import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../../../foundation/json.dart';
import '../../catalog/domain/content.dart';
import '../../learning/domain/learning_session.dart';
import '../../rewards/domain/reward_policy.dart';
import '../domain/learning_data.dart';
import '../domain/achievement.dart';

class LearningRepository {
  final Database database;
  final DateTime Function() now;
  final StoreRef<String, JsonMap> profiles = stringMapStoreFactory.store(
    'profiles',
  );
  final StoreRef<String, JsonMap> preferences = stringMapStoreFactory.store(
    'preferences',
  );
  final StoreRef<String, JsonMap> completions = stringMapStoreFactory.store(
    'completions',
  );
  final StoreRef<String, JsonMap> sessions = stringMapStoreFactory.store(
    'sessions',
  );
  final StoreRef<String, JsonMap> portfolio = stringMapStoreFactory.store(
    'portfolio',
  );
  final StoreRef<String, JsonMap> ledger = stringMapStoreFactory.store(
    'ledger',
  );
  final StoreRef<String, JsonMap> attempts = stringMapStoreFactory.store(
    'attempts',
  );
  final StoreRef<String, JsonMap> outbox = stringMapStoreFactory.store(
    'outbox',
  );

  LearningRepository(this.database, {DateTime Function()? clock})
    : now = clock ?? DateTime.now;

  String key(String account, String id) => '$account/$id';
  Finder forAccount(String account, {int? limit, String? sort}) => Finder(
    filter: Filter.equals('accountId', account),
    limit: limit,
    sortOrders: sort == null ? null : [SortOrder(sort, false)],
  );

  Future<LearningData> load(String account) => database.transaction((
    transaction,
  ) async {
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final settings =
        await preferences.record('device').get(transaction) ??
        <String, Object?>{};
    final completionRows = await completions.find(
      transaction,
      finder: forAccount(account),
    );
    final sessionRows = await sessions.find(
      transaction,
      finder: forAccount(account),
    );
    final portfolioRows = await portfolio.find(
      transaction,
      finder: forAccount(account, limit: 100, sort: 'at'),
    );
    final ledgerRows = await ledger.find(
      transaction,
      finder: forAccount(account, limit: 40, sort: 'at'),
    );
    final attemptRows = await attempts.find(
      transaction,
      finder: forAccount(account, limit: 200, sort: 'at'),
    );
    return LearningData(
      profile: profile,
      preferences: Preferences.fromJson(settings),
      wallet: Wallet.fromJson(jsonMap(profile['wallet'])),
      completions: {
        for (final item in completionRows)
          jsonString(item.value['lessonId']): Completion.fromJson(item.value),
      },
      sessions: {
        for (final item in sessionRows)
          jsonString(item.value['lessonId']): LearningSession.fromJson(
            item.value,
          ),
      },
      portfolio: portfolioRows
          .map((item) => PortfolioEntry.fromJson(item.value))
          .toList(),
      ledger: ledgerRows.map((item) => item.value).toList(),
      attempts: attemptRows.map((item) => item.value).toList(),
      achievements: jsonList(
        profile['achievements'],
      ).map((item) => jsonString(item)).toSet(),
      pending: await outbox.count(
        transaction,
        filter: Filter.equals('accountId', account),
      ),
    );
  });

  Future<void> updatePreferences(JsonMap patch) =>
      database.transaction((transaction) async {
        final current =
            await preferences.record('device').get(transaction) ??
            <String, Object?>{};
        await preferences
            .record('device')
            .put(
              transaction,
              Preferences.fromJson({...current, ...patch}).toJson(),
            );
      });

  Future<void> updateProfile(
    String account,
    JsonMap patch,
  ) => database.transaction((transaction) async {
    final current =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final allowed = {
      for (final field in ['name', 'bio', 'avatar', 'focus', 'dailyMinutes'])
        if (patch.containsKey(field)) field: patch[field],
    };
    final payload = {...current, ...allowed};
    await profiles.record(account).put(transaction, payload);
    await enqueue(transaction, account, 'profile', allowed, 'profile');
  });

  Future<void> saveSession(String account, LearningSession session) async {
    await sessions.record(key(account, session.lessonId)).put(database, {
      ...session.toJson(),
      'accountId': account,
    });
  }

  Future<void> recordAttempt(
    String account,
    String courseId,
    String lessonId,
    bool passed, {
    String code = '',
  }) async {
    final at = now().toUtc().toIso8601String();
    final id = '${lessonId}_${now().microsecondsSinceEpoch}';
    await attempts.record(key(account, id)).put(database, {
      'accountId': account,
      'courseId': courseId,
      'lessonId': lessonId,
      'passed': passed,
      'code': code,
      'at': at,
    });
  }

