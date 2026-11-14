import '../../../foundation/json.dart';
import '../../catalog/domain/content.dart';

enum LearningStage { theory, quiz, practice, complete }

class LearningSession {
  final String lessonId;
  final int contentVersion;
  final LearningStage stage;
  final int slideIndex;
  final Map<String, String> answers;
  final String code;
  final bool practicePassed;
  final bool hintRevealed;

  LearningSession({
    required this.lessonId,
    required this.contentVersion,
    this.stage = LearningStage.theory,
    this.slideIndex = 0,
    Map<String, String> answers = const {},
    this.code = '',
    this.practicePassed = false,
    this.hintRevealed = false,
  }) : answers = Map.unmodifiable(answers);

  factory LearningSession.fromJson(JsonMap value) => LearningSession(
    lessonId: jsonString(value['lessonId']),
    contentVersion: jsonInt(value['contentVersion'], 1),
    stage: LearningStage.values.firstWhere(
      (item) => item.name == value['stage'],
      orElse: () => LearningStage.theory,
    ),
    slideIndex: jsonInt(value['slideIndex']),
    answers: jsonMap(
      value['answers'],
    ).map((key, value) => MapEntry(key, jsonString(value))),
    code: jsonString(value['code']),
    practicePassed: jsonBool(value['practicePassed']),
    hintRevealed: jsonBool(value['hintRevealed']),
  );

  LearningSession copyWith({
    LearningStage? stage,
    int? slideIndex,
    Map<String, String>? answers,
    String? code,
    bool? practicePassed,
    bool? hintRevealed,
  }) => LearningSession(
    lessonId: lessonId,
    contentVersion: contentVersion,
    stage: stage ?? this.stage,
    slideIndex: slideIndex ?? this.slideIndex,
    answers: answers ?? this.answers,
    code: code ?? this.code,
    practicePassed: practicePassed ?? this.practicePassed,
    hintRevealed: hintRevealed ?? this.hintRevealed,
  );

  int correctAnswers(Lesson lesson) => lesson.questions
      .where((item) => answers[item.id] == item.correctOptionId)
      .length;
  bool quizPassed(Lesson lesson) =>
      lesson.questions.isEmpty ||
      (answers.length >= lesson.questions.length &&
          correctAnswers(lesson) * 100 >= lesson.questions.length * 60);
  bool canComplete(Lesson lesson) =>
      quizPassed(lesson) && (lesson.challenge == null || practicePassed);
  JsonMap toJson() => {
    'lessonId': lessonId,
    'contentVersion': contentVersion,
    'stage': stage.name,
    'slideIndex': slideIndex,
    'answers': answers,
    'code': code,
    'practicePassed': practicePassed,
    'hintRevealed': hintRevealed,
  };
}
