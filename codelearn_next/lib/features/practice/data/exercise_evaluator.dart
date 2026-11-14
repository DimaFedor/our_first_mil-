import '../../../foundation/json.dart';
import '../domain/practice_result.dart';
import 'engines/bash_interpreter.dart' show BashInterpreter;
import 'engines/cpp_validator.dart' show CppValidator;
import 'engines/git_branching_simulator.dart';
import 'engines/html_validator.dart' show HTMLValidator;
import 'sql_evaluator.dart';

Future<JsonMap> evaluateExercise(JsonMap request) async {
  final code = jsonString(request['code']);
  final challenge = jsonMap(request['challenge']);
  final language = jsonString(challenge['language']).toLowerCase();
  final reference = jsonString(challenge['solution']);
  final tests = jsonList(challenge['tests']).map(jsonMap).toList();
  if (code.trim().isEmpty || code.length > 20000) {
    return const PracticeResult(
      passed: false,
      diagnostic: 'unsupportedCode',
    ).toJson();
  }
  try {
    if (language == 'sql') return (await evaluateSql(code, reference)).toJson();
    if (language == 'git') {
      final simulator = GitBranchingSimulator();
      final result = simulator.execute(code);
      final failures = <String>[];
      for (final test in tests) {
        failures.addAll(
          simulator
              .validateGoal(
                state: result.state,
                goal: GitChallengeGoal.fromDsl(
                  jsonString(test['expectedOutput']),
                ),
              )
              .failures,
        );
      }
      final passed = !result.hasError && failures.isEmpty;
      return PracticeResult(
        passed: passed,
        output: result.output,
        diagnostic: result.error ?? failures.join('\n'),
        passedCount: passed ? tests.length : 0,
        totalCount: tests.length,
        visualization: {
          'head': result.state.head,
          'branches': result.state.branches,
          'commits': result.state.commits
              .map(
                (node) => {
                  'id': node.id,
                  'parents': node.parents,
                  'message': node.message,
                  'lane': node.lane,
                },
              )
              .toList(),
        },
      ).toJson();
    }
    if (language == 'html' ||
        language == 'css' ||
        language == 'html/css' ||
        reference.contains('return <') ||
        reference.contains('useState') ||
        reference.contains('useEffect')) {
      final valid =
          language == 'css' || !HTMLValidator().execute(code).hasError;
      final normalized = normalizeSource(code);
      final referenceNormalized = normalizeSource(reference);
      final exact = normalized == referenceNormalized;
      final expectedMarkers = tests
          .map((test) => jsonString(test['expectedOutput']))
          .where((item) => item.isNotEmpty);
      final markersPresent = expectedMarkers.every(
        (marker) => normalized.contains(normalizeSource(marker)),
      );
      final requiredTokens = RegExp(
        r'[A-Za-z_][A-Za-z0-9_-]*(?=\s*[:=(])',
      ).allMatches(reference).map((match) => match.group(0)!).toSet();
      final passed =
          valid &&
          (exact ||
              (markersPresent &&
                  requiredTokens.every((token) => code.contains(token)) &&
                  code.contains(language == 'css' ? '{' : '<')));
      return PracticeResult(
        passed: passed,
        output: code,
        diagnostic: passed ? '' : 'resultMismatch',
        passedCount: passed ? tests.length : 0,
        totalCount: tests.length,
      ).toJson();
    }
    final outputs = <String>[];
    var passedCount = 0;
    JsonMap visualization = {};
    for (final test in tests) {
      final input = jsonString(test['input']);
      final execution = executeSnippet(language, code, input);
      if (jsonString(execution['error']).isNotEmpty) {
        return PracticeResult(
          passed: false,
          diagnostic: jsonString(execution['error']),
          totalCount: tests.length,
        ).toJson();
      }
      final output = jsonString(execution['output']);
      outputs.add(output);
      visualization = jsonMap(execution['variables']);
      if (normalizeOutput(output) ==
          normalizeOutput(jsonString(test['expectedOutput']))) {
        passedCount++;
      }
    }
    return PracticeResult(
      passed: tests.isNotEmpty && passedCount == tests.length,
      output: outputs.toSet().join('\n'),
      diagnostic: passedCount == tests.length ? '' : 'resultMismatch',
      passedCount: passedCount,
      totalCount: tests.length,
      visualization: visualization,
    ).toJson();
  } on Exception catch (error) {
    return PracticeResult(
      passed: false,
      diagnostic: error is AppFailure ? error.code : error.toString(),
    ).toJson();
  }
}

JsonMap executeSnippet(String language, String code, String input) {
  switch (language) {
    case 'cpp':
    case 'c++':
    case 'cplusplus':
      final result = CppValidator().execute(code);
      return {'output': result.output, 'error': result.error};
    case 'bash':
    case 'shell':
    case 'sh':
      final interpreter = BashInterpreter();
      interpreter.fileSystem.addAll({
        '/home/ubuntu/downloads': 'DIR',
        '/home/ubuntu/notes': 'DIR',
        '/home/ubuntu/projects': 'DIR',
        '/home/ubuntu/notes/today.txt':
            'TODO: finish CLI homework\nTODO: run tests\nDONE: clean desktop',
        '/home/ubuntu/readme.md': 'Welcome to CodeLearn',
        '/home/ubuntu/todo.txt': 'Learn CLI',
      });
      final result = interpreter.execute(code);
      return {
        'output': result.output,
        'error': result.error,
        'variables': result.variables,
      };
    default:
      throw const AppFailure('unsupportedCode');
  }
}

String normalizeOutput(String value) =>
    value.replaceAll('\r\n', '\n').trimRight();
String normalizeSource(String value) => value
    .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