  Future<CompletionResult> complete(
    String account,
    Lesson lesson,
    LearningSession session,
    int courseSize,
  ) => database.transaction((transaction) async {
    if (session.lessonId != lesson.id ||
        session.contentVersion != lesson.version ||
        !session.canComplete(lesson)) {
      throw const AppFailure('quizRequired');
    }
    final record = completions.record(key(account, lesson.id));
    if (await record.exists(transaction)) {
      return const CompletionResult(applied: false);
    }
    final at = now();
    final today = RewardPolicy.dayKey(at);
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final wallet = jsonMap(profile['wallet']);
    final boost = jsonInt(wallet['boosts']) > 0;
    final earned = RewardPolicy.lessonXp(lesson.xp, boost);
    final lastDay = jsonString(profile['lastLearningDay']);
    final distance = RewardPolicy.dayDistance(lastDay, today);
    var streak = jsonInt(profile['streak']);
    var shields = jsonInt(wallet['shields']);
    if (lastDay.isEmpty) {
      streak = 1;
    } else if (distance == 1) {
      streak++;
    } else if (distance == 2 && shields > 0) {
      streak++;
      shields--;
    } else if (distance > 1) {
      streak = 1;
    }
    final value = <String, Object?>{
      'accountId': account,
      'lessonId': lesson.id,
      'courseId': lesson.courseId,
      'version': lesson.version,
      'xp': earned,
      'at': at.toUtc().toIso8601String(),
    };
    await record.put(transaction, value);
    final total = await completions.count(
      transaction,
      filter: Filter.equals('accountId', account),
    );
    final inCourse = await completions.count(
      transaction,
      filter: Filter.and([
        Filter.equals('accountId', account),
        Filter.equals('courseId', lesson.courseId),
      ]),
    );
    final courseFinished = inCourse == courseSize;
    final oldAchievements = jsonList(
      profile['achievements'],
    ).map((item) => jsonString(item)).toSet();
    final unlocked = <String>[];
    final completedCourseIds = jsonList(
      profile['completedCourseIds'],
    ).map((id) => jsonString(id)).toSet();
    if (courseFinished) completedCourseIds.add(lesson.courseId);
    for (final achievement in achievementDefinitions) {
      if (achievement.isUnlocked(
            lessons: total,
            streak: streak,
            xp: jsonInt(profile['xp']) + earned,
            courses: completedCourseIds.length,
          ) &&
          oldAchievements.add(achievement.id)) {
        unlocked.add(achievement.id);
      }
    }
    final milestoneBonus = unlocked.length * 20;
    final totalEarned = earned + (courseFinished ? 60 : 0) + milestoneBonus;
    final credits = 8 + (courseFinished ? 50 : 0);
    await profiles.record(account).put(transaction, {
      ...profile,
      'xp': jsonInt(profile['xp']) + totalEarned,
      'streak': streak,
      'lastLearningDay': today,
      'achievements': oldAchievements.toList(),
      'completedCourseIds': completedCourseIds.toList(),
      'wallet': {
        ...wallet,
        'credits': jsonInt(wallet['credits']) + credits,
        'boosts': (jsonInt(wallet['boosts']) - (boost ? 1 : 0)).clamp(0, 9999),
        'shields': shields,
      },
    });
    await sessions.record(key(account, lesson.id)).put(transaction, {
      ...session.copyWith(stage: LearningStage.complete).toJson(),
      'accountId': account,
    });
    await ledger.record(key(account, 'lesson:${lesson.id}')).put(transaction, {
      'accountId': account,
      'type': 'lesson',
      'xp': totalEarned,
      'credits': credits,
      'at': at.toUtc().toIso8601String(),
    });
    await enqueue(transaction, account, 'completion', {
      'lessonId': lesson.id,
      'courseId': lesson.courseId,
      'version': lesson.version,
      'completedAt': at.toUtc().toIso8601String(),
    }, 'completion:${lesson.id}');
    return CompletionResult(
      applied: true,
      xp: totalEarned,
      credits: credits,
      achievements: unlocked,
    );
  });

  Future<bool> claimDaily(String account) => database.transaction((
    transaction,
  ) async {
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final wallet = jsonMap(profile['wallet']);
    final today = RewardPolicy.dayKey(now());
    if (wallet['dailyClaim'] == today) return false;
    await profiles.record(account).put(transaction, {
      ...profile,
      'xp': jsonInt(profile['xp']) + 15,
      'wallet': {
        ...wallet,
        'dailyClaim': today,
        'credits': jsonInt(wallet['credits']) + 20,
      },
    });
    await ledger.record(key(account, 'daily:$today')).put(transaction, {
      'accountId': account,
      'type': 'daily',
      'xp': 15,
      'credits': 20,
      'at': now().toUtc().toIso8601String(),
    });
    await enqueue(transaction, account, 'daily', {
      'day': today,
    }, 'daily:$today');
    return true;
  });

