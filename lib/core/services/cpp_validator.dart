/// Lightweight C++ validator used by in-app coding challenges.
///
/// This is not a full C++ runtime. It validates common syntax patterns and
/// evaluates simple expressions used in beginner/intermediate exercises.
class CppValidator {
  final Map<String, Object?> _variables = <String, Object?>{};
  final List<String> _output = <String>[];

  CppExecutionResult execute(String code) {
    _variables.clear();
    _output.clear();
    String? error;

    try {
      final lines = _preprocessCode(code);
      for (final line in lines) {
        if (_isSkippableLine(line)) {
          continue;
        }

        if (_isCoutStatement(line)) {
          _handleCout(line);
          continue;
        }

        if (_isDeclarationStatement(line)) {
          _handleDeclaration(line);
          continue;
        }

        if (_isAssignmentStatement(line)) {
          _handleAssignment(line);
          continue;
        }
      }
    } catch (e) {
      error = _formatError(e.toString());
    }

    return CppExecutionResult(
      output: _output.join('\n'),
      error: error,
      hasError: error != null,
    );
  }

  List<String> _preprocessCode(String code) {
    final normalized = code.replaceAll('\r\n', '\n');
    final lines = <String>[];

    for (var rawLine in normalized.split('\n')) {
      final stripped = _stripInlineComment(rawLine).trim();
      if (stripped.isEmpty) continue;
      lines.add(stripped);
    }

    return lines;
  }

  String _stripInlineComment(String line) {
    var inSingleQuote = false;
    var inDoubleQuote = false;

    for (var i = 0; i < line.length - 1; i++) {
      final char = line[i];
      if (char == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
        continue;
      }
      if (char == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
        continue;
      }
      if (!inSingleQuote &&
          !inDoubleQuote &&
          char == '/' &&
          line[i + 1] == '/') {
        return line.substring(0, i);
      }
    }
    return line;
  }

  bool _isSkippableLine(String line) {
    if (line.startsWith('#')) return true;
    if (line.startsWith('using namespace ')) return true;
    if (line == '{' || line == '}' || line == '};') return true;
    if (line.startsWith('int main(') ||
        line.startsWith('void main(') ||
        line.startsWith('main(')) {
      return true;
    }
    if (line.startsWith('return ')) return true;

    final controlFlowStarts = <String>[
      'if ',
      'if(',
      'else',
      'for ',
      'for(',
      'while ',
      'while(',
      'switch ',
      'switch(',
      'case ',
      'default:',
      'break;',
      'continue;',
      'class ',
      'struct ',
      'public:',
      'private:',
      'protected:',
      'template',
      'typename ',
    ];

    return controlFlowStarts.any((prefix) => line.startsWith(prefix));
  }

  bool _isCoutStatement(String line) {
    return line.startsWith('cout <<') || line.startsWith('std::cout <<');
  }

  bool _isDeclarationStatement(String line) {
    final declarationPattern = RegExp(
      r'^(?:const\s+)?(int|long|double|float|bool|string|char)\s+[A-Za-z_]\w*(?:\s*=\s*.+)?;$',
    );
    return declarationPattern.hasMatch(line);
  }

  bool _isAssignmentStatement(String line) {
    final assignmentPattern = RegExp(r'^[A-Za-z_]\w*\s*=\s*.+;$');
    if (!assignmentPattern.hasMatch(line)) {
      return false;
    }
    if (line.contains('==') ||
        line.contains('<=') ||
        line.contains('>=') ||
        line.contains('!=')) {
      return false;
    }
    return true;
  }

  void _handleDeclaration(String line) {
    final match = RegExp(
      r'^(?:const\s+)?(int|long|double|float|bool|string|char)\s+([A-Za-z_]\w*)(?:\s*=\s*(.+))?;$',
    ).firstMatch(line);

    if (match == null) {
      throw Exception('Invalid declaration: $line');
    }

    final type = match.group(1)!;
    final variableName = match.group(2)!;
    final rawValue = match.group(3)?.trim();

    if (rawValue == null || rawValue.isEmpty) {
      _variables[variableName] = _defaultValueForType(type);
      return;
    }

    _variables[variableName] = _evaluateExpression(rawValue);
  }

  void _handleAssignment(String line) {
    final match = RegExp(r'^([A-Za-z_]\w*)\s*=\s*(.+);$').firstMatch(line);
    if (match == null) {
      throw Exception('Invalid assignment: $line');
    }

    final variableName = match.group(1)!;
    final rawValue = match.group(2)!.trim();
    _variables[variableName] = _evaluateExpression(rawValue);
  }

  void _handleCout(String line) {
    final match = RegExp(r'^(?:std::)?cout\s*<<\s*(.+);$').firstMatch(line);
    if (match == null) {
      throw Exception('cout statement must end with semicolon.');
    }

    final expressionChain = match.group(1)!;
    final tokens = expressionChain.split('<<');
    var buffer = StringBuffer();
    var emittedLineByEndl = false;

    for (final rawToken in tokens) {
      final token = rawToken.trim();
      if (token.isEmpty) {
        continue;
      }

      if (token == 'endl' || token == 'std::endl') {
        _output.add(buffer.toString());
        buffer = StringBuffer();
        emittedLineByEndl = true;
        continue;
      }

      final value = _evaluateExpression(token);
      buffer.write(_formatValue(value));
    }

    if (buffer.isNotEmpty || !emittedLineByEndl) {
      _output.add(buffer.toString());
    }
  }

