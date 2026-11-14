import 'dart:convert';
import 'dart:io';

import 'package:codelearn_next/features/practice/data/exercise_evaluator.dart';
import 'package:codelearn_next/features/practice/domain/practice_result.dart';
import 'package:codelearn_next/foundation/json.dart';

Future<void> main() async {
  final failures = <JsonMap>[];
  var total = 0;
  for (final file in Directory(
    'assets/content',
  ).listSync().whereType<File>().where((file) => file.path.contains('/en__'))) {
    final course = jsonMap(jsonDecode(file.readAsStringSync()));
    for (final value in jsonList(course['lessons'])) {
      final lesson = jsonMap(value);
      final challenge = jsonMap(lesson['codingChallenge']);
      if (challenge.isEmpty ||
          ['python', 'javascript'].contains(challenge['language'])) {
        continue;
      }
      total++;
      final result = PracticeResult.fromJson(
        await evaluateExercise({
          'code': challenge['solution'],
          'challenge': {
            'language': challenge['language'],
            'solution': challenge['solution'],
            'tests': challenge['testCases'],
          },
        }),
      );
      if (!result.passed) {
        failures.add({
          'id': lesson['id'],
          'language': challenge['language'],
          'diagnostic': result.diagnostic,
          'output': result.output,
          'tests': challenge['testCases'],
          'solution': challenge['solution'],
        });
        stdout.writeln('FAILED ${lesson['id']}: ${result.diagnostic}');
      }
    }
  }
  File('docs/practice-validation.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'total': total,
      'passed': total - failures.length,
      'failures': failures,
    }),
  );
  stdout.writeln(
    '${total - failures.length}/$total reference solutions passed',
  );
  exitCode = failures.isEmpty ? 0 : 1;
}
