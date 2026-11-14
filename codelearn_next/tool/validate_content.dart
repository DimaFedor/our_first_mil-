import 'dart:convert';
import 'dart:io';

import 'package:codelearn_next/foundation/json.dart';

void main() {
  final directory = Directory('assets/content');
  final errors = <String>[];
  final ids = <String>{};
  var lessonCount = 0;
  var translationCount = 0;
  for (final file in directory.listSync().whereType<File>().where(
    (file) => file.path.contains('/en__'),
  )) {
    final course = jsonMap(jsonDecode(file.readAsStringSync()));
    final lessons = jsonList(course['lessons']).map(jsonMap).toList();
    for (final lesson in lessons) {
      lessonCount++;
      final id = jsonString(lesson['id']);
      if (id.isEmpty || !ids.add(id)) {
        errors.add('Duplicate or empty lesson ID: $id');
      }
      for (final value in jsonList(jsonMap(lesson['quiz'])['questions'])) {
        final question = jsonMap(value);
        final options = jsonList(question['optionIds']);
        if (options.length != jsonList(question['options']).length ||
            !options.contains(question['correctOptionId'])) {
          errors.add('Invalid answers in $id');
        }
      }
      final challenge = jsonMap(lesson['codingChallenge']);
      if (challenge.isNotEmpty &&
          (jsonString(challenge['solution']).isEmpty ||
              jsonList(challenge['testCases']).isEmpty)) {
        errors.add('Invalid challenge in $id');
      }
    }
    final byId = {for (final lesson in lessons) lesson['id']: lesson};
    final courseId = jsonString(course['courseId']);
    for (final languageFile in directory.listSync().whereType<File>().where(
      (item) =>
          item.path.endsWith('__$courseId.json') && item.path != file.path,
    )) {
      final overlay = jsonMap(jsonDecode(languageFile.readAsStringSync()));
      for (final entry in jsonMap(overlay['lessons']).entries) {
        translationCount++;
        final base = byId[entry.key];
        final translated = jsonMap(entry.value);
        if (base == null || translated['version'] != base['version']) {
          errors.add('Stale translation: ${languageFile.path}/${entry.key}');
          continue;
        }
        for (final value in jsonList(base['theorySlides'])) {
          final slide = jsonMap(value);
          final text = jsonMap(jsonMap(translated['slides'])[slide['id']]);
          if (jsonString(text['title']).isEmpty ||
              jsonString(text['content']).isEmpty) {
            errors.add('Incomplete slide ${slide['id']}');
          }
        }
        for (final value in jsonList(jsonMap(base['quiz'])['questions'])) {
          final question = jsonMap(value);
          final text = jsonMap(
            jsonMap(translated['questions'])[question['id']],
          );
          final options = jsonMap(text['options']);
          if (jsonString(text['prompt']).isEmpty ||
              jsonList(
                question['optionIds'],
              ).any((id) => jsonString(options[id]).isEmpty)) {
            errors.add('Incomplete question ${question['id']}');
          }
        }
      }
    }
  }
  for (final error in errors) {
    stderr.writeln(error);
  }
  stdout.writeln(
    '$lessonCount lessons, $translationCount translated lessons, ${errors.length} errors',
  );
  exitCode = errors.isEmpty ? 0 : 1;
}
