import 'package:codelearn_next/features/practice/data/exercise_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'all required tests must pass and output remains case sensitive',
    () async {
      final result = await evaluateExercise({
        'code': '#include <iostream>\nint main() {\nstd::cout << "Hello";\n}',
        'challenge': {
          'language': 'cpp',
          'tests': [
            {'input': '', 'expectedOutput': 'Hello'},
            {'input': '', 'expectedOutput': 'hello'},
          ],
        },
      });
      expect(result['passed'], false);
      expect(result['passedCount'], 1);
    },
  );
  test('unknown languages are not treated as Python', () async {
    final result = await evaluateExercise({
      'code': 'print("x")',
      'challenge': {
        'language': 'unknown',
        'tests': [
          {'expectedOutput': 'x'},
        ],
      },
    });
    expect(result['passed'], false);
    expect(result['diagnostic'], 'unsupportedCode');
  });
  test('SQL accepts equivalent output instead of string matching', () async {
    final result = await evaluateExercise({
      'code': 'select p.name from products as p where p.id = 1',
      'challenge': {
        'language': 'sql',
        'solution': 'SELECT name FROM products WHERE id=1;',
        'tests': [],
      },
    });
    expect(result['passed'], true);
  });
  test('SQL rejects a query returning different results', () async {
    final result = await evaluateExercise({
      'code': 'SELECT name FROM products WHERE id=2;',
      'challenge': {
        'language': 'sql',
        'solution': 'SELECT name FROM products WHERE id=1;',
        'tests': [],
      },
    });
    expect(result['passed'], false);
  });
}