  Object? _defaultValueForType(String type) {
    switch (type) {
      case 'int':
      case 'long':
        return 0;
      case 'double':
      case 'float':
        return 0.0;
      case 'bool':
        return false;
      case 'string':
        return '';
      case 'char':
        return '\u0000';
      default:
        return null;
    }
  }

  Object? _evaluateExpression(String expression) {
    var expr = expression.trim();

    if (expr.startsWith('(') && expr.endsWith(')')) {
      expr = expr.substring(1, expr.length - 1).trim();
    }

    if (_isDoubleQuotedString(expr)) {
      return expr.substring(1, expr.length - 1);
    }

    if (_isSingleQuotedChar(expr)) {
      return expr.substring(1, expr.length - 1);
    }

    if (expr == 'true') return true;
    if (expr == 'false') return false;

    final intValue = int.tryParse(expr);
    if (intValue != null) return intValue;
    final doubleValue = double.tryParse(expr);
    if (doubleValue != null) return doubleValue;

    if (_variables.containsKey(expr)) {
      return _variables[expr];
    }

    final binary = _splitBinaryExpression(expr);
    if (binary != null) {
      final leftValue = _evaluateExpression(binary.left);
      final rightValue = _evaluateExpression(binary.right);
      return _applyOperator(leftValue, rightValue, binary.operator);
    }

    throw Exception('Unsupported expression: $expression');
  }

  _BinaryExpression? _splitBinaryExpression(String expression) {
    for (final operator in <String>['+', '-', '*', '/']) {
      final index = _findOperatorIndex(expression, operator);
      if (index <= 0 || index >= expression.length - 1) {
        continue;
      }

      final left = expression.substring(0, index).trim();
      final right = expression.substring(index + 1).trim();
      if (left.isEmpty || right.isEmpty) continue;

      return _BinaryExpression(left: left, operator: operator, right: right);
    }
    return null;
  }

  int _findOperatorIndex(String expression, String operator) {
    var inSingleQuote = false;
    var inDoubleQuote = false;
    var depth = 0;

    for (var i = 0; i < expression.length; i++) {
      final char = expression[i];

      if (char == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
        continue;
      }
      if (char == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
        continue;
      }
      if (inSingleQuote || inDoubleQuote) {
        continue;
      }
      if (char == '(') {
        depth++;
        continue;
      }
      if (char == ')') {
        depth--;
        continue;
      }
      if (depth != 0) {
        continue;
      }
      if (char == operator) {
        if (operator == '-' && i == 0) {
          continue;
        }
        return i;
      }
    }

    return -1;
  }

  Object _applyOperator(Object? left, Object? right, String operator) {
    if (operator == '+' && (left is String || right is String)) {
      return '${_formatValue(left)}${_formatValue(right)}';
    }

    final leftNumber = _toNumber(left);
    final rightNumber = _toNumber(right);
    if (leftNumber == null || rightNumber == null) {
      throw Exception('Cannot apply "$operator" to non-numeric values.');
    }

    switch (operator) {
      case '+':
        return _normalizeNumeric(leftNumber + rightNumber);
      case '-':
        return _normalizeNumeric(leftNumber - rightNumber);
      case '*':
        return _normalizeNumeric(leftNumber * rightNumber);
      case '/':
        if (rightNumber == 0) {
          throw Exception('Division by zero.');
        }
        return _normalizeNumeric(leftNumber / rightNumber);
      default:
        throw Exception('Unsupported operator: $operator');
    }
  }

  num? _toNumber(Object? value) {
    if (value is int || value is double) {
      return value as num;
    }
    if (value is String) {
      return num.tryParse(value.trim());
    }
    return null;
  }

  Object _normalizeNumeric(num value) {
    if (value == value.toInt()) {
      return value.toInt();
    }
    return value.toDouble();
  }

  bool _isDoubleQuotedString(String value) {
    return value.length >= 2 && value.startsWith('"') && value.endsWith('"');
  }

  bool _isSingleQuotedChar(String value) {
    return value.length >= 3 && value.startsWith("'") && value.endsWith("'");
  }

  String _formatValue(Object? value) {
    if (value == null) return '';
    if (value is bool) return value ? 'true' : 'false';
    if (value is double && value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _formatError(String error) {
    final cleaned = error.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return '❌ C++ validation error: $cleaned\n💡 Tip: check semicolons, cout, and simple expression syntax.';
  }
}

class CppExecutionResult {
  final String output;
  final String? error;
  final bool hasError;

  CppExecutionResult({
    required this.output,
    required this.error,
    required this.hasError,
  });
}

class _BinaryExpression {
  final String left;
  final String operator;
  final String right;

  const _BinaryExpression({
    required this.left,
    required this.operator,
    required this.right,
  });
}
