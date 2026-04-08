enum QuizQuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  codeOutput,
}

class Lesson {
  final String id;
  final String courseId;
  final String moduleId;
  final String title;
  final String description;
  final List<TheorySlide> theorySlides;
  final Quiz? quiz;
  final CodingChallenge? codingChallenge;
  final int xpReward;
  final int order;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.theorySlides,
    this.quiz,
    this.codingChallenge,
    this.xpReward = 10,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'theorySlides': theorySlides.map((s) => s.toJson()).toList(),
        'quiz': quiz?.toJson(),
        'codingChallenge': codingChallenge?.toJson(),
        'xpReward': xpReward,
        'order': order,
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        courseId: json['courseId'],
        moduleId: json['moduleId'] ?? '',
        title: json['title'],
        description: json['description'],
        theorySlides: (json['theorySlides'] as List)
            .map((s) => TheorySlide.fromJson(s))
            .toList(),
        quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
        codingChallenge: json['codingChallenge'] != null
            ? CodingChallenge.fromJson(json['codingChallenge'])
            : null,
        xpReward: json['xpReward'] ?? 10,
        order: json['order'] ?? 0,
      );
}

class TheorySlide {
  final String title;
  final String content;
  final String? codeSnippet;
  final String? codeLanguage;
  final String? imageUrl;
  final String? lottieUrl;
  final int order;

  const TheorySlide({
    required this.title,
    required this.content,
    this.codeSnippet,
    this.codeLanguage,
    this.imageUrl,
    this.lottieUrl,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'codeSnippet': codeSnippet,
        'codeLanguage': codeLanguage,
        'imageUrl': imageUrl,
        'lottieUrl': lottieUrl,
        'order': order,
      };

  factory TheorySlide.fromJson(Map<String, dynamic> json) => TheorySlide(
        title: json['title'],
        content: json['content'],
        codeSnippet: json['codeSnippet'],
        codeLanguage: json['codeLanguage'],
        imageUrl: json['imageUrl'],
        lottieUrl: json['lottieUrl'],
        order: json['order'] ?? 0,
      );
}

class Quiz {
  final List<QuizQuestion> questions;
  final int xpReward;

  const Quiz({
    required this.questions,
    this.xpReward = 5,
  });

  Map<String, dynamic> toJson() => {
        'questions': questions.map((q) => q.toJson()).toList(),
        'xpReward': xpReward,
      };

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        questions: (json['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList(),
        xpReward: json['xpReward'] ?? 5,
      );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final QuizQuestionType type;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.type = QuizQuestionType.multipleChoice,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'explanation': explanation,
        'type': type.name,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'],
        options: List<String>.from(json['options']),
        correctAnswerIndex: json['correctAnswerIndex'],
        explanation: json['explanation'],
        type: QuizQuestionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => QuizQuestionType.multipleChoice,
        ),
      );
}

class CodingChallenge {
  final String title;
  final String description;
  final String starterCode;
  final String language;
  final List<TestCase> testCases;
  final String? hint;
  final String? solution;
  final int xpReward;

  const CodingChallenge({
    required this.title,
    required this.description,
    required this.starterCode,
    required this.language,
    required this.testCases,
    this.hint,
    this.solution,
    this.xpReward = 15,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'starterCode': starterCode,
        'language': language,
        'testCases': testCases.map((t) => t.toJson()).toList(),
        'hint': hint,
        'solution': solution,
        'xpReward': xpReward,
      };

  factory CodingChallenge.fromJson(Map<String, dynamic> json) =>
      CodingChallenge(
        title: json['title'],
        description: json['description'],
        starterCode: json['starterCode'],
        language: json['language'],
        testCases: (json['testCases'] as List)
            .map((t) => TestCase.fromJson(t))
            .toList(),
        hint: json['hint'],
        solution: json['solution'],
        xpReward: json['xpReward'] ?? 15,
      );
}

class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  const TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'input': input,
        'expectedOutput': expectedOutput,
        'isHidden': isHidden,
      };

  factory TestCase.fromJson(Map<String, dynamic> json) => TestCase(
        input: json['input'],
        expectedOutput: json['expectedOutput'],
        isHidden: json['isHidden'] ?? false,
      );
}
