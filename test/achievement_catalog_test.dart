import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/course_content_service.dart';
import 'package:untitled/features/achievements/models/achievement_model.dart';

void main() {
  group('Achievement catalog', () {
    test('contains expanded and balanced milestones', () {
      final all = Achievement.getAllAchievements();

      expect(all.length, greaterThanOrEqualTo(24));

      final lessonCount = all
          .where((item) => item.type == AchievementType.lessonComplete)
          .length;
      final streakCount = all
          .where((item) => item.type == AchievementType.streak)
          .length;
      final xpCount = all
          .where((item) => item.type == AchievementType.xp)
          .length;
      final courseCount = all
          .where((item) => item.type == AchievementType.courseComplete)
          .length;

      expect(lessonCount, greaterThanOrEqualTo(8));
      expect(streakCount, greaterThanOrEqualTo(5));
      expect(xpCount, greaterThanOrEqualTo(5));
      expect(courseCount, greaterThanOrEqualTo(6));
    });

    test('uses unique ids and valid values', () {
      final all = Achievement.getAllAchievements();
      final ids = all.map((item) => item.id).toList(growable: false);

      expect(ids.toSet().length, ids.length);
      expect(all.every((item) => item.requirement > 0), isTrue);
      expect(all.every((item) => item.xpReward > 0), isTrue);
      final maxReward = all
          .map((item) => item.xpReward)
          .reduce((current, next) => current > next ? current : next);
      expect(maxReward, lessThanOrEqualTo(130));
    });

    test('provides ukrainian copy for all achievements', () {
      final all = Achievement.getAllAchievements();
      for (final item in all) {
        expect(item.titleForLocale('uk').trim(), isNotEmpty);
        expect(item.descriptionForLocale('uk').trim(), isNotEmpty);
        expect(item.titleForLocale('uk'), isNot(equals(item.title)));
        expect(
          item.descriptionForLocale('uk'),
          isNot(equals(item.description)),
        );
      }
    });

    test('keeps milestone progression ordered by requirement', () {
      final all = Achievement.getAllAchievements();
      final trackedTypes = <AchievementType>[
        AchievementType.lessonComplete,
        AchievementType.courseComplete,
        AchievementType.streak,
        AchievementType.xp,
      ];

      for (final type in trackedTypes) {
        final requirements = all
            .where((item) => item.type == type)
            .map((item) => item.requirement)
            .toList(growable: false);
        final sorted = requirements.toList()..sort();
        expect(
          requirements,
          sorted,
          reason: 'Milestones for $type are unordered.',
        );
      }
    });

    test('stays within real course and lesson limits', () {
      final all = Achievement.getAllAchievements();
      final totalLessons = CourseContentService.supportedCourseIds
          .map((courseId) => CourseContentService.getLessonsForCourse(courseId))
          .fold<int>(0, (sum, lessons) => sum + lessons.length);
      final totalCourses = CourseContentService.supportedCourseIds.length;

      final maxLessonRequirement = all
          .where((item) => item.type == AchievementType.lessonComplete)
          .map((item) => item.requirement)
          .reduce((current, next) => current > next ? current : next);
      final maxCourseRequirement = all
          .where((item) => item.type == AchievementType.courseComplete)
          .map((item) => item.requirement)
          .reduce((current, next) => current > next ? current : next);

      expect(maxLessonRequirement, lessThanOrEqualTo(totalLessons));
      expect(maxCourseRequirement, lessThanOrEqualTo(totalCourses));
    });
  });
}
