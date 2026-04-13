enum RewardTransactionType {
  dailyCheckIn,
  lessonCompletion,
  streakMilestone,
  courseCompletion,
  purchase,
  boosterXpBonus,
}

RewardTransactionType rewardTransactionTypeFromString(String raw) {
  switch (raw) {
    case 'dailyCheckIn':
      return RewardTransactionType.dailyCheckIn;
    case 'lessonCompletion':
      return RewardTransactionType.lessonCompletion;
    case 'streakMilestone':
      return RewardTransactionType.streakMilestone;
    case 'courseCompletion':
      return RewardTransactionType.courseCompletion;
    case 'purchase':
      return RewardTransactionType.purchase;
    case 'boosterXpBonus':
      return RewardTransactionType.boosterXpBonus;
    default:
      return RewardTransactionType.lessonCompletion;
  }
}

class RewardWallet {
  final int creditsBalance;
  final int totalCreditsEarned;
  final int totalCreditsSpent;
  final int xpBoostLessonsRemaining;
  final int streakShields;
  final int hintTokens;
  final List<String> ownedCosmetics;
  final List<int> claimedStreakMilestones;
  final List<String> rewardedCompletedCourses;
  final String? lastDailyClaimDate;
  final DateTime? updatedAt;

  const RewardWallet({
    required this.creditsBalance,
    required this.totalCreditsEarned,
    required this.totalCreditsSpent,
    required this.xpBoostLessonsRemaining,
    required this.streakShields,
    required this.hintTokens,
    required this.ownedCosmetics,
    required this.claimedStreakMilestones,
    required this.rewardedCompletedCourses,
    required this.lastDailyClaimDate,
    required this.updatedAt,
  });

  const RewardWallet.initial()
    : creditsBalance = 0,
      totalCreditsEarned = 0,
      totalCreditsSpent = 0,
      xpBoostLessonsRemaining = 0,
      streakShields = 0,
      hintTokens = 0,
      ownedCosmetics = const <String>[],
      claimedStreakMilestones = const <int>[],
      rewardedCompletedCourses = const <String>[],
      lastDailyClaimDate = null,
      updatedAt = null;

  bool get hasActiveXpBoost => xpBoostLessonsRemaining > 0;
  bool get isEmpty =>
      creditsBalance == 0 &&
      totalCreditsEarned == 0 &&
      totalCreditsSpent == 0 &&
      xpBoostLessonsRemaining == 0 &&
      streakShields == 0 &&
      hintTokens == 0 &&
      ownedCosmetics.isEmpty &&
      claimedStreakMilestones.isEmpty &&
      rewardedCompletedCourses.isEmpty &&
      (lastDailyClaimDate == null || lastDailyClaimDate!.isEmpty);

  bool canClaimDaily(String dayKey) => lastDailyClaimDate != dayKey;

