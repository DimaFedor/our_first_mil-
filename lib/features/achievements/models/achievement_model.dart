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

  String titleForLocale(String languageCode) {
    if (languageCode == 'uk') {
      return _ukTitles[id] ?? title;
    }
    return title;
  }

  String descriptionForLocale(String languageCode) {
    if (languageCode == 'uk') {
      return _ukDescriptions[id] ?? description;
    }
    return description;
  }

  static const Map<String, String> _ukTitles = <String, String>{
    'first_lesson': 'Перші кроки',
    'five_lessons': 'Гарний старт',
    'ten_lessons': 'Шукач знань',
    'twenty_lessons': 'Ритм навчання',
    'thirty_five_lessons': 'Фокус-ранер',
    'fifty_five_lessons': 'Машина навчання',
    'eighty_lessons': 'Навчальний марафон',
    'one_hundred_twenty_lessons': 'Штурм курсу',
    'streak_3': 'У вогні!',
    'streak_7': 'Воїн тижня',
    'streak_14': 'Титан двох тижнів',
    'streak_21': 'Звичка закріплена',
    'streak_30': 'Майстер місяця',
    'xp_100': 'Колекціонер XP',
    'xp_500': 'Зірка, що сходить',
    'xp_1000': 'Майстер XP',
    'xp_1600': 'Потужний учень',
    'xp_2500': 'Елітний учень',
    'course_1': 'Першопроходець',
    'course_3': 'Мульти-трек учень',
    'course_6': 'Будівельник стеку',
    'course_10': 'Поліглот-кодер',
    'course_14': 'Архітектор навчання',
    'course_18': 'Герой повної програми',
  };

  static const Map<String, String> _ukDescriptions = <String, String>{
    'first_lesson': 'Заверши свій перший урок',
    'five_lessons': 'Заверши 5 уроків',
    'ten_lessons': 'Заверши 10 уроків',
    'twenty_lessons': 'Заверши 20 уроків',
    'thirty_five_lessons': 'Заверши 35 уроків',
    'fifty_five_lessons': 'Заверши 55 уроків',
    'eighty_lessons': 'Заверши 80 уроків',
    'one_hundred_twenty_lessons': 'Заверши 120 уроків',
    'streak_3': 'Підтримуй стрік 3 дні',
    'streak_7': 'Підтримуй стрік 7 днів',
    'streak_14': 'Підтримуй стрік 14 днів',
    'streak_21': 'Підтримуй стрік 21 день',
    'streak_30': 'Підтримуй стрік 30 днів',
    'xp_100': 'Набери 100 XP',
    'xp_500': 'Набери 500 XP',
    'xp_1000': 'Набери 1000 XP',
    'xp_1600': 'Набери 1600 XP',
    'xp_2500': 'Набери 2500 XP',
    'course_1': 'Заверши свій перший курс повністю',
    'course_3': 'Заверши 3 курси',
    'course_6': 'Заверши 6 курсів',
    'course_10': 'Заверши 10 курсів',
    'course_14': 'Заверши 14 курсів',
    'course_18': 'Заверши всі доступні курси',
  };

  static List<Achievement> getAllAchievements() {
    return [
      // Lesson milestones
      const Achievement(
        id: 'first_lesson',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: Icons.school,
        color: Colors.green,
        type: AchievementType.lessonComplete,
        requirement: 1,
        xpReward: 10,
      ),
      const Achievement(
        id: 'five_lessons',
        title: 'Getting Started',
        description: 'Complete 5 lessons',
        icon: Icons.trending_up,
        color: Colors.blue,
        type: AchievementType.lessonComplete,
        requirement: 5,
        xpReward: 18,
      ),
      const Achievement(
        id: 'ten_lessons',
        title: 'Knowledge Seeker',
        description: 'Complete 10 lessons',
        icon: Icons.local_library,
        color: Colors.purple,
        type: AchievementType.lessonComplete,
        requirement: 10,
        xpReward: 28,
      ),
      const Achievement(
        id: 'twenty_lessons',
        title: 'Consistency Builder',
        description: 'Complete 20 lessons',
        icon: Icons.menu_book,
        color: Colors.indigo,
        type: AchievementType.lessonComplete,
        requirement: 20,
        xpReward: 40,
      ),
      const Achievement(
        id: 'thirty_five_lessons',
        title: 'Focus Runner',
        description: 'Complete 35 lessons',
        icon: Icons.run_circle_outlined,
        color: Colors.teal,
        type: AchievementType.lessonComplete,
        requirement: 35,
        xpReward: 55,
      ),
      const Achievement(
        id: 'fifty_five_lessons',
        title: 'Learning Machine',
        description: 'Complete 55 lessons',
        icon: Icons.auto_stories,
        color: Colors.teal,
        type: AchievementType.lessonComplete,
        requirement: 55,
        xpReward: 72,
      ),
      const Achievement(
        id: 'eighty_lessons',
        title: 'Study Marathon',
        description: 'Complete 80 lessons',
        icon: Icons.speed,
        color: Colors.deepPurple,
        type: AchievementType.lessonComplete,
        requirement: 80,
        xpReward: 95,
      ),
      const Achievement(
        id: 'one_hundred_twenty_lessons',
        title: 'Course Crusher',
        description: 'Complete 120 lessons',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
        type: AchievementType.lessonComplete,
        requirement: 120,
        xpReward: 125,
      ),
      // Streak milestones
      const Achievement(
        id: 'streak_3',
        title: 'On Fire!',
        description: 'Maintain a 3-day streak',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        type: AchievementType.streak,
        requirement: 3,
        xpReward: 12,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.whatshot,
        color: Colors.red,
        type: AchievementType.streak,
        requirement: 7,
        xpReward: 24,
      ),
      const Achievement(
        id: 'streak_14',
        title: 'Two-Week Titan',
        description: 'Maintain a 14-day streak',
        icon: Icons.flash_on,
        color: Colors.orange,
        type: AchievementType.streak,
        requirement: 14,
        xpReward: 38,
      ),
      const Achievement(
        id: 'streak_21',
        title: 'Habit Locked',
        description: 'Maintain a 21-day streak',
        icon: Icons.lock_clock,
        color: Colors.deepOrangeAccent,
        type: AchievementType.streak,
        requirement: 21,
        xpReward: 55,
      ),
      const Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        icon: Icons.calendar_month,
        color: Colors.deepOrange,
        type: AchievementType.streak,
        requirement: 30,
        xpReward: 80,
      ),
      // XP milestones
      const Achievement(
        id: 'xp_100',
        title: 'XP Collector',
        description: 'Earn 100 XP',
        icon: Icons.star,
        color: Colors.lightBlue,
        type: AchievementType.xp,
        requirement: 100,
        xpReward: 8,
      ),
      const Achievement(
        id: 'xp_500',
        title: 'Rising Star',
        description: 'Earn 500 XP',
        icon: Icons.star_half,
        color: Colors.cyan,
        type: AchievementType.xp,
        requirement: 500,
        xpReward: 20,
      ),
      const Achievement(
        id: 'xp_1000',
        title: 'XP Master',
        description: 'Earn 1000 XP',
        icon: Icons.stars,
        color: Colors.amber,
        type: AchievementType.xp,
        requirement: 1000,
        xpReward: 35,
      ),
      const Achievement(
        id: 'xp_1600',
        title: 'Power Learner',
        description: 'Earn 1600 XP',
        icon: Icons.auto_awesome,
        color: Colors.indigoAccent,
        type: AchievementType.xp,
        requirement: 1600,
        xpReward: 50,
      ),
      const Achievement(
        id: 'xp_2500',
        title: 'Elite Learner',
        description: 'Earn 2500 XP',
        icon: Icons.emoji_events,
        color: Colors.amberAccent,
        type: AchievementType.xp,
        requirement: 2500,
        xpReward: 70,
      ),
      // Course milestones
      const Achievement(
        id: 'course_1',
        title: 'Pathfinder',
        description: 'Complete your first full course',
        icon: Icons.flag,
        color: Colors.greenAccent,
        type: AchievementType.courseComplete,
        requirement: 1,
        xpReward: 15,
      ),
      const Achievement(
        id: 'course_3',
        title: 'Multi-Track Learner',
        description: 'Complete 3 courses',
        icon: Icons.route,
        color: Colors.lightGreen,
        type: AchievementType.courseComplete,
        requirement: 3,
        xpReward: 25,
      ),
      const Achievement(
        id: 'course_6',
        title: 'Stack Builder',
        description: 'Complete 6 courses',
        icon: Icons.view_module,
        color: Colors.lime,
        type: AchievementType.courseComplete,
        requirement: 6,
        xpReward: 40,
      ),
      const Achievement(
        id: 'course_10',
        title: 'Polyglot Coder',
        description: 'Complete 10 courses',
        icon: Icons.hub,
        color: Colors.orangeAccent,
        type: AchievementType.courseComplete,
        requirement: 10,
        xpReward: 60,
      ),
      const Achievement(
        id: 'course_14',
        title: 'Learning Architect',
        description: 'Complete 14 courses',
        icon: Icons.architecture,
        color: Colors.deepOrangeAccent,
        type: AchievementType.courseComplete,
        requirement: 14,
        xpReward: 85,
      ),
      const Achievement(
        id: 'course_18',
        title: 'Full Curriculum Hero',
        description: 'Complete all available courses',
        icon: Icons.verified,
        color: Colors.amber,
        type: AchievementType.courseComplete,
        requirement: 18,
        xpReward: 120,
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
