import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/cpp_validator.dart';

void main() {
  group('CppValidator', () {
    test('executes basic cout output', () {
      final validator = CppValidator();

      final result = validator.execute('''
#include <iostream>
using namespace std;

int main() {
  cout << "Hello, C++!";
  return 0;
}
''');

      expect(result.hasError, isFalse);
      expect(result.output, 'Hello, C++!');
    });

    test('evaluates simple numeric expressions', () {
      final validator = CppValidator();

      final result = validator.execute('''
int score = 7;
int bonus = 5;
cout << score + bonus;
''');

      expect(result.hasError, isFalse);
      expect(result.output, '12');
    });

    test('returns validation error for invalid cout syntax', () {
      final validator = CppValidator();

      final result = validator.execute('''
cout << "Broken output"
''');

      expect(result.hasError, isTrue);
      expect(result.error, contains('C++ validation error'));
    });
  });
}
