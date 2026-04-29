import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/lessons/models/lesson_model.dart';
import '../l10n/language_catalog.dart';
import '../l10n/locale_provider.dart';
import 'course_content_service.dart';
import 'runtime_translation_service.dart';

final lessonLanguageOverrideProvider = StateProvider<String?>((ref) {
  return null;
});

final localizedCourseLessonsProvider =
    FutureProvider.family<List<Lesson>, String>((ref, courseId) async {
      final uiLocale = ref.watch(localeProvider);
      final forcedLanguageCode = ref.watch(lessonLanguageOverrideProvider);

      return LessonLocalizationService.getLocalizedLessons(
        courseId: courseId,
        uiLocale: uiLocale,
        forcedLanguageCode: forcedLanguageCode,
      );
    });

class LessonLocalizationService {
  static const String _fallbackLanguageCode = 'en';
  static const String _assetsRoot = 'assets/lessons';

  static final Map<String, Map<String, Map<String, dynamic>>>
  _courseTranslationCache = {};
  static final Map<String, List<Lesson>> _localizedLessonsCache = {};

  static Future<List<Lesson>> getLocalizedLessons({
    required String courseId,
    required Locale uiLocale,
    String? forcedLanguageCode,
    bool allowRuntimeTranslation = true,
  }) async {
    final baseLessons = CourseContentService.getLessonsForCourse(courseId);
    if (baseLessons.isEmpty) {
      return const <Lesson>[];
    }

    final languageCandidates = _buildLanguageCandidates(
      uiLocale: uiLocale,
      forcedLanguageCode: forcedLanguageCode,
    );

    final primaryLanguageCode = _resolvePrimaryLanguageCode(languageCandidates);
    final localizedCacheKey = '$primaryLanguageCode|$courseId';
    final cachedLessons = _localizedLessonsCache[localizedCacheKey];
    if (cachedLessons != null) {
      return cachedLessons;
    }

    final mergedTranslations = <String, Map<String, dynamic>>{};

    for (final languageCode in languageCandidates) {
      if (languageCode == _fallbackLanguageCode) {
        continue;
      }

      final translationsByLesson = await _loadTranslationsForCourseLanguage(
        courseId: courseId,
        languageCode: languageCode,
      );

      if (translationsByLesson.isEmpty) {
        continue;
      }

      for (final entry in translationsByLesson.entries) {
        final existing = mergedTranslations[entry.key];
        mergedTranslations[entry.key] = existing == null
            ? Map<String, dynamic>.from(entry.value)
            : _mergeMaps(existing, entry.value);
      }
    }

    final hasFullOverlayForCourse = _hasComprehensiveOverlayForCourse(
      baseLessons: baseLessons,
      mergedTranslations: mergedTranslations,
    );

    var localizedLessons = baseLessons;
    final shouldAttemptRuntimeAutoTranslation =
        allowRuntimeTranslation &&
        primaryLanguageCode != _fallbackLanguageCode &&
        !hasFullOverlayForCourse;
    if (shouldAttemptRuntimeAutoTranslation) {
      try {
        localizedLessons = await _autoTranslateLessons(
          lessons: localizedLessons,
          targetLanguageCode: primaryLanguageCode,
        ).timeout(
          const Duration(seconds: 45),
          onTimeout: () {
            debugPrint(
              'Auto-translation timed out for "$courseId" ($primaryLanguageCode). Using base lessons.',
            );
            return baseLessons;
          },
        );
      } catch (error) {
        debugPrint(
          'Runtime lesson translation skipped for "$courseId" ($primaryLanguageCode): $error',
        );
      }
    }

    if (mergedTranslations.isNotEmpty) {
      localizedLessons = List<Lesson>.unmodifiable(
        localizedLessons.map(
          (lesson) =>
              _applyLessonTranslation(lesson, mergedTranslations[lesson.id]),
        ),
      );
    }

    final immutableLessons = List<Lesson>.unmodifiable(localizedLessons);
    final shouldCacheLessons =
        primaryLanguageCode == _fallbackLanguageCode ||
        mergedTranslations.isNotEmpty ||
        _hasMeaningfulLocalization(
          baseLessons: baseLessons,
          localizedLessons: immutableLessons,
        );
    if (shouldCacheLessons) {
      _localizedLessonsCache[localizedCacheKey] = immutableLessons;
    }
    return immutableLessons;
  }

