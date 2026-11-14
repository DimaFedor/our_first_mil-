import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../foundation/json.dart';
import '../domain/content.dart';

class AssetContentRepository implements ContentRepository {
  final AssetBundle bundle;
  final Map<String, List<Lesson>> lessonCache = {};
  AssetContentRepository(this.bundle);

  @override
  Future<List<Course>> courses() async {
    final raw = jsonDecode(
      await bundle.loadString('assets/content/catalog.json'),
    );
    return List.unmodifiable(
      jsonList(raw).map((item) => Course.fromJson(jsonMap(item))).toList()
        ..sort((left, right) => left.order.compareTo(right.order)),
    );
  }

  @override
  Future<List<ContentLanguage>> languages() async {
    final raw = jsonDecode(
      await bundle.loadString('assets/content/languages.json'),
    );
    return List.unmodifiable(
      jsonList(raw).map((item) => ContentLanguage.fromJson(jsonMap(item))),
    );
  }

  @override
  Future<List<Lesson>> lessons(String courseId, String locale) async {
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(courseId) ||
        !RegExp(r'^[a-z]{2}$').hasMatch(locale)) {
      throw const AppFailure('notFound');
    }
    final key = '$locale:$courseId';
    if (lessonCache.containsKey(key)) return lessonCache[key]!;
    final catalog = await courses();
    if (!catalog.any((item) => item.id == courseId)) {
      throw const AppFailure('notFound');
    }
    final supported = await languages();
    final resolvedLocale = supported.any((item) => item.code == locale)
        ? locale
        : 'en';
    final raw = jsonMap(
      jsonDecode(await bundle.loadString('assets/content/en__$courseId.json')),
    );
    if (jsonInt(raw['schemaVersion']) != 1) {
      throw const AppFailure('contentVersion');
    }
    final overlay = resolvedLocale == 'en'
        ? <String, Object?>{}
        : jsonMap(
            jsonDecode(
              await bundle.loadString(
                'assets/content/${resolvedLocale}__$courseId.json',
              ),
            ),
          );
    final translations = jsonMap(overlay['lessons']);
    final lessons = List<Lesson>.unmodifiable(
      jsonList(raw['lessons']).map((item) {
        final base = jsonMap(item);
        final translated = jsonMap(translations[base['id']]);
        if (translated.isEmpty || translated['version'] != base['version']) {
          return Lesson.fromJson(base);
        }
        final slides = jsonMap(translated['slides']);
        final questions = jsonMap(translated['questions']);
        final quiz = jsonMap(base['quiz']);
        final challenge = jsonMap(base['codingChallenge']);
        return Lesson.fromJson({
          ...base,
          'title': translated['title'],
          'description': translated['description'],
          'sourceLocale': resolvedLocale,
          'theorySlides': jsonList(base['theorySlides']).map((item) {
            final slide = jsonMap(item);
            return {...slide, ...jsonMap(slides[slide['id']])};
          }).toList(),
          'quiz': quiz.isEmpty
              ? null
              : {
                  ...quiz,
                  'questions': jsonList(quiz['questions']).map((item) {
                    final question = jsonMap(item);
                    final text = jsonMap(questions[question['id']]);
                    final options = jsonMap(text['options']);
                    return {
                      ...question,
                      'question': text['prompt'],
                      'explanation': text['explanation'],
                      'options': jsonList(
                        question['optionIds'],
                      ).map((id) => options[id]).toList(),
                    };
                  }).toList(),
                },
          'codingChallenge': challenge.isEmpty
              ? null
              : {...challenge, ...jsonMap(translated['challenge'])},
        });
      }),
    );
    if (lessonCache.length >= 8) lessonCache.remove(lessonCache.keys.first);
    lessonCache[key] = lessons;
    return lessons;
  }
}
