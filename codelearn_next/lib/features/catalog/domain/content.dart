import '../../../foundation/json.dart';

class Course {
  final String id;
  final Map<String, String> titles;
  final String icon;
  final String difficulty;
  final int lessonCount;
  final int order;

  Course.fromJson(JsonMap value)
    : id = jsonString(value['id']),
      titles = Map.unmodifiable(
        jsonMap(
          value['titles'],
        ).map((key, value) => MapEntry(key, jsonString(value))),
      ),
      icon = jsonString(value['icon']),
      difficulty = jsonString(value['difficulty']),
      lessonCount = jsonInt(value['lessonCount']),
      order = jsonInt(value['order']);

  String title(String locale) => titles[locale] ?? titles['en'] ?? id;
}

class Lesson {
  final String id;
  final String courseId;
  final String moduleId;
  final String title;
  final String description;
  final String sourceLocale;
  final int version;
  final int xp;
  final List<TheorySlide> slides;
  final List<Question> questions;
  final Challenge? challenge;

  Lesson.fromJson(JsonMap value)
    : id = jsonString(value['id']),
      courseId = jsonString(value['courseId']),
      moduleId = jsonString(value['moduleId']),
      title = jsonString(value['title']),
      description = jsonString(value['description']),
      sourceLocale = jsonString(value['sourceLocale'], 'en'),
      version = jsonInt(value['version'], 1),
      xp = jsonInt(value['xpReward'], 15),
      slides = List.unmodifiable(
        jsonList(
          value['theorySlides'],
        ).map((item) => TheorySlide.fromJson(jsonMap(item))),
      ),
      questions = List.unmodifiable(
        jsonList(
          jsonMap(value['quiz'])['questions'],
        ).map((item) => Question.fromJson(jsonMap(item))),
      ),
      challenge = value['codingChallenge'] is Map
          ? Challenge.fromJson(jsonMap(value['codingChallenge']))
          : null;
}

class TheorySlide {
  final String id;
  final String title;
  final String content;
  final String code;
  final String language;
  TheorySlide.fromJson(JsonMap value)
    : id = jsonString(value['id']),
      title = jsonString(value['title']),
      content = jsonString(value['content']),
      code = jsonString(value['codeSnippet']),
      language = jsonString(value['codeLanguage']);
}

class Question {
  final String id;
  final String prompt;
  final List<String> options;
  final List<String> optionIds;
  final String correctOptionId;
  final String explanation;
  final String type;
  Question.fromJson(JsonMap value)
    : id = jsonString(value['id']),
      prompt = jsonString(value['question']),
      options = List.unmodifiable(
        jsonList(value['options']).map((item) => jsonString(item)),
      ),
      optionIds = List.unmodifiable(
        jsonList(value['optionIds']).map((item) => jsonString(item)),
      ),
      correctOptionId = jsonString(value['correctOptionId']),
      explanation = jsonString(value['explanation']),
      type = jsonString(value['type'], 'multipleChoice');
}

class Challenge {
  final String title;
  final String description;
  final String starterCode;
  final String language;
  final String hint;
  final String solution;
  final List<ExerciseTest> tests;
  Challenge.fromJson(JsonMap value)
    : title = jsonString(value['title']),
      description = jsonString(value['description']),
      starterCode = jsonString(value['starterCode']),
      language = jsonString(value['language']),
      hint = jsonString(value['hint']),
      solution = jsonString(value['solution']),
      tests = List.unmodifiable(
        jsonList(
          value['testCases'],
        ).map((item) => ExerciseTest.fromJson(jsonMap(item))),
      );

  JsonMap toJson() => {
    'language': language,
    'tests': tests.map((item) => item.toJson()).toList(),
    'solution': solution,
  };
}

class ExerciseTest {
  final String input;
  final String expected;
  final bool hidden;
  ExerciseTest.fromJson(JsonMap value)
    : input = jsonString(value['input']),
      expected = jsonString(value['expectedOutput']),
      hidden = jsonBool(value['isHidden']);
  JsonMap toJson() => {
    'input': input,
    'expectedOutput': expected,
    'isHidden': hidden,
  };
}

class ContentLanguage {
  final String code;
  final String name;
  ContentLanguage.fromJson(JsonMap value)
    : code = jsonString(value['code']),
      name = jsonString(value['nativeName']);
}

abstract interface class ContentRepository {
  Future<List<Course>> courses();
  Future<List<Lesson>> lessons(String courseId, String locale);
  Future<List<ContentLanguage>> languages();
}
