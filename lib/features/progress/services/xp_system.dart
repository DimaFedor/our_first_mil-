import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class LevelInfo {
  final int level;
  final int currentXP;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final double progress;
  final String title;
  final String badge;

  const LevelInfo({
    required this.level,
    required this.currentXP,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.progress,
    required this.title,
    required this.badge,
  });

  int get xpNeededForNextLevel => xpForNextLevel - currentXP;
  bool get isMaxLevel => level >= 100;
}

class XPSystem {
  // XP required to reach each level (exponential growth)
  static int xpForLevel(int level) {
    if (level <= 0) return 0;
    if (level == 1) return 0;
    // Level 2: 50 XP, Level 3: 150, Level 4: 300, etc.
    return (50 * level * (level - 1) / 2).round();
  }

  // Get level from total XP
  static int levelFromXP(int totalXP) {
    int level = 1;
    while (xpForLevel(level + 1) <= totalXP) {
      level++;
      if (level >= 100) break;
    }
    return level;
  }

  // Get detailed level info
  static LevelInfo getLevelInfo(int totalXP) {
    final level = levelFromXP(totalXP);
    final xpForCurrent = xpForLevel(level);
    final xpForNext = xpForLevel(level + 1);
    final xpInCurrentLevel = totalXP - xpForCurrent;
    final xpNeededForLevel = xpForNext - xpForCurrent;
    final progress = level >= 100 ? 1.0 : xpInCurrentLevel / xpNeededForLevel;

    return LevelInfo(
      level: level,
      currentXP: totalXP,
      xpForCurrentLevel: xpForCurrent,
      xpForNextLevel: xpForNext,
      progress: progress.clamp(0.0, 1.0),
      title: getTitleForLevel(level),
      badge: getBadgeForLevel(level),
    );
  }

  static String getTitleForLevel(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Apprentice';
    if (level < 15) return 'Student';
    if (level < 20) return 'Coder';
    if (level < 30) return 'Developer';
    if (level < 40) return 'Senior Developer';
    if (level < 50) return 'Expert';
    if (level < 60) return 'Master';
    if (level < 75) return 'Guru';
    if (level < 90) return 'Legend';
    return 'Code Wizard';
  }

  static String getBadgeForLevel(int level) {
    if (level < 5) return '🌱';
    if (level < 10) return '🌿';
    if (level < 15) return '🌳';
    if (level < 20) return '💻';
    if (level < 30) return '⭐';
    if (level < 40) return '🌟';
    if (level < 50) return '💎';
    if (level < 60) return '👑';
    if (level < 75) return '🏆';
    if (level < 90) return '🔥';
    return '🧙‍♂️';
  }

  // XP rewards for different actions
  static const int lessonCompleteXP = 20;
  static const int quizPerfectXP = 10;
  static const int codeChallengeXP = 15;
  static const int dailyStreakXP = 5;
  static const int weekStreakBonusXP = 25;
  static const int monthStreakBonusXP = 100;
}

// Providers
final userXPProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserUidProvider);
  if (userId == null) return 0;
  
  final userData = await ref.watch(userDataProvider(userId).future);
  return userData?.totalXP ?? 0;
});

final levelInfoProvider = Provider<AsyncValue<LevelInfo>>((ref) {
  final xpAsync = ref.watch(userXPProvider);
  return xpAsync.when(
    data: (xp) => AsyncValue.data(XPSystem.getLevelInfo(xp)),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Check if user leveled up (compare before and after XP)
bool didLevelUp(int oldXP, int newXP) {
  return XPSystem.levelFromXP(oldXP) < XPSystem.levelFromXP(newXP);
}

// XP breakdown for a lesson
class LessonXPBreakdown {
  final int baseXP;
  final int quizBonus;
  final int streakBonus;
  final int total;

  const LessonXPBreakdown({
    required this.baseXP,
    required this.quizBonus,
    required this.streakBonus,
    required this.total,
  });

  factory LessonXPBreakdown.calculate({
    required int lessonXP,
    required int correctAnswers,
    required int totalQuestions,
    required int currentStreak,
  }) {
    final base = lessonXP;
    
    // Bonus for perfect quiz (all correct)
    final quizBonus = correctAnswers == totalQuestions && totalQuestions > 0
        ? XPSystem.quizPerfectXP
        : 0;
    
    // Streak bonuses
    int streakBonus = 0;
    if (currentStreak > 0) {
      streakBonus += XPSystem.dailyStreakXP;
      if (currentStreak % 7 == 0) {
        streakBonus += XPSystem.weekStreakBonusXP;
      }
      if (currentStreak % 30 == 0) {
        streakBonus += XPSystem.monthStreakBonusXP;
      }
    }

    return LessonXPBreakdown(
      baseXP: base,
      quizBonus: quizBonus,
      streakBonus: streakBonus,
      total: base + quizBonus + streakBonus,
    );
  }
}
