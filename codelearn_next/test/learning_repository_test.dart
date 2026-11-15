import 'package:codelearn_next/features/catalog/domain/content.dart';
import 'package:codelearn_next/features/learning/domain/learning_session.dart';
import 'package:codelearn_next/features/progress/data/learning_repository.dart';
import 'package:codelearn_next/features/progress/domain/learning_data.dart';
import 'package:codelearn_next/features/rewards/domain/reward_policy.dart';
import 'package:codelearn_next/foundation/json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late LearningRepository repository;
  late DateTime clock;
  late Lesson lesson;
  setUp(() async {
    clock = DateTime(2026, 11, 14, 23, 59);
    final database = await databaseFactoryMemory.openDatabase(
      'test-${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = LearningRepository(database, clock: () => clock);
    lesson = Lesson.fromJson({
      'id': 'first',
      'courseId': 'python',
      'version': 1,
      'xpReward': 20,
      'theorySlides': [],
      'quiz': null,
    });
  });
  tearDown(() async => repository.database.close());

  test(
    'concurrent completion rewards exactly once and persists after reload',
    () async {
      final session = LearningSession(lessonId: lesson.id, contentVersion: 1);
      final results = await Future.wait(
        List.generate(
          8,
          (index) => repository.complete('guest', lesson, session, 10),
        ),
      );
      expect(results.where((item) => item.applied).length, 1);
      final data = await repository.load('guest');
      expect(data.completions.length, 1);
      expect(data.xp, 40);
      expect(data.wallet.credits, 8);
      expect(data.ledger.length, 1);
      expect(data.pending, 1);
    },
  );
  test(
    'completion reports level up only when the level threshold is crossed',
    () async {
      final first = await repository.complete(
        'guest',
        lesson,
        LearningSession(lessonId: lesson.id, contentVersion: 1),
        10,
      );
      final second = await repository.complete(
        'guest',
        Lesson.fromJson({
          'id': 'second',
          'courseId': 'python',
          'version': 1,
          'xpReward': 20,
          'theorySlides': [],
          'quiz': null,
        }),
        LearningSession(lessonId: 'second', contentVersion: 1),
        10,
      );
      expect(first.levelUp, isFalse);
      expect(second.levelUp, isTrue);
      expect(RewardPolicy.level((await repository.load('guest')).xp), 2);
    },
  );
  test('completion is isolated by account', () async {
    await repository.complete(
      'one',
      lesson,
      LearningSession(lessonId: 'first', contentVersion: 1),
      10,
    );
    expect((await repository.load('two')).completions, isEmpty);
    expect((await repository.load('two')).xp, 0);
  });
  test(
    'daily claim is idempotent and does not start learning streak',
    () async {
      expect(await repository.claimDaily('guest'), isTrue);
      expect(await repository.claimDaily('guest'), isFalse);
      final data = await repository.load('guest');
      expect(data.wallet.credits, 20);
      expect(data.streak, 0);
    },
  );
  test(
    'calendar day transition increases streak without requiring 24 hours',
    () async {
      await repository.complete(
        'guest',
        lesson,
        LearningSession(lessonId: 'first', contentVersion: 1),
        10,
      );
      clock = DateTime(2026, 11, 15, 0, 1);
      final next = Lesson.fromJson({
        'id': 'second',
        'courseId': 'python',
        'xpReward': 20,
      });
      await repository.complete(
        'guest',
        next,
        LearningSession(lessonId: 'second', contentVersion: 1),
        10,
      );
      expect((await repository.load('guest')).streak, 2);
    },
  );
  test('wallet cannot spend beyond its balance', () async {
    await repository.claimDaily('guest');
    await expectLater(
      repository.purchase('guest', 'booster'),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.load('guest')).wallet.credits, 20);
  });
  test('import rolls back entirely on an invalid completion', () async {
    const raw =
        '{"schemaVersion":1,"completions":[{"lessonId":"first","courseId":"python","xp":20,"at":"2026-11-14T12:00:00Z"},{"lessonId":"bad","courseId":"python","at":"2026-11-14T12:00:00Z"}],"portfolio":[]}';
    await expectLater(
      repository.importData('guest', raw, {'first': 'python'}),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.load('guest')).completions, isEmpty);
  });
  test('backup merge does not duplicate existing completions', () async {
    await repository.complete(
      'guest',
      lesson,
      LearningSession(lessonId: 'first', contentVersion: 1),
      10,
    );
    final backup = await repository.exportData('guest');
    await repository.importData('guest', backup, {'first': 'python'});
    expect((await repository.load('guest')).completions.length, 1);
    expect((await repository.load('guest')).xp, 40);
  });
  test('quiz must be passed before completion', () async {
    final quizLesson = Lesson.fromJson({
      'id': 'quiz',
      'courseId': 'python',
      'quiz': {
        'questions': [
          {
            'id': 'q1',
            'question': 'Q',
            'options': ['a', 'b'],
            'optionIds': ['a', 'b'],
            'correctOptionId': 'b',
          },
        ],
      },
    });
    final session = LearningSession(
      lessonId: 'quiz',
      contentVersion: 1,
      answers: {'q1': 'a'},
    );
    await expectLater(
      repository.complete('guest', quizLesson, session, 10),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.load('guest')).xp, 0);
  });
  test('day distance uses dates across DST', () {
    expect(RewardPolicy.dayDistance('2026-10-24', '2026-10-25'), 1);
    expect(RewardPolicy.dayDistance('2026-10-25', '2026-10-26'), 1);
  });
  test(
    'backup restores wallet, achievements, drafts and portfolio to a clean account',
    () async {
      await repository.claimDaily('source');
      await repository.complete(
        'source',
        lesson,
        LearningSession(
          lessonId: 'first',
          contentVersion: 1,
          code: 'print(42)',
        ),
        10,
      );
      await repository.savePortfolio(
        'source',
        PortfolioEntry.fromJson({
          'id': 'snippet:1',
          'title': 'A solution',
          'language': 'python',
          'code': 'print(42)',
          'at': clock.toUtc().toIso8601String(),
        }),
      );
      final backup = await repository.exportData('source');
      await repository.importData('target', backup, {'first': 'python'});
      final restored = await repository.load('target');
      expect(restored.wallet.credits, 28);
      expect(restored.xp, 55);
      expect(restored.achievements, contains('firstLesson'));
      expect(restored.sessions['first']?.code, 'print(42)');
      expect(restored.portfolio.single.code, 'print(42)');
      expect(restored.pending, 3);
    },
  );
  test('boost is consumed once by a unique completion', () async {
    for (var index = 0; index < 4; index++) {
      clock = DateTime(2026, 11, 10 + index);
      await repository.claimDaily('guest');
    }
    await repository.purchase('guest', 'booster');
    final session = LearningSession(lessonId: 'first', contentVersion: 1);
    final first = await repository.complete('guest', lesson, session, 10);
    await repository.complete('guest', lesson, session, 10);
    expect(first.xp, 45);
    expect((await repository.load('guest')).wallet.boosts, 2);
  });
  test('revealing the same hint twice consumes one token', () async {
    for (var index = 0; index < 3; index++) {
      clock = DateTime(2026, 11, 10 + index);
      await repository.claimDaily('guest');
    }
    await repository.purchase('guest', 'hints');
    final session = LearningSession(lessonId: 'first', contentVersion: 1);
    await repository.revealHint('guest', session);
    await repository.revealHint('guest', session);
    expect((await repository.load('guest')).wallet.hints, 4);
  });
  test('stale lesson sessions cannot award progress', () async {
    await expectLater(
      repository.complete(
        'guest',
        lesson,
        LearningSession(lessonId: 'first', contentVersion: 99),
        10,
      ),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.load('guest')).completions, isEmpty);
  });
  test('edited portfolio entries receive separate sync receipts', () async {
    final entry = PortfolioEntry.fromJson({
      'id': 'snippet:1',
      'title': 'First',
      'code': 'print(1)',
      'at': clock.toIso8601String(),
    });
    await repository.savePortfolio('guest', entry);
    await repository.savePortfolio(
      'guest',
      PortfolioEntry.fromJson({...entry.toJson(), 'code': 'print(2)'}),
    );
    final data = await repository.load('guest');
    expect(data.portfolio.length, 1);
    expect(data.portfolio.single.code, 'print(2)');
    expect(data.pending, 2);
  });
}