  static List<String> _buildLanguageCandidates({
    required Locale uiLocale,
    String? forcedLanguageCode,
  }) {
    final normalizedLanguageCode =
        forcedLanguageCode != null && forcedLanguageCode.trim().isNotEmpty
        ? _normalizeLanguageCode(forcedLanguageCode)
        : _normalizeLanguageCode(localeToLanguageTag(uiLocale));

    final parts = normalizedLanguageCode
        .split('-')
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return <String>[_fallbackLanguageCode];
    }

    final candidates = <String>[parts.first];
    if (parts.length > 1) {
      candidates.add(parts.join('-'));
    }

    return candidates.toSet().toList(growable: false);
  }

  static String _normalizeLanguageCode(String rawCode) {
    return rawCode.trim().toLowerCase().replaceAll('_', '-');
  }

  static String _resolvePrimaryLanguageCode(List<String> languageCandidates) {
    if (languageCandidates.isEmpty) {
      return _fallbackLanguageCode;
    }

    final firstCandidate = _normalizeLanguageCode(languageCandidates.first);
    final segments = firstCandidate.split('-').where((part) => part.isNotEmpty);
    if (segments.isEmpty) {
      return _fallbackLanguageCode;
    }

    return segments.first;
  }

  static Future<Map<String, Map<String, dynamic>>>
  _loadTranslationsForCourseLanguage({
    required String courseId,
    required String languageCode,
  }) async {
    final cacheKey = '$languageCode|$courseId';
    final cached = _courseTranslationCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final path = '$_assetsRoot/$languageCode/$courseId.json';

    try {
      final rawJson = await rootBundle.loadString(path);
      final decoded = jsonDecode(rawJson);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('Lesson translation file is not a JSON object: $path');
        const emptyTranslations = <String, Map<String, dynamic>>{};
        _courseTranslationCache[cacheKey] = emptyTranslations;
        return emptyTranslations;
      }

      final declaredCourseId = _readString(decoded, 'courseId');
      if (declaredCourseId != null && declaredCourseId != courseId) {
        debugPrint(
          'Lesson translation file $path has mismatched courseId "$declaredCourseId".',
        );
      }

      final translations = <String, Map<String, dynamic>>{};
      final rawLessons = decoded['lessons'];
      if (rawLessons is List) {
        for (final item in rawLessons) {
          final lessonMap = _asStringMap(item);
          if (lessonMap == null) {
            continue;
          }

          final lessonId = _readString(lessonMap, 'id');
          if (lessonId == null || lessonId.isEmpty) {
            continue;
          }

          translations[lessonId] = lessonMap;
        }
      }

      final immutableTranslations =
          Map<String, Map<String, dynamic>>.unmodifiable(translations);
      _courseTranslationCache[cacheKey] = immutableTranslations;
      return immutableTranslations;
    } on FlutterError {
      const emptyTranslations = <String, Map<String, dynamic>>{};
      _courseTranslationCache[cacheKey] = emptyTranslations;
      return emptyTranslations;
    } on FormatException catch (error) {
      debugPrint('Invalid lesson translation JSON in $path: $error');
      const emptyTranslations = <String, Map<String, dynamic>>{};
      _courseTranslationCache[cacheKey] = emptyTranslations;
      return emptyTranslations;
    }
  }

  static Lesson _applyLessonTranslation(
    Lesson baseLesson,
    Map<String, dynamic>? translation,
  ) {
    if (translation == null) {
      return baseLesson;
    }

    return Lesson(
      id: baseLesson.id,
      courseId: baseLesson.courseId,
      moduleId: baseLesson.moduleId,
      title: _readString(translation, 'title') ?? baseLesson.title,
      description:
          _readString(translation, 'description') ?? baseLesson.description,
      theorySlides: _applyTheorySlideTranslations(
        baseSlides: baseLesson.theorySlides,
        rawSlides: translation['theorySlides'],
      ),
      quiz: _applyQuizTranslation(
        baseQuiz: baseLesson.quiz,
        rawQuiz: translation['quiz'],
      ),
      codingChallenge: _applyCodingChallengeTranslation(
        baseChallenge: baseLesson.codingChallenge,
        rawChallenge: translation['codingChallenge'],
      ),
      xpReward: baseLesson.xpReward,
      order: baseLesson.order,
    );
  }

  static List<TheorySlide> _applyTheorySlideTranslations({
    required List<TheorySlide> baseSlides,
    required dynamic rawSlides,
  }) {
    if (rawSlides is! List) {
      return baseSlides;
    }

    return List<TheorySlide>.generate(baseSlides.length, (index) {
      final baseSlide = baseSlides[index];
      final translation = index < rawSlides.length
          ? _asStringMap(rawSlides[index])
          : null;

      if (translation == null) {
        return baseSlide;
      }

      return TheorySlide(
        title: _readString(translation, 'title') ?? baseSlide.title,
        content: _readString(translation, 'content') ?? baseSlide.content,
        codeSnippet: baseSlide.codeSnippet,
        codeLanguage: baseSlide.codeLanguage,
        imageUrl: baseSlide.imageUrl,
        lottieUrl: baseSlide.lottieUrl,
        order: baseSlide.order,
      );
    });
  }

  static Quiz? _applyQuizTranslation({
    required Quiz? baseQuiz,
    required dynamic rawQuiz,
  }) {
    if (baseQuiz == null) {
      return null;
    }

    final quizTranslation = _asStringMap(rawQuiz);
    if (quizTranslation == null) {
      return baseQuiz;
    }

    return Quiz(
      questions: _applyQuizQuestionTranslations(
        baseQuestions: baseQuiz.questions,
        rawQuestions: quizTranslation['questions'],
      ),
      xpReward: baseQuiz.xpReward,
    );
  }

  static List<QuizQuestion> _applyQuizQuestionTranslations({
    required List<QuizQuestion> baseQuestions,
    required dynamic rawQuestions,
  }) {
    if (rawQuestions is! List) {
      return baseQuestions;
    }

    return List<QuizQuestion>.generate(baseQuestions.length, (index) {
      final baseQuestion = baseQuestions[index];
      final translation = index < rawQuestions.length
          ? _asStringMap(rawQuestions[index])
          : null;

      if (translation == null) {
        return baseQuestion;
      }

      return QuizQuestion(
        question: _readString(translation, 'question') ?? baseQuestion.question,
        options: _applyQuizOptions(
          baseOptions: baseQuestion.options,
          rawOptions: translation['options'],
        ),
        correctAnswerIndex: baseQuestion.correctAnswerIndex,
        explanation:
            _readString(translation, 'explanation') ?? baseQuestion.explanation,
        type: baseQuestion.type,
      );
    });
  }

  static List<String> _applyQuizOptions({
    required List<String> baseOptions,
    required dynamic rawOptions,
  }) {
    if (rawOptions is! List) {
      return baseOptions;
    }

    return List<String>.generate(baseOptions.length, (index) {
      if (index >= rawOptions.length) {
        return baseOptions[index];
      }

      final translated = rawOptions[index];
      if (translated is String && translated.trim().isNotEmpty) {
        return translated;
      }

      return baseOptions[index];
    });
  }

  static CodingChallenge? _applyCodingChallengeTranslation({
    required CodingChallenge? baseChallenge,
    required dynamic rawChallenge,
  }) {
    if (baseChallenge == null) {
      return null;
    }

    final challengeTranslation = _asStringMap(rawChallenge);
    if (challengeTranslation == null) {
      return baseChallenge;
    }

    return CodingChallenge(
      title: _readString(challengeTranslation, 'title') ?? baseChallenge.title,
      description:
          _readString(challengeTranslation, 'description') ??
          baseChallenge.description,
      starterCode: baseChallenge.starterCode,
      language: baseChallenge.language,
      testCases: baseChallenge.testCases,
      hint: _readString(challengeTranslation, 'hint') ?? baseChallenge.hint,
      solution: baseChallenge.solution,
      xpReward: baseChallenge.xpReward,
    );
  }

  static Future<List<Lesson>> _autoTranslateLessons({
    required List<Lesson> lessons,
    required String targetLanguageCode,
  }) async {
    final translatedLessons = await Future.wait(
      lessons.map(
        (lesson) => _autoTranslateLesson(
          lesson: lesson,
          targetLanguageCode: targetLanguageCode,
        ),
      ),
    );
    return List<Lesson>.unmodifiable(translatedLessons);
  }

  static Future<Lesson> _autoTranslateLesson({
    required Lesson lesson,
    required String targetLanguageCode,
  }) async {
    final translatedCoreFuture = _translateBatch(<String>[
      lesson.title,
      lesson.description,
    ], targetLanguageCode);
    final translatedSlidesFuture = _autoTranslateTheorySlides(
      slides: lesson.theorySlides,
      targetLanguageCode: targetLanguageCode,
    );
    final translatedQuizFuture = _autoTranslateQuiz(
      quiz: lesson.quiz,
      targetLanguageCode: targetLanguageCode,
    );
    final translatedChallengeFuture = _autoTranslateCodingChallenge(
      challenge: lesson.codingChallenge,
      targetLanguageCode: targetLanguageCode,
    );
    final translatedCore = await translatedCoreFuture;

    return Lesson(
      id: lesson.id,
      courseId: lesson.courseId,
      moduleId: lesson.moduleId,
      title: translatedCore[0],
      description: translatedCore[1],
      theorySlides: await translatedSlidesFuture,
      quiz: await translatedQuizFuture,
      codingChallenge: await translatedChallengeFuture,
      xpReward: lesson.xpReward,
      order: lesson.order,
    );
  }

  static Future<List<TheorySlide>> _autoTranslateTheorySlides({
    required List<TheorySlide> slides,
    required String targetLanguageCode,
  }) async {
    if (slides.isEmpty) {
      return const <TheorySlide>[];
    }

    final sourceTexts = <String>[
      for (final slide in slides) ...<String>[slide.title, slide.content],
    ];
    final translatedTexts = await _translateBatch(
      sourceTexts,
      targetLanguageCode,
    );

    var cursor = 0;
    final translatedSlides = slides
        .map((slide) {
          final translatedTitle = translatedTexts[cursor++];
          final translatedContent = translatedTexts[cursor++];
          return TheorySlide(
            title: translatedTitle,
            content: translatedContent,
            codeSnippet: slide.codeSnippet,
            codeLanguage: slide.codeLanguage,
            imageUrl: slide.imageUrl,
            lottieUrl: slide.lottieUrl,
            order: slide.order,
          );
        })
        .toList(growable: false);

    return List<TheorySlide>.unmodifiable(translatedSlides);
  }

  static Future<Quiz?> _autoTranslateQuiz({
    required Quiz? quiz,
    required String targetLanguageCode,
  }) async {
    if (quiz == null) {
      return null;
    }

    final translatedQuestions = await Future.wait(
      quiz.questions.map((question) async {
        final hasExplanation =
            question.explanation != null &&
            question.explanation!.trim().isNotEmpty;
        final sourceTexts = <String>[
          question.question,
          ...question.options,
          if (hasExplanation) question.explanation!,
        ];
        final translatedTexts = await _translateBatch(
          sourceTexts,
          targetLanguageCode,
        );

        final optionsStart = 1;
        final optionsEnd = optionsStart + question.options.length;
        final translatedOptions = translatedTexts.sublist(
          optionsStart,
          optionsEnd,
        );
        final translatedExplanation = hasExplanation
            ? translatedTexts[optionsEnd]
            : question.explanation;

        return QuizQuestion(
          question: translatedTexts.first,
          options: translatedOptions,
          correctAnswerIndex: question.correctAnswerIndex,
          explanation: translatedExplanation,
          type: question.type,
        );
      }),
    );

    return Quiz(
      questions: List<QuizQuestion>.unmodifiable(translatedQuestions),
      xpReward: quiz.xpReward,
    );
  }

  static Future<CodingChallenge?> _autoTranslateCodingChallenge({
    required CodingChallenge? challenge,
    required String targetLanguageCode,
  }) async {
    if (challenge == null) {
      return null;
    }

    final hasHint = challenge.hint != null && challenge.hint!.trim().isNotEmpty;
    final sourceTexts = <String>[
      challenge.title,
      challenge.description,
      if (hasHint) challenge.hint!,
    ];
    final translatedTexts = await _translateBatch(
      sourceTexts,
      targetLanguageCode,
    );

    return CodingChallenge(
      title: translatedTexts[0],
      description: translatedTexts[1],
      starterCode: challenge.starterCode,
      language: challenge.language,
      testCases: challenge.testCases,
      hint: hasHint ? translatedTexts[2] : challenge.hint,
      solution: challenge.solution,
      xpReward: challenge.xpReward,
    );
  }

  static Future<List<String>> _translateBatch(
    List<String> texts,
    String targetLanguageCode,
  ) {
    return RuntimeTranslationService.translateBatch(
      texts: texts,
      targetLanguageCode: targetLanguageCode,
    );
  }

  static bool _hasComprehensiveOverlayForCourse({
    required List<Lesson> baseLessons,
    required Map<String, Map<String, dynamic>> mergedTranslations,
  }) {
    if (mergedTranslations.length != baseLessons.length) {
      return false;
    }

    for (final lesson in baseLessons) {
      final translation = mergedTranslations[lesson.id];
      if (translation == null) {
        return false;
      }

      final hasCoreText =
          translation['title'] is String &&
          translation['description'] is String;
      final hasTheorySlides = translation['theorySlides'] is List;
      final hasQuiz = lesson.quiz == null || translation['quiz'] is Map;
      final hasChallenge =
          lesson.codingChallenge == null ||
          translation['codingChallenge'] is Map;

      if (!hasCoreText || !hasTheorySlides || !hasQuiz || !hasChallenge) {
        return false;
      }
    }

    return true;
  }

  static bool _hasMeaningfulLocalization({
    required List<Lesson> baseLessons,
    required List<Lesson> localizedLessons,
  }) {
    if (baseLessons.length != localizedLessons.length) {
      return true;
    }

    for (var index = 0; index < baseLessons.length; index++) {
      final baseLesson = baseLessons[index];
      final localizedLesson = localizedLessons[index];
      if (baseLesson.title != localizedLesson.title ||
          baseLesson.description != localizedLesson.description) {
        return true;
      }

      if (baseLesson.theorySlides.length !=
          localizedLesson.theorySlides.length) {
        return true;
      }
      for (
        var slideIndex = 0;
        slideIndex < baseLesson.theorySlides.length;
        slideIndex++
      ) {
        final baseSlide = baseLesson.theorySlides[slideIndex];
        final localizedSlide = localizedLesson.theorySlides[slideIndex];
        if (baseSlide.title != localizedSlide.title ||
            baseSlide.content != localizedSlide.content) {
          return true;
        }
      }

      final baseQuiz = baseLesson.quiz;
      final localizedQuiz = localizedLesson.quiz;
      if (baseQuiz == null && localizedQuiz != null ||
          baseQuiz != null && localizedQuiz == null) {
        return true;
      }
      if (baseQuiz != null && localizedQuiz != null) {
        if (baseQuiz.questions.length != localizedQuiz.questions.length) {
          return true;
        }
        for (
          var questionIndex = 0;
          questionIndex < baseQuiz.questions.length;
          questionIndex++
        ) {
          final baseQuestion = baseQuiz.questions[questionIndex];
          final localizedQuestion = localizedQuiz.questions[questionIndex];
          if (baseQuestion.question != localizedQuestion.question ||
              baseQuestion.explanation != localizedQuestion.explanation) {
            return true;
          }
          if (baseQuestion.options.length != localizedQuestion.options.length) {
            return true;
          }
          for (
            var optionIndex = 0;
            optionIndex < baseQuestion.options.length;
            optionIndex++
          ) {
            if (baseQuestion.options[optionIndex] !=
                localizedQuestion.options[optionIndex]) {
              return true;
            }
          }
        }
      }

      final baseChallenge = baseLesson.codingChallenge;
      final localizedChallenge = localizedLesson.codingChallenge;
      if (baseChallenge == null && localizedChallenge != null ||
          baseChallenge != null && localizedChallenge == null) {
        return true;
      }
      if (baseChallenge != null && localizedChallenge != null) {
        if (baseChallenge.title != localizedChallenge.title ||
            baseChallenge.description != localizedChallenge.description ||
            baseChallenge.hint != localizedChallenge.hint) {
          return true;
        }
      }
    }

    return false;
  }

  static Map<String, dynamic> _mergeMaps(
    Map<String, dynamic> base,
    Map<String, dynamic> overlay,
  ) {
    final merged = Map<String, dynamic>.from(base);

    for (final entry in overlay.entries) {
      final existingValue = merged[entry.key];
      final incomingValue = entry.value;

      if (existingValue is Map && incomingValue is Map) {
        merged[entry.key] = _mergeMaps(
          Map<String, dynamic>.from(existingValue),
          Map<String, dynamic>.from(incomingValue),
        );
      } else {
        merged[entry.key] = incomingValue;
      }
    }

    return merged;
  }

  static Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }
}
