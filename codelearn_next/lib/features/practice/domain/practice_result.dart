import '../../../foundation/json.dart';

class PracticeResult {
  final bool passed;
  final String output;
  final String diagnostic;
  final int passedCount;
  final int totalCount;
  final JsonMap visualization;
  const PracticeResult({
    required this.passed,
    this.output = '',
    this.diagnostic = '',
    this.passedCount = 0,
    this.totalCount = 0,
    this.visualization = const {},
  });
  factory PracticeResult.fromJson(JsonMap value) => PracticeResult(
    passed: jsonBool(value['passed']),
    output: jsonString(value['output']),
    diagnostic: jsonString(value['diagnostic']),
    passedCount: jsonInt(value['passedCount']),
    totalCount: jsonInt(value['totalCount']),
    visualization: jsonMap(value['visualization']),
  );
  JsonMap toJson() => {
    'passed': passed,
    'output': output,
    'diagnostic': diagnostic,
    'passedCount': passedCount,
    'totalCount': totalCount,
    'visualization': visualization,
  };
}
