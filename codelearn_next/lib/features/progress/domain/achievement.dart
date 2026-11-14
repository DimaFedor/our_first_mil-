enum AchievementKind { lessons, streak, xp, courses }

class AchievementDefinition {
  final String id;
  final AchievementKind kind;
  final int requirement;
  const AchievementDefinition(this.id, this.kind, this.requirement);
  bool isUnlocked({
    required int lessons,
    required int streak,
    required int xp,
    required int courses,
  }) =>
      switch (kind) {
        AchievementKind.lessons => lessons,
        AchievementKind.streak => streak,
        AchievementKind.xp => xp,
        AchievementKind.courses => courses,
      } >=
      requirement;
}

const achievementDefinitions = [
  AchievementDefinition('firstLesson', AchievementKind.lessons, 1),
  AchievementDefinition('fiveLessons', AchievementKind.lessons, 5),
  AchievementDefinition('tenLessons', AchievementKind.lessons, 10),
  AchievementDefinition('twentyLessons', AchievementKind.lessons, 20),
  AchievementDefinition('thirtyFiveLessons', AchievementKind.lessons, 35),
  AchievementDefinition('fiftyFiveLessons', AchievementKind.lessons, 55),
  AchievementDefinition('eightyLessons', AchievementKind.lessons, 80),
  AchievementDefinition(
    'oneHundredTwentyLessons',
    AchievementKind.lessons,
    120,
  ),
  AchievementDefinition('threeDayStreak', AchievementKind.streak, 3),
  AchievementDefinition('weekStreak', AchievementKind.streak, 7),
  AchievementDefinition('twoWeekStreak', AchievementKind.streak, 14),
  AchievementDefinition('threeWeekStreak', AchievementKind.streak, 21),
  AchievementDefinition('monthStreak', AchievementKind.streak, 30),
  AchievementDefinition('xp100', AchievementKind.xp, 100),
  AchievementDefinition('xp500', AchievementKind.xp, 500),
  AchievementDefinition('xpMilestone', AchievementKind.xp, 1000),
  AchievementDefinition('xp1600', AchievementKind.xp, 1600),
  AchievementDefinition('xp2500', AchievementKind.xp, 2500),
  AchievementDefinition('firstCourse', AchievementKind.courses, 1),
  AchievementDefinition('threeCourses', AchievementKind.courses, 3),
  AchievementDefinition('sixCourses', AchievementKind.courses, 6),
  AchievementDefinition('tenCourses', AchievementKind.courses, 10),
  AchievementDefinition('fourteenCourses', AchievementKind.courses, 14),
  AchievementDefinition('allCourses', AchievementKind.courses, 18),
];
