import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementType { lessonComplete, courseComplete, streak, xp, special }

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int requirement;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requirement,
    this.xpReward = 50,
  });

  static List<Achievement> getAllAchievements() {
    return [
      const Achievement(
        id: 'first_lesson',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: Icons.school,
        color: Colors.green,
        type: AchievementType.lessonComplete,
        requirement: 1,
        xpReward: 25,
      ),
      const Achievement(
        id: 'five_lessons',
        title: 'Getting Started',
        description: 'Complete 5 lessons',
        icon: Icons.trending_up,
        color: Colors.blue,
        type: AchievementType.lessonComplete,
        requirement: 5,
        xpReward: 50,
      ),
      const Achievement(
        id: 'ten_lessons',
        title: 'Knowledge Seeker',
        description: 'Complete 10 lessons',
        icon: Icons.local_library,
        color: Colors.purple,
        type: AchievementType.lessonComplete,
        requirement: 10,
        xpReward: 100,
      ),
      const Achievement(
        id: 'streak_3',
        title: 'On Fire!',
        description: 'Maintain a 3-day streak',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        type: AchievementType.streak,
        requirement: 3,
        xpReward: 30,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.whatshot,
        color: Colors.red,
        type: AchievementType.streak,
        requirement: 7,
        xpReward: 100,
      ),
      const Achievement(
        id: 'xp_100',
        title: 'XP Collector',
        description: 'Earn 100 XP',
        icon: Icons.star,
        color: Colors.lightBlue,
        type: AchievementType.xp,
        requirement: 100,
        xpReward: 25,
      ),
      const Achievement(
        id: 'xp_500',
        title: 'Rising Star',
        description: 'Earn 500 XP',
        icon: Icons.star_half,
        color: Colors.cyan,
        type: AchievementType.xp,
        requirement: 500,
        xpReward: 50,
      ),
      const Achievement(
        id: 'xp_1000',
        title: 'XP Master',
        description: 'Earn 1000 XP',
        icon: Icons.stars,
        color: Colors.amber,
        type: AchievementType.xp,
        requirement: 1000,
        xpReward: 100,
      ),
    ];
  }
}

class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;

  UserAchievement({required this.achievementId, required this.unlockedAt});

  factory UserAchievement.fromJson(
    Map<String, dynamic> json, {
    String? fallbackAchievementId,
  }) {
    final rawUnlockedAt = json['unlockedAt'];
    DateTime parsedUnlockedAt;

    if (rawUnlockedAt is Timestamp) {
      parsedUnlockedAt = rawUnlockedAt.toDate();
    } else if (rawUnlockedAt is String) {
      parsedUnlockedAt = DateTime.tryParse(rawUnlockedAt) ?? DateTime.now();
    } else if (rawUnlockedAt is int) {
      parsedUnlockedAt = DateTime.fromMillisecondsSinceEpoch(rawUnlockedAt);
    } else {
      parsedUnlockedAt = DateTime.now();
    }

    return UserAchievement(
      achievementId:
          (json['achievementId'] as String?) ?? fallbackAchievementId ?? '',
      unlockedAt: parsedUnlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'unlockedAt': unlockedAt.toIso8601String(),
  };
}