  Future<void> purchase(String account, String itemId) => database.transaction((
    transaction,
  ) async {
    final item = shopItems.where((item) => item.id == itemId).firstOrNull;
    if (item == null) throw const AppFailure('notFound');
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final wallet = jsonMap(profile['wallet']);
    if (jsonInt(wallet['credits']) < item.cost) {
      throw const AppFailure('insufficientCredits');
    }
    if (itemId == 'frame' && jsonBool(wallet['hasFrame'])) {
      throw const AppFailure('owned');
    }
    final updated = {
      ...wallet,
      'credits': jsonInt(wallet['credits']) - item.cost,
    };
    switch (itemId) {
      case 'booster':
        updated['boosts'] = jsonInt(wallet['boosts']) + 3;
      case 'shield':
        updated['shields'] = jsonInt(wallet['shields']) + 1;
      case 'hints':
        updated['hints'] = jsonInt(wallet['hints']) + 5;
      case 'frame':
        updated['hasFrame'] = true;
    }
    await profiles.record(account).put(transaction, {
      ...profile,
      'wallet': updated,
    });
    final id = 'purchase:${now().microsecondsSinceEpoch}';
    await ledger.record(key(account, id)).put(transaction, {
      'accountId': account,
      'type': itemId,
      'xp': 0,
      'credits': -item.cost,
      'at': now().toUtc().toIso8601String(),
    });
    await enqueue(transaction, account, 'purchase', {'itemId': itemId}, id);
  });

  Future<void> revealHint(String account, LearningSession session) =>
      database.transaction((transaction) async {
        final stored = await sessions
            .record(key(account, session.lessonId))
            .get(transaction);
        if (session.hintRevealed || jsonBool(stored?['hintRevealed'])) return;
        final profile =
            await profiles.record(account).get(transaction) ??
            <String, Object?>{};
        final wallet = jsonMap(profile['wallet']);
        if (jsonInt(wallet['hints']) <= 0) throw const AppFailure('hintEmpty');
        await profiles.record(account).put(transaction, {
          ...profile,
          'wallet': {...wallet, 'hints': jsonInt(wallet['hints']) - 1},
        });
        await sessions.record(key(account, session.lessonId)).put(transaction, {
          ...session.copyWith(hintRevealed: true).toJson(),
          'accountId': account,
        });
        await enqueue(transaction, account, 'hint', {
          'lessonId': session.lessonId,
        }, 'hint:${session.lessonId}');
      });

  Future<List<PortfolioEntry>> portfolioPage(String account, int limit) async {
    final rows = await portfolio.find(
      database,
      finder: forAccount(account, limit: limit, sort: 'at'),
    );
    return List.unmodifiable(
      rows.map((row) => PortfolioEntry.fromJson(row.value)),
    );
  }

  Future<void> savePortfolio(String account, PortfolioEntry entry) =>
      database.transaction((transaction) async {
        if (entry.title.trim().isEmpty || entry.code.trim().isEmpty) {
          throw const AppFailure('requiredField');
        }
        await portfolio.record(key(account, entry.id)).put(transaction, {
          ...entry.toJson(),
          'accountId': account,
        });
        await enqueue(
          transaction,
          account,
          'portfolio',
          entry.toJson(),
          'portfolio:${entry.id}',
        );
      });

  Future<void> deletePortfolio(String account, String id) =>
      database.transaction((transaction) async {
        await portfolio.record(key(account, id)).delete(transaction);
        await enqueue(transaction, account, 'portfolioDelete', {
          'id': id,
        }, 'portfolioDelete:$id');
      });

  Future<void> enqueue(
    Transaction transaction,
    String account,
    String type,
    JsonMap payload,
    String id,
  ) async {
    var operationId = id;
    if (type == 'profile' || type == 'portfolio') {
      final record = preferences.record('operationSequence:$account');
      final previous = await record.get(transaction) ?? <String, Object?>{};
      final sequence = jsonInt(previous['sequence']) + 1;
      await record.put(transaction, {'sequence': sequence});
      operationId = '$id:$sequence';
    }
    await outbox.record(key(account, operationId)).put(transaction, {
      'accountId': account,
      'id': operationId,
      'type': type,
      'payload': payload,
      'at': now().toUtc().toIso8601String(),
    });
  }

  Future<void> submitSupport(String account, String message) =>
      database.transaction((transaction) async {
        if (message.trim().length < 5) throw const AppFailure('requiredField');
        await enqueue(transaction, account, 'support', {
          'message': message.trim(),
        }, 'support:${now().microsecondsSinceEpoch}');
      });

