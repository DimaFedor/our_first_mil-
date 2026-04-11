import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/course_content_service.dart';
import 'package:untitled/core/services/course_localization_service.dart';
import 'package:untitled/core/services/lesson_localization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unknown course id returns no lessons', () {
    final lessons = CourseContentService.getLessonsForCourse(
      'unknown-course-id',
    );
    expect(lessons, isEmpty);
  });

  test('course localization covers all configured courses', () async {
    final courses = await CourseLocalizationService.getLocalizedCourses(
      const Locale('en'),
    );

    expect(courses, isNotEmpty);
    expect(courses.length, CourseContentService.supportedCourseIds.length);
    expect(
      courses.map((course) => course.id),
      containsAll(CourseContentService.supportedCourseIds),
    );
  });

  test('uk lesson overlay is loaded for python', () async {
    final lessons = await LessonLocalizationService.getLocalizedLessons(
      courseId: 'python',
      uiLocale: const Locale('uk'),
    );

    expect(lessons, isNotEmpty);
    expect(lessons.first.title, 'Ласкаво просимо до Python');
    expect(
      lessons.first.description,
      'Ваші перші кроки у світ програмування на Python',
    );
  });

  test('uk locale gracefully falls back for cplusplus lessons', () async {
    final lessons = await LessonLocalizationService.getLocalizedLessons(
      courseId: 'cplusplus',
      uiLocale: const Locale('uk'),
    );

    expect(lessons, isNotEmpty);
    expect(lessons.first.title, 'Welcome to C++');
  });
}
