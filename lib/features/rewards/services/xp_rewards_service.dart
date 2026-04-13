import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/xp_rewards_models.dart';

class XPRewardsService {
  static const String _walletPrefsPrefix = 'xp_rewards_wallet_';
  static const String _txPrefsPrefix = 'xp_rewards_transactions_';
  static const int _maxTransactions = 40;

  static const int dailyLoginXp = 15;
  static const int dailyLoginCredits = 20;
  static const int lessonCompletionCredits = 8;
  static const int courseCompletionXp = 60;
  static const int courseCompletionCredits = 50;
  static const int weeklyStreakXp = 40;
  static const int weeklyStreakCredits = 35;
  static const int monthlyStreakXp = 120;
  static const int monthlyStreakCredits = 90;
  static const double xpBoostMultiplier = 0.25;

  final FirebaseFirestore? _firestore;

  XPRewardsService({FirebaseFirestore? firestore}) : _firestore = firestore;

  Future<RewardWallet> getWallet({
    required String userId,
    required bool useLocalMode,
  }) async {
    final localWallet = await _getLocalWallet(userId);
    if (useLocalMode) return localWallet;

    try {
      final snapshot = await (_firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(userId)
          .get();
      final raw = snapshot.data();
      if (raw == null || raw['xpRewards'] is! Map) {
        if (!localWallet.isEmpty) {
          await _saveRemoteWallet(userId: userId, wallet: localWallet);
          return localWallet;
        }
        return const RewardWallet.initial();
      }

      final remoteWallet = RewardWallet.fromJson(
        Map<String, dynamic>.from(raw['xpRewards'] as Map),
      );
      await _saveLocalWallet(userId, remoteWallet);
      return remoteWallet;
    } on FirebaseException {
      return localWallet;
    } on StateError {
      return localWallet;
    }
  }

  Future<List<RewardTransaction>> getTransactions({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_txPrefsPrefix$userId');
    if (raw == null || raw.trim().isEmpty) return const <RewardTransaction>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <RewardTransaction>[];

    return decoded
        .whereType<Map>()
        .map(
          (item) => RewardTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<RewardActionResult> claimDailyCheckIn({
    required String userId,
    required bool useLocalMode,
    required int currentStreak,
  }) async {
    final wallet = await getWallet(userId: userId, useLocalMode: useLocalMode);
    final dayKey = _dayKey(DateTime.now());

    if (!wallet.canClaimDaily(dayKey)) {
      return RewardActionResult(
        applied: false,
        remoteSynced: true,
        creditsEarned: 0,
        xpEarned: 0,
        message: 'Daily bonus already claimed.',
        wallet: wallet,
      );
    }

    var credits = dailyLoginCredits;
    if (currentStreak >= 7) {
      credits += 5;
    }

    final updatedWallet = wallet.copyWith(
      creditsBalance: wallet.creditsBalance + credits,
      totalCreditsEarned: wallet.totalCreditsEarned + credits,
      lastDailyClaimDate: dayKey,
      updatedAt: DateTime.now(),
    );

    final remoteSynced = await _saveWallet(
      userId: userId,
      useLocalMode: useLocalMode,
      wallet: updatedWallet,
    );
    final xpSynced = await _incrementUserXP(
      userId: userId,
      useLocalMode: useLocalMode,
      xpDelta: dailyLoginXp,
    );

    await _appendTransactions(
      userId: userId,
      transactions: [
        RewardTransaction(
          id: _txId('daily'),
          type: RewardTransactionType.dailyCheckIn,
          creditsDelta: credits,
          xpDelta: dailyLoginXp,
          title: 'Daily check-in bonus',
          subtitle: 'Login streak reward',
          createdAt: DateTime.now(),
        ),
      ],
    );

    return RewardActionResult(
      applied: true,
      remoteSynced: remoteSynced && xpSynced,
      creditsEarned: credits,
      xpEarned: dailyLoginXp,
      message: remoteSynced && xpSynced
          ? 'Daily bonus claimed.'
          : 'Daily bonus saved locally.',
      wallet: updatedWallet,
    );
  }

  Future<RewardActionResult> processLessonCompletion({
    required String userId,
    required bool useLocalMode,
    required String courseId,
    required int currentStreak,
    required int baseLessonXp,
    required bool courseCompletedNow,
  }) async {
    final wallet = await getWallet(userId: userId, useLocalMode: useLocalMode);
    var updatedWallet = wallet;
    var creditsEarned = lessonCompletionCredits;
    var xpEarned = 0;
    final transactions = <RewardTransaction>[
      RewardTransaction(
        id: _txId('lesson'),
        type: RewardTransactionType.lessonCompletion,
        creditsDelta: lessonCompletionCredits,
        xpDelta: 0,
        title: 'Lesson completion',
        subtitle: 'Practice consistency bonus',
        createdAt: DateTime.now(),
      ),
    ];

    if (wallet.xpBoostLessonsRemaining > 0) {
      final boostXp = (baseLessonXp * xpBoostMultiplier).round().clamp(5, 200);
      xpEarned += boostXp;
      updatedWallet = updatedWallet.copyWith(
        xpBoostLessonsRemaining: wallet.xpBoostLessonsRemaining - 1,
      );
      transactions.add(
        RewardTransaction(
          id: _txId('boost'),
          type: RewardTransactionType.boosterXpBonus,
          creditsDelta: 0,
          xpDelta: boostXp,
          title: 'XP booster active',
          subtitle: '+$boostXp XP from active booster',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (courseCompletedNow &&
        !wallet.rewardedCompletedCourses.contains(courseId)) {
      creditsEarned += courseCompletionCredits;
      xpEarned += courseCompletionXp;
      updatedWallet = updatedWallet.copyWith(
        rewardedCompletedCourses: <String>[
          ...updatedWallet.rewardedCompletedCourses,
          courseId,
        ],
      );
      transactions.add(
        RewardTransaction(
          id: _txId('course'),
          type: RewardTransactionType.courseCompletion,
          creditsDelta: courseCompletionCredits,
          xpDelta: courseCompletionXp,
          title: 'Course completed',
          subtitle: 'One-time completion bonus',
          createdAt: DateTime.now(),
        ),
      );
    }

    final shouldRewardWeeklyStreak =
        currentStreak > 0 &&
        currentStreak % 7 == 0 &&
        !wallet.claimedStreakMilestones.contains(currentStreak);
    final shouldRewardMonthlyStreak =
        currentStreak > 0 &&
        currentStreak % 30 == 0 &&
        !wallet.claimedStreakMilestones.contains(currentStreak);

    if (shouldRewardWeeklyStreak) {
      creditsEarned += weeklyStreakCredits;
      xpEarned += weeklyStreakXp;
      transactions.add(
        RewardTransaction(
          id: _txId('streak-weekly'),
          type: RewardTransactionType.streakMilestone,
          creditsDelta: weeklyStreakCredits,
          xpDelta: weeklyStreakXp,
          title: 'Weekly streak milestone',
          subtitle: '$currentStreak-day streak reached',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (shouldRewardMonthlyStreak) {
      creditsEarned += monthlyStreakCredits;
      xpEarned += monthlyStreakXp;
      transactions.add(
        RewardTransaction(
          id: _txId('streak-monthly'),
          type: RewardTransactionType.streakMilestone,
          creditsDelta: monthlyStreakCredits,
          xpDelta: monthlyStreakXp,
          title: 'Monthly streak milestone',
          subtitle: '$currentStreak-day streak reached',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (shouldRewardWeeklyStreak || shouldRewardMonthlyStreak) {
      updatedWallet = updatedWallet.copyWith(
        claimedStreakMilestones: <int>[
          ...updatedWallet.claimedStreakMilestones,
          currentStreak,
        ],
      );
    }

    updatedWallet = updatedWallet.copyWith(
      creditsBalance: updatedWallet.creditsBalance + creditsEarned,
      totalCreditsEarned: updatedWallet.totalCreditsEarned + creditsEarned,
      updatedAt: DateTime.now(),
    );

    final walletSynced = await _saveWallet(
      userId: userId,
      useLocalMode: useLocalMode,
      wallet: updatedWallet,
    );
    final xpSynced = await _incrementUserXP(
      userId: userId,
      useLocalMode: useLocalMode,
      xpDelta: xpEarned,
    );

    await _appendTransactions(userId: userId, transactions: transactions);

    return RewardActionResult(
      applied: true,
      remoteSynced: walletSynced && xpSynced,
      creditsEarned: creditsEarned,
      xpEarned: xpEarned,
      message: 'Lesson rewards applied.',
      wallet: updatedWallet,
    );
  }

  Future<RewardPurchaseResult> purchaseItem({
    required String userId,
    required bool useLocalMode,
    required String itemId,
  }) async {
    final item = RewardShopCatalog.byId(itemId);
    final wallet = await getWallet(userId: userId, useLocalMode: useLocalMode);
    if (item == null) {
      return RewardPurchaseResult(
        success: false,
        remoteSynced: true,
        message: 'Unknown reward item.',
        wallet: wallet,
      );
    }

    if (wallet.creditsBalance < item.costCredits) {
      return RewardPurchaseResult(
        success: false,
        remoteSynced: true,
        message: 'Not enough credits.',
        wallet: wallet,
      );
    }

    if (item.cosmeticId != null &&
        wallet.ownedCosmetics.contains(item.cosmeticId)) {
      return RewardPurchaseResult(
        success: false,
        remoteSynced: true,
        message: 'Item already owned.',
        wallet: wallet,
      );
    }

    final updatedWallet = wallet.copyWith(
      creditsBalance: wallet.creditsBalance - item.costCredits,
      totalCreditsSpent: wallet.totalCreditsSpent + item.costCredits,
      xpBoostLessonsRemaining:
          wallet.xpBoostLessonsRemaining + item.xpBoostLessons,
      streakShields: wallet.streakShields + item.streakShields,
      hintTokens: wallet.hintTokens + item.hintTokens,
      ownedCosmetics: item.cosmeticId == null
          ? wallet.ownedCosmetics
          : <String>[...wallet.ownedCosmetics, item.cosmeticId!],
      updatedAt: DateTime.now(),
    );

    final remoteSynced = await _saveWallet(
      userId: userId,
      useLocalMode: useLocalMode,
      wallet: updatedWallet,
    );
    await _appendTransactions(
      userId: userId,
      transactions: [
        RewardTransaction(
          id: _txId('purchase'),
          type: RewardTransactionType.purchase,
          creditsDelta: -item.costCredits,
          xpDelta: 0,
          title: 'Shop purchase',
          subtitle: item.id,
          createdAt: DateTime.now(),
        ),
      ],
    );

    return RewardPurchaseResult(
      success: true,
      remoteSynced: remoteSynced,
      message: remoteSynced ? 'Purchase completed.' : 'Purchase saved locally.',
      wallet: updatedWallet,
    );
  }

  Future<bool> _saveWallet({
    required String userId,
    required bool useLocalMode,
    required RewardWallet wallet,
  }) async {
    await _saveLocalWallet(userId, wallet);
    if (useLocalMode) return true;
    return _saveRemoteWallet(userId: userId, wallet: wallet);
  }

  Future<bool> _saveRemoteWallet({
    required String userId,
    required RewardWallet wallet,
  }) async {
    try {
      await (_firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(userId)
          .set({
            'uid': userId,
            'xpRewards': wallet.toJson(),
          }, SetOptions(merge: true));
      return true;
    } on FirebaseException {
      return false;
    } on StateError {
      return false;
    }
  }

  Future<bool> _incrementUserXP({
    required String userId,
    required bool useLocalMode,
    required int xpDelta,
  }) async {
    if (xpDelta <= 0) return true;
    if (useLocalMode) return true;

    try {
      await (_firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(userId)
          .set({
            'uid': userId,
            'totalXP': FieldValue.increment(xpDelta),
          }, SetOptions(merge: true));
      return true;
    } on FirebaseException {
      return false;
    } on StateError {
      return false;
    }
  }

  Future<void> _saveLocalWallet(String userId, RewardWallet wallet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_walletPrefsPrefix$userId',
      jsonEncode(wallet.toJson()),
    );
  }

  Future<RewardWallet> _getLocalWallet(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_walletPrefsPrefix$userId');
    if (raw == null || raw.trim().isEmpty) return const RewardWallet.initial();

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const RewardWallet.initial();
    return RewardWallet.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> _appendTransactions({
    required String userId,
    required List<RewardTransaction> transactions,
  }) async {
    final existing = await getTransactions(userId: userId);
    final updated = <RewardTransaction>[...transactions, ...existing];
    final trimmed = updated.take(_maxTransactions).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_txPrefsPrefix$userId',
      jsonEncode(trimmed.map((item) => item.toJson()).toList(growable: false)),
    );
  }

  String _dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _txId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
