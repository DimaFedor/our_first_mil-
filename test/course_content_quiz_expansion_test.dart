import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/course_content_service.dart';
import 'package:untitled/features/lessons/models/lesson_model.dart';

void main() {
  group('CourseContentService quiz expansion', () {
    test(
      'expands quiz lessons to at least 10 questions without altering originals',
      () {
        for (final courseId in CourseContentService.supportedCourseIds) {
          final rawLessons = _rawLessonsForCourse(courseId);
          final expandedLessons = CourseContentService.getLessonsForCourse(
            courseId,
          );

          expect(
            rawLessons,
            isNotEmpty,
            reason: 'Course $courseId has no lessons',
          );
          expect(expandedLessons.length, rawLessons.length);

          for (final rawLesson in rawLessons) {
            final expandedLesson = expandedLessons.firstWhere(
              (lesson) => lesson.id == rawLesson.id,
            );

            final rawQuiz = rawLesson.quiz;
            final expandedQuiz = expandedLesson.quiz;

            if (rawQuiz == null) {
              expect(expandedQuiz, isNull);
              continue;
            }

            expect(expandedQuiz, isNotNull);
            expect(expandedQuiz!.questions.length, greaterThanOrEqualTo(10));

            final rawQuestions = rawQuiz.questions;
            final preservedQuestions = expandedQuiz.questions
                .take(rawQuestions.length)
                .map((question) => question.question)
                .toList(growable: false);

            expect(
              preservedQuestions,
              rawQuestions
                  .map((question) => question.question)
                  .toList(growable: false),
            );
          }
        }
      },
    );
  });
}

List<Lesson> _rawLessonsForCourse(String courseId) {
  switch (courseId) {
    case 'python':
      return CourseContentService.getPythonLessons();
    case 'javascript':
      return CourseContentService.getJavaScriptLessons();
    case 'cplusplus':
      return CourseContentService.getCPPLessons();
    case 'htmlcss':
      return CourseContentService.getHTMLCSSLessons();
    case 'react':
      return CourseContentService.getReactLessons();
    case 'sql':
      return CourseContentService.getSQLLessons();
    case 'git':
      return CourseContentService.getGitLessons();
    case 'python-intermediate':
      return CourseContentService.getPythonIntermediateLessons();
    case 'cplusplus-intermediate':
      return CourseContentService.getCPPIntermediateLessons();
    case 'htmlcss-intermediate':
      return CourseContentService.getHTMLCSSIntermediateLessons();
    case 'javascript-intermediate':
      return CourseContentService.getJavaScriptIntermediateLessons();
    case 'sql-intermediate':
      return CourseContentService.getSQLIntermediateLessons();
    case 'react-intermediate':
      return CourseContentService.getReactIntermediateLessons();
    default:
      return const <Lesson>[];
  }
}
