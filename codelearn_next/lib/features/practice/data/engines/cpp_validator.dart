class CppValidator {
  final Map<String, Object?> variables = <String, Object?>{};
  final List<String> output = <String>[];

  CppExecutionResult execute(String code) {
    variables.clear();
    output.clear();
    String? error;

    try {
      final lines = preprocessCode(code);
      final conditions = <bool>[];
      bool? lastCondition;
      for (final line in lines) {
        if (line.startsWith('if ') || line.startsWith('if(')) {
          final match = RegExp(
            r'if\s*\((\w+)\s*(>=|<=|==|!=|>|<)\s*(-?\d+)\)',
          ).firstMatch(line);
          if (match == null) {
            throw const FormatException('Unsupported condition');
          }
          final left = variables[match.group(1)] as num? ?? 0;
          final right = num.parse(match.group(3)!);
          final condition = switch (match.group(2)) {
            '>=' => left >= right,
            '<=' => left <= right,
            '>' => left > right,
            '<' => left < right,
            '==' => left == right,
            _ => left != right,
          };
          conditions.add(condition);
          continue;
        }
        if (line.startsWith('} else')) {
          if (conditions.isNotEmpty) {
            conditions[conditions.length - 1] = !conditions.last;
          }
          continue;
        }
        if (line == '}' && conditions.isNotEmpty) {
          lastCondition = conditions.removeLast();
          continue;
        }
        if (line.startsWith('else')) {
          conditions.add(!(lastCondition ?? false));
          continue;
        }
        if (conditions.contains(false)) continue;
        if (isSkippableLine(line)) {
          continue;
        }

        if (isCoutStatement(line)) {
          handleCout(line);
          continue;
        }

        if (isDeclarationStatement(line)) {
          handleDeclaration(line);
          continue;
        }

        if (isAssignmentStatement(line)) {
          handleAssignment(line);
          continue;
        }
      }
    } catch (e) {
      error = formatError(e.toString());
    }

    return CppExecutionResult(
      output: output.join('\n'),
      error: error,
      hasError: error != null,
    );
  }

  List<String> preprocessCode(String code) {
    final normalized = code.replaceAll('\r\n', '\n');
    final lines = <String>[];

    for (var rawLine in normalized.split('\n')) {
      final stripped = stripInlineComment(rawLine).trim();
      if (stripped.isEmpty) continue;
      lines.add(stripped);
    }

    return lines;
  }

  String stripInlineComment(String line) {
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

  bool isSkippableLine(String line) {
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

  bool isCoutStatement(String line) {
    return line.startsWith('cout <<') || line.startsWith('std::cout <<');
  }

  bool isDeclarationStatement(String line) {
    final declarationPattern = RegExp(
      r'^(?:const\s+)?(int|long|double|float|bool|string|char)\s+[A-Za-z_]\w*(?:\s*=\s*.+)?;$',
    );
    return declarationPattern.hasMatch(line);
  }

  bool isAssignmentStatement(String line) {
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

  void handleDeclaration(String line) {
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
      variables[variableName] = defaultValueForType(type);
      return;
    }

    variables[variableName] = evaluateExpression(rawValue);
  }

  void handleAssignment(String line) {
    final match = RegExp(r'^([A-Za-z_]\w*)\s*=\s*(.+);$').firstMatch(line);
    if (match == null) {
      throw Exception('Invalid assignment: $line');
    }

    final variableName = match.group(1)!;
    final rawValue = match.group(2)!.trim();
    variables[variableName] = evaluateExpression(rawValue);
  }

  void handleCout(String line) {
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
        output.add(buffer.toString());
        buffer = StringBuffer();
        emittedLineByEndl = true;
        continue;
      }

      final value = evaluateExpression(token);
      buffer.write(formatValue(value));
    }

    if (buffer.isNotEmpty || !emittedLineByEndl) {
      output.add(buffer.toString());
    }
  }

  Object? defaultValueForType(String type) {
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

  Object? evaluateExpression(String expression) {
    var expr = expression.trim();

    if (expr.startsWith('(') && expr.endsWith(')')) {
      expr = expr.substring(1, expr.length - 1).trim();
    }

    if (isDoubleQuotedString(expr)) {
      return expr.substring(1, expr.length - 1);
    }

    if (isSingleQuotedChar(expr)) {
      return expr.substring(1, expr.length - 1);
    }

    if (expr == 'true') return true;
    if (expr == 'false') return false;

    final intValue = int.tryParse(expr);
    if (intValue != null) return intValue;
    final doubleValue = double.tryParse(expr);
    if (doubleValue != null) return doubleValue;

    if (variables.containsKey(expr)) {
      return variables[expr];
    }

    final binary = splitBinaryExpression(expr);
    if (binary != null) {
      final leftValue = evaluateExpression(binary.left);
      final rightValue = evaluateExpression(binary.right);
      return applyOperator(leftValue, rightValue, binary.operator);
    }

    throw Exception('Unsupported expression: $expression');
  }

  BinaryExpression? splitBinaryExpression(String expression) {
    for (final operator in <String>['+', '-', '*', '/']) {
      final index = findOperatorIndex(expression, operator);
      if (index <= 0 || index >= expression.length - 1) {
        continue;
      }

      final left = expression.substring(0, index).trim();
      final right = expression.substring(index + 1).trim();
      if (left.isEmpty || right.isEmpty) continue;

      return BinaryExpression(left: left, operator: operator, right: right);
    }
    return null;
  }

  int findOperatorIndex(String expression, String operator) {
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

  Object applyOperator(Object? left, Object? right, String operator) {
    if (operator == '+' && (left is String || right is String)) {
      return '${formatValue(left)}${formatValue(right)}';
    }

    final leftNumber = toNumber(left);
    final rightNumber = toNumber(right);
    if (leftNumber == null || rightNumber == null) {
      throw Exception('Cannot apply "$operator" to non-numeric values.');
    }

    switch (operator) {
      case '+':
        return normalizeNumeric(leftNumber + rightNumber);
      case '-':
        return normalizeNumeric(leftNumber - rightNumber);
      case '*':
        return normalizeNumeric(leftNumber * rightNumber);
      case '/':
        if (rightNumber == 0) {
          throw Exception('Division by zero.');
        }
        return normalizeNumeric(leftNumber / rightNumber);
      default:
        throw Exception('Unsupported operator: $operator');
    }
  }

  num? toNumber(Object? value) {
    if (value is int || value is double) {
      return value as num;
    }
    if (value is String) {
      return num.tryParse(value.trim());
    }
    return null;
  }

  Object normalizeNumeric(num value) {
    if (value == value.toInt()) {
      return value.toInt();
    }
    return value.toDouble();
  }

  bool isDoubleQuotedString(String value) {
    return value.length >= 2 && value.startsWith('"') && value.endsWith('"');
  }

  bool isSingleQuotedChar(String value) {
    return value.length >= 3 && value.startsWith("'") && value.endsWith("'");
  }

  String formatValue(Object? value) {
    if (value == null) return '';
    if (value is bool) return value ? 'true' : 'false';
    if (value is double && value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String formatError(String error) {
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

class BinaryExpression {
  final String left;
  final String operator;
  final String right;

  const BinaryExpression({
    required this.left,
    required this.operator,
    required this.right,
  });
}