  RewardWallet copyWith({
    int? creditsBalance,
    int? totalCreditsEarned,
    int? totalCreditsSpent,
    int? xpBoostLessonsRemaining,
    int? streakShields,
    int? hintTokens,
    List<String>? ownedCosmetics,
    List<int>? claimedStreakMilestones,
    List<String>? rewardedCompletedCourses,
    String? lastDailyClaimDate,
    DateTime? updatedAt,
    bool clearLastDailyClaimDate = false,
  }) {
    return RewardWallet(
      creditsBalance: creditsBalance ?? this.creditsBalance,
      totalCreditsEarned: totalCreditsEarned ?? this.totalCreditsEarned,
      totalCreditsSpent: totalCreditsSpent ?? this.totalCreditsSpent,
      xpBoostLessonsRemaining:
          xpBoostLessonsRemaining ?? this.xpBoostLessonsRemaining,
      streakShields: streakShields ?? this.streakShields,
      hintTokens: hintTokens ?? this.hintTokens,
      ownedCosmetics: ownedCosmetics ?? this.ownedCosmetics,
      claimedStreakMilestones:
          claimedStreakMilestones ?? this.claimedStreakMilestones,
      rewardedCompletedCourses:
          rewardedCompletedCourses ?? this.rewardedCompletedCourses,
      lastDailyClaimDate: clearLastDailyClaimDate
          ? null
          : (lastDailyClaimDate ?? this.lastDailyClaimDate),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory RewardWallet.fromJson(Map<String, dynamic> json) {
    final ownedCosmetics =
        (json['ownedCosmetics'] as List? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList(growable: false);
    final claimedStreakMilestones =
        (json['claimedStreakMilestones'] as List? ?? const <dynamic>[])
            .map((item) => item is num ? item.toInt() : int.tryParse('$item'))
            .whereType<int>()
            .toList(growable: false);
    final rewardedCompletedCourses =
        (json['rewardedCompletedCourses'] as List? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList(growable: false);

    final updatedAtRaw = json['updatedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw is String) {
      updatedAt = DateTime.tryParse(updatedAtRaw);
    }

    return RewardWallet(
      creditsBalance: (json['creditsBalance'] as num?)?.toInt() ?? 0,
      totalCreditsEarned: (json['totalCreditsEarned'] as num?)?.toInt() ?? 0,
      totalCreditsSpent: (json['totalCreditsSpent'] as num?)?.toInt() ?? 0,
      xpBoostLessonsRemaining:
          (json['xpBoostLessonsRemaining'] as num?)?.toInt() ?? 0,
      streakShields: (json['streakShields'] as num?)?.toInt() ?? 0,
      hintTokens: (json['hintTokens'] as num?)?.toInt() ?? 0,
      ownedCosmetics: ownedCosmetics,
      claimedStreakMilestones: claimedStreakMilestones,
      rewardedCompletedCourses: rewardedCompletedCourses,
      lastDailyClaimDate: json['lastDailyClaimDate']?.toString(),
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creditsBalance': creditsBalance,
      'totalCreditsEarned': totalCreditsEarned,
      'totalCreditsSpent': totalCreditsSpent,
      'xpBoostLessonsRemaining': xpBoostLessonsRemaining,
      'streakShields': streakShields,
      'hintTokens': hintTokens,
      'ownedCosmetics': ownedCosmetics,
      'claimedStreakMilestones': claimedStreakMilestones,
      'rewardedCompletedCourses': rewardedCompletedCourses,
      'lastDailyClaimDate': lastDailyClaimDate,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }
}

class RewardTransaction {
  final String id;
  final RewardTransactionType type;
  final int creditsDelta;
  final int xpDelta;
  final String title;
  final String subtitle;
  final DateTime createdAt;

  const RewardTransaction({
    required this.id,
    required this.type,
    required this.creditsDelta,
    required this.xpDelta,
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });

  bool get isSpend => creditsDelta < 0;

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt']?.toString();
    final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
    return RewardTransaction(
      id:
          json['id']?.toString() ??
          'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: rewardTransactionTypeFromString(json['type']?.toString() ?? ''),
      creditsDelta: (json['creditsDelta'] as num?)?.toInt() ?? 0,
      xpDelta: (json['xpDelta'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Reward update',
      subtitle: json['subtitle']?.toString() ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'creditsDelta': creditsDelta,
      'xpDelta': xpDelta,
      'title': title,
      'subtitle': subtitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RewardActionResult {
  final bool applied;
  final bool remoteSynced;
  final int creditsEarned;
  final int xpEarned;
  final String message;
  final RewardWallet wallet;

  const RewardActionResult({
    required this.applied,
    required this.remoteSynced,
    required this.creditsEarned,
    required this.xpEarned,
    required this.message,
    required this.wallet,
  });
}

class RewardPurchaseResult {
  final bool success;
  final bool remoteSynced;
  final String message;
  final RewardWallet wallet;

  const RewardPurchaseResult({
    required this.success,
    required this.remoteSynced,
    required this.message,
    required this.wallet,
  });
}

class RewardShopItemDefinition {
  final String id;
  final int costCredits;
  final int xpBoostLessons;
  final int streakShields;
  final int hintTokens;
  final String? cosmeticId;

  const RewardShopItemDefinition({
    required this.id,
    required this.costCredits,
    this.xpBoostLessons = 0,
    this.streakShields = 0,
    this.hintTokens = 0,
    this.cosmeticId,
  });
}

class RewardShopCatalog {
  static const RewardShopItemDefinition xpBoosterPack =
      RewardShopItemDefinition(
        id: 'xp_booster_pack',
        costCredits: 80,
        xpBoostLessons: 3,
      );

  static const RewardShopItemDefinition streakShield = RewardShopItemDefinition(
    id: 'streak_shield',
    costCredits: 95,
    streakShields: 1,
  );

  static const RewardShopItemDefinition hintPack = RewardShopItemDefinition(
    id: 'hint_pack',
    costCredits: 55,
    hintTokens: 5,
  );

  static const RewardShopItemDefinition neonProfileFrame =
      RewardShopItemDefinition(
        id: 'neon_profile_frame',
        costCredits: 140,
        cosmeticId: 'neon_profile_frame',
      );

  static const List<RewardShopItemDefinition> all = <RewardShopItemDefinition>[
    xpBoosterPack,
    streakShield,
    hintPack,
    neonProfileFrame,
  ];

  static RewardShopItemDefinition? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
