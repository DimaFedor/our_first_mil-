import '../../catalog/domain/content.dart';
import '../../practice/data/practice_runner.dart';
import '../../practice/domain/practice_result.dart';
import '../../progress/data/learning_repository.dart';
import '../../progress/domain/learning_data.dart';
import '../domain/learning_session.dart';

class LessonApplication {
  final LearningRepository repository;
  final PracticeRunner runner;
  final String account;
  LessonApplication({
    required this.repository,
    required this.runner,
    required this.account,
  });

  Future<PracticeResult> check(Lesson lesson, String code) async {
    final challenge = lesson.challenge;
    if (challenge == null) return const PracticeResult(passed: true);
    final result = await runner.run({
      'code': code,
      'challenge': challenge.toJson(),
    });
    await repository.recordAttempt(
      account,
      lesson.courseId,
      lesson.id,
      result.passed,
      code: code,
    );
    return result;
  }

  Future<CompletionResult> complete(
    Lesson lesson,
    LearningSession session,
    int courseSize,
  ) => repository.complete(account, lesson, session, courseSize);
}