  Future<String> exportData(String account) => database.transaction((
    transaction,
  ) async {
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    final settings =
        await preferences.record('device').get(transaction) ??
        <String, Object?>{};
    final result = <String, Object?>{
      'schemaVersion': 1,
      'profile': profile,
      'preferences': settings,
    };
    for (final store in [
      completions,
      sessions,
      portfolio,
      ledger,
      attempts,
      outbox,
    ]) {
      final rows = await store.find(transaction, finder: forAccount(account));
      result[store.name] = rows
          .map(
            (row) => {
              'recordId': row.key.substring(account.length + 1),
              ...row.value,
            }..remove('accountId'),
          )
          .toList();
    }
    return const JsonEncoder.withIndent('  ').convert(result);
  });

  Future<void> importData(
    String account,
    String raw,
    Map<String, String> validLessons,
  ) async {
    if (raw.length > 20000000) throw const AppFailure('importFailed');
    final JsonMap decoded;
    try {
      decoded = jsonMap(jsonDecode(raw));
    } on FormatException {
      throw const AppFailure('importFailed');
    }
    if (decoded['schemaVersion'] != 1 ||
        decoded['completions'] is! List ||
        decoded['portfolio'] is! List) {
      throw const AppFailure('importFailed');
    }
    await database.transaction((transaction) async {
      for (final value in jsonList(decoded['completions'])) {
        final row = jsonMap(value);
        final id = jsonString(row['lessonId']);
        if (validLessons[id] != row['courseId'] ||
            jsonDate(row['at']) == null) {
          throw const AppFailure('importFailed');
        }
        final record = completions.record(key(account, id));
        if (!await record.exists(transaction)) {
          await record.put(transaction, {...row, 'accountId': account});
        }
      }
      for (final value in jsonList(decoded['portfolio'])) {
        final entry = PortfolioEntry.fromJson(jsonMap(value));
        if (entry.id.isEmpty || entry.code.isEmpty) {
          throw const AppFailure('importFailed');
        }
        final record = portfolio.record(key(account, entry.id));
        if (!await record.exists(transaction)) {
          await record.put(transaction, {
            ...entry.toJson(),
            'accountId': account,
          });
        }
      }
      for (final store in [sessions, ledger, attempts, outbox]) {
        for (final value in jsonList(decoded[store.name])) {
          final row = jsonMap(value);
          final id = jsonString(row['recordId']);
          if (id.isEmpty || id.length > 240 || id.contains('/')) {
            throw const AppFailure('importFailed');
          }
          if (store.name == 'sessions' &&
              !validLessons.containsKey(jsonString(row['lessonId']))) {
            throw const AppFailure('importFailed');
          }
          final record = store.record(key(account, id));
          if (!await record.exists(transaction)) {
            await record.put(
              transaction,
              {...row, 'accountId': account}..remove('recordId'),
            );
          }
        }
      }
      final profile =
          await profiles.record(account).get(transaction) ??
          <String, Object?>{};
      final backupProfile = jsonMap(decoded['profile']);
      final rows = await completions.find(
        transaction,
        finder: forAccount(account),
      );
      final totalXp = rows.fold<int>(
        0,
        (sum, row) => sum + jsonInt(row.value['xp']).clamp(0, 10000),
      );
      final merged = {...backupProfile, ...profile};
      await profiles.record(account).put(transaction, {
        ...merged,
        'xp': [
          jsonInt(profile['xp']),
          jsonInt(backupProfile['xp']),
          totalXp,
        ].reduce((left, right) => left > right ? left : right),
      });
      if (!await preferences.record('device').exists(transaction) &&
          decoded['preferences'] is Map) {
        await preferences
            .record('device')
            .put(
              transaction,
              Preferences.fromJson(jsonMap(decoded['preferences'])).toJson(),
            );
      }
    });
  }

  Future<void> mergeGuest(String account) => database.transaction((
    transaction,
  ) async {
    if (account == 'guest') return;
    for (final store in [completions, sessions, portfolio, attempts, outbox]) {
      final records = await store.find(
        transaction,
        finder: forAccount('guest'),
      );
      for (final record in records) {
        final id = record.key.substring('guest/'.length);
        final target = store.record(key(account, id));
        if (!await target.exists(transaction)) {
          await target.put(transaction, {
            ...record.value,
            'accountId': account,
          });
        }
      }
    }
    final guestProfile =
        await profiles.record('guest').get(transaction) ?? <String, Object?>{};
    final profile =
        await profiles.record(account).get(transaction) ?? <String, Object?>{};
    await profiles.record(account).put(transaction, {
      ...guestProfile,
      ...profile,
    });
  });
}
