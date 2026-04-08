/// Simple Python interpreter for code challenges
/// Handles basic Python syntax: variables, print(), arithmetic, strings, lists, conditionals
class PythonInterpreter {
  final Map<String, dynamic> _variables = {};
  final List<String> _output = [];
  String? _error;

  /// Execute Python code and return the result
  InterpreterResult execute(String code) {
    _variables.clear();
    _output.clear();
    _error = null;

    try {
      final lines = _preprocessCode(code);
      _executeLines(lines, 0, lines.length);
    } catch (e) {
      _error = _formatError(e.toString());
    }

    return InterpreterResult(
      output: _output.join('\n'),
      error: _error,
      variables: Map.from(_variables),
    );
  }
  
  /// Format error message with helpful context
  String _formatError(String error) {
    // Remove "Exception:" prefix if present
    error = error.replaceFirst(RegExp(r'^Exception:\s*'), '');
    
    // Common Python error translations
    final errorPatterns = {
      'undefined variable': '❌ NameError: Variable not defined\n💡 Hint: Check if you declared this variable before using it.',
      'division by zero': '❌ ZeroDivisionError: Cannot divide by zero\n💡 Hint: Make sure the divisor is not 0.',
      'index out of range': '❌ IndexError: List index out of range\n💡 Hint: Check if the list has enough elements.',
      'invalid syntax': '❌ SyntaxError: Invalid syntax\n💡 Hint: Check for missing colons, parentheses, or quotes.',
      'type error': '❌ TypeError: Operation not supported between these types\n💡 Hint: Make sure you\'re using compatible data types.',
    };
    
    for (final pattern in errorPatterns.entries) {
      if (error.toLowerCase().contains(pattern.key)) {
        return pattern.value;
      }
    }
    
    return '❌ Error: $error\n💡 Hint: Check your code for typos or missing elements.';
  }

  /// Preprocess code - remove comments, handle multiline strings
  List<String> _preprocessCode(String code) {
    final lines = <String>[];
    
    for (var line in code.split('\n')) {
      // Remove inline comments
      final commentIndex = line.indexOf('#');
      if (commentIndex >= 0) {
        // Check if # is inside a string
        final beforeComment = line.substring(0, commentIndex);
        final singleQuotes = "'".allMatches(beforeComment).length;
        final doubleQuotes = '"'.allMatches(beforeComment).length;
        if (singleQuotes % 2 == 0 && doubleQuotes % 2 == 0) {
          line = beforeComment;
        }
      }
      
      line = line.trimRight();
      if (line.isNotEmpty) {
        lines.add(line);
      }
    }
    
    return lines;
  }

  /// Execute lines of code
  void _executeLines(List<String> lines, int start, int end) {
    int i = start;
    while (i < end) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        i++;
        continue;
      }

      // Handle if statement
      if (line.startsWith('if ')) {
        i = _handleIf(lines, i, end);
        continue;
      }

      // Handle for loop
      if (line.startsWith('for ')) {
        i = _handleFor(lines, i, end);
        continue;
      }

      // Handle while loop
      if (line.startsWith('while ')) {
        i = _handleWhile(lines, i, end);
        continue;
      }

      // Handle regular statement
      _executeStatement(line);
      i++;
    }
  }

  /// Execute a single statement
  void _executeStatement(String line) {
    line = line.trim();
    
    // print() statement
    if (line.startsWith('print(') && line.endsWith(')')) {
      _handlePrint(line);
      return;
    }

    // Assignment statement
    if (line.contains('=') && !line.contains('==')) {
      _handleAssignment(line);
      return;
    }

    // Handle augmented assignment (+=, -=, etc.)
    if (line.contains('+=') || line.contains('-=') || 
        line.contains('*=') || line.contains('/=')) {
      _handleAugmentedAssignment(line);
      return;
    }
  }

  /// Handle print() statements
  void _handlePrint(String line) {
    // Extract content between print( and )
    final content = line.substring(6, line.length - 1).trim();
    
    if (content.isEmpty) {
      _output.add('');
      return;
    }

    // Parse arguments (comma separated, respecting strings and parens)
    final args = _parseArguments(content);
    final outputParts = <String>[];

    for (var arg in args) {
      arg = arg.trim();
      
      // Handle sep= and end= parameters
      if (arg.startsWith('sep=') || arg.startsWith('end=')) {
        continue; // Skip for simplicity
      }

      final value = _evaluateExpression(arg);
      outputParts.add(_formatValue(value));
    }

    _output.add(outputParts.join(' '));
  }

  /// Parse comma-separated arguments respecting quotes and parens
  List<String> _parseArguments(String content) {
    final args = <String>[];
    var current = StringBuffer();
    var parenDepth = 0;
    var inString = false;
    String? stringChar;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      // Handle string boundaries
      if ((char == '"' || char == "'") && (i == 0 || content[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
          stringChar = null;
        }
      }

      // Handle parentheses (only outside strings)
      if (!inString) {
        if (char == '(' || char == '[') parenDepth++;
        if (char == ')' || char == ']') parenDepth--;

        // Split on comma at top level (only outside strings!)
        if (char == ',' && parenDepth == 0) {
          args.add(current.toString());
          current = StringBuffer();
          continue;
        }
      }

      current.write(char);
    }

    if (current.isNotEmpty) {
      args.add(current.toString());
    }

    return args;
  }

  /// Handle variable assignment
  void _handleAssignment(String line) {
    // Handle multiple assignment like a, b = 1, 2
    if (line.contains(',') && !line.contains('[') && !line.contains('(')) {
      _handleMultipleAssignment(line);
      return;
    }

    final parts = line.split('=');
    if (parts.length < 2) return;

    final varName = parts[0].trim();
    final expression = parts.sublist(1).join('=').trim();

    // Validate variable name
    if (!_isValidVariableName(varName)) {
      _error = "Invalid variable name: $varName";
      return;
    }

    final value = _evaluateExpression(expression);
    _variables[varName] = value;
  }

  /// Handle augmented assignment (+=, -=, etc.)
  void _handleAugmentedAssignment(String line) {
    final patterns = ['+=', '-=', '*=', '/=', '//=', '%=', '**='];
    
    for (final pattern in patterns) {
      if (line.contains(pattern)) {
        final parts = line.split(pattern);
        if (parts.length != 2) continue;

        final varName = parts[0].trim();
        final expression = parts[1].trim();

        if (!_variables.containsKey(varName)) {
          _error = "Variable '$varName' is not defined";
          return;
        }

        final currentValue = _variables[varName];
        final addValue = _evaluateExpression(expression);

        dynamic newValue;
        switch (pattern) {
          case '+=':
            if (currentValue is String && addValue is String) {
              newValue = currentValue + addValue;
            } else if (currentValue is List) {
              newValue = [...currentValue, addValue];
            } else {
              newValue = (currentValue as num) + (addValue as num);
            }
            break;
          case '-=':
            newValue = (currentValue as num) - (addValue as num);
            break;
          case '*=':
            if (currentValue is String && addValue is int) {
              newValue = currentValue * addValue;
            } else {
              newValue = (currentValue as num) * (addValue as num);
            }
            break;
          case '/=':
            newValue = (currentValue as num) / (addValue as num);
            break;
          case '//=':
            newValue = (currentValue as num) ~/ (addValue as num);
            break;
          case '%=':
            newValue = (currentValue as num) % (addValue as num);
            break;
          case '**=':
            newValue = _power(currentValue as num, addValue as num);
            break;
        }

        _variables[varName] = newValue;
        return;
      }
    }
  }

  /// Handle multiple assignment
  void _handleMultipleAssignment(String line) {
    final parts = line.split('=');
    if (parts.length != 2) return;

    final varNames = parts[0].split(',').map((v) => v.trim()).toList();
    final expressions = parts[1].split(',').map((e) => e.trim()).toList();

    if (varNames.length != expressions.length) {
      _error = "Number of variables doesn't match number of values";
      return;
    }

    for (var i = 0; i < varNames.length; i++) {
      _variables[varNames[i]] = _evaluateExpression(expressions[i]);
    }
  }

  /// Evaluate an expression and return its value
  dynamic _evaluateExpression(String expr) {
    expr = expr.trim();

    // Empty expression
    if (expr.isEmpty) return null;

    // Boolean literals
    if (expr == 'True') return true;
    if (expr == 'False') return false;
    if (expr == 'None') return null;

    // String literal
    if ((expr.startsWith('"') && expr.endsWith('"')) ||
        (expr.startsWith("'") && expr.endsWith("'"))) {
      return _processEscapeSequences(expr.substring(1, expr.length - 1));
    }

    // f-string
    if ((expr.startsWith('f"') && expr.endsWith('"')) ||
        (expr.startsWith("f'") && expr.endsWith("'"))) {
      return _processEscapeSequences(_evaluateFString(expr.substring(2, expr.length - 1)));
    }

    // List literal
    if (expr.startsWith('[') && expr.endsWith(']')) {
      return _evaluateList(expr);
    }

    // Tuple/parens expression
    if (expr.startsWith('(') && expr.endsWith(')')) {
      final inner = expr.substring(1, expr.length - 1).trim();
      if (inner.contains(',')) {
        return _parseArguments(inner).map((e) => _evaluateExpression(e)).toList();
      }
      return _evaluateExpression(inner);
    }

    // Integer
    final intValue = int.tryParse(expr);
    if (intValue != null) return intValue;

    // Float
    final floatValue = double.tryParse(expr);
    if (floatValue != null) return floatValue;

    // Variable reference
    if (_isValidVariableName(expr) && _variables.containsKey(expr)) {
      return _variables[expr];
    }

    // len() function
    if (expr.startsWith('len(') && expr.endsWith(')')) {
      final arg = expr.substring(4, expr.length - 1);
      final value = _evaluateExpression(arg);
      if (value is String) return value.length;
      if (value is List) return value.length;
      return 0;
    }

    // str() function
    if (expr.startsWith('str(') && expr.endsWith(')')) {
      final arg = expr.substring(4, expr.length - 1);
      return _formatValue(_evaluateExpression(arg));
    }

    // int() function
    if (expr.startsWith('int(') && expr.endsWith(')')) {
      final arg = expr.substring(4, expr.length - 1);
      final value = _evaluateExpression(arg);
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      if (value is int) return value;
      return 0;
    }

    // float() function
    if (expr.startsWith('float(') && expr.endsWith(')')) {
      final arg = expr.substring(6, expr.length - 1);
      final value = _evaluateExpression(arg);
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    // type() function
    if (expr.startsWith('type(') && expr.endsWith(')')) {
      final arg = expr.substring(5, expr.length - 1);
      final value = _evaluateExpression(arg);
      return _getTypeName(value);
    }

    // input() function - return empty string for now
    if (expr.startsWith('input(')) {
      return '';
    }

    // range() function
    if (expr.startsWith('range(') && expr.endsWith(')')) {
      return _evaluateRange(expr);
    }

    // String methods
    if (expr.contains('.upper()')) {
      final varPart = expr.substring(0, expr.indexOf('.upper()'));
      final value = _evaluateExpression(varPart);
      if (value is String) return value.toUpperCase();
    }
    if (expr.contains('.lower()')) {
      final varPart = expr.substring(0, expr.indexOf('.lower()'));
      final value = _evaluateExpression(varPart);
      if (value is String) return value.toLowerCase();
    }
    if (expr.contains('.strip()') || expr.contains('.trim()')) {
      final method = expr.contains('.strip()') ? '.strip()' : '.trim()';
      final varPart = expr.substring(0, expr.indexOf(method));
      final value = _evaluateExpression(varPart);
      if (value is String) return value.trim();
    }

    // List indexing
    if (expr.contains('[') && expr.endsWith(']')) {
      return _evaluateIndexing(expr);
    }

    // Comparison operators
    if (expr.contains('==') || expr.contains('!=') ||
        expr.contains('<=') || expr.contains('>=') ||
        expr.contains('<') || expr.contains('>')) {
      return _evaluateComparison(expr);
    }

    // Logical operators
    if (expr.contains(' and ') || expr.contains(' or ') || expr.startsWith('not ')) {
      return _evaluateLogical(expr);
    }

    // String concatenation or arithmetic
    if (expr.contains('+') || expr.contains('-') ||
        expr.contains('*') || expr.contains('/') ||
        expr.contains('%') || expr.contains('**') ||
        expr.contains('//')) {
      return _evaluateArithmetic(expr);
    }

    // Unknown - try as variable
    if (_variables.containsKey(expr)) {
      return _variables[expr];
    }

    return expr; // Return as-is if can't evaluate
  }

  /// Evaluate f-string
  String _evaluateFString(String content) {
    final result = StringBuffer();
    var i = 0;
    
    while (i < content.length) {
      if (content[i] == '{' && (i + 1 < content.length) && content[i + 1] != '{') {
        // Find matching closing brace
        var depth = 1;
        var j = i + 1;
        while (j < content.length && depth > 0) {
          if (content[j] == '{') depth++;
          if (content[j] == '}') depth--;
          j++;
        }
        
        final expr = content.substring(i + 1, j - 1);
        final value = _evaluateExpression(expr);
        result.write(_formatValue(value));
        i = j;
      } else if (content[i] == '{' && (i + 1 < content.length) && content[i + 1] == '{') {
        result.write('{');
        i += 2;
      } else if (content[i] == '}' && (i + 1 < content.length) && content[i + 1] == '}') {
        result.write('}');
        i += 2;
      } else {
        result.write(content[i]);
        i++;
      }
    }
    
    return result.toString();
  }

  /// Evaluate list literal
  List<dynamic> _evaluateList(String expr) {
    final content = expr.substring(1, expr.length - 1).trim();
    if (content.isEmpty) return [];
    
    final items = _parseArguments(content);
    return items.map((item) => _evaluateExpression(item)).toList();
  }

  /// Evaluate indexing (list[0] or string[0])
  dynamic _evaluateIndexing(String expr) {
    final bracketIndex = expr.lastIndexOf('[');
    final varPart = expr.substring(0, bracketIndex);
    final indexPart = expr.substring(bracketIndex + 1, expr.length - 1);
    
    final value = _evaluateExpression(varPart);
    final index = _evaluateExpression(indexPart);
    
    if (value is List && index is int) {
      final actualIndex = index < 0 ? value.length + index : index;
      if (actualIndex >= 0 && actualIndex < value.length) {
        return value[actualIndex];
      }
    }
    
    if (value is String && index is int) {
      final actualIndex = index < 0 ? value.length + index : index;
      if (actualIndex >= 0 && actualIndex < value.length) {
        return value[actualIndex];
      }
    }
    
    return null;
  }

  /// Evaluate range() function
  List<int> _evaluateRange(String expr) {
    final content = expr.substring(6, expr.length - 1);
    final args = _parseArguments(content).map((a) => _evaluateExpression(a) as int).toList();
    
    int start = 0, stop = 0, step = 1;
    
    if (args.length == 1) {
      stop = args[0];
    } else if (args.length == 2) {
      start = args[0];
      stop = args[1];
    } else if (args.length >= 3) {
      start = args[0];
      stop = args[1];
      step = args[2];
    }
    
    final result = <int>[];
    if (step > 0) {
      for (var i = start; i < stop; i += step) {
        result.add(i);
      }
    } else if (step < 0) {
      for (var i = start; i > stop; i += step) {
        result.add(i);
      }
    }
    
    return result;
  }

  /// Evaluate comparison expressions
  bool _evaluateComparison(String expr) {
    // Handle chained comparisons like 1 < x < 10
    final operators = ['==', '!=', '<=', '>=', '<', '>'];
    
    for (final op in operators) {
      if (expr.contains(op)) {
        final parts = expr.split(op);
        if (parts.length >= 2) {
          final left = _evaluateExpression(parts[0]);
          final right = _evaluateExpression(parts[1]);
          
          switch (op) {
            case '==': return left == right;
            case '!=': return left != right;
            case '<': return (left as num) < (right as num);
            case '>': return (left as num) > (right as num);
            case '<=': return (left as num) <= (right as num);
            case '>=': return (left as num) >= (right as num);
          }
        }
      }
    }
    
    return false;
  }

  /// Evaluate logical expressions (and, or, not)
  bool _evaluateLogical(String expr) {
    if (expr.startsWith('not ')) {
      final value = _evaluateExpression(expr.substring(4));
      return !_isTruthy(value);
    }
    
    if (expr.contains(' and ')) {
      final parts = expr.split(' and ');
      return parts.every((p) => _isTruthy(_evaluateExpression(p)));
    }
    
    if (expr.contains(' or ')) {
      final parts = expr.split(' or ');
      return parts.any((p) => _isTruthy(_evaluateExpression(p)));
    }
    
    return _isTruthy(_evaluateExpression(expr));
  }

  /// Evaluate arithmetic expression
  dynamic _evaluateArithmetic(String expr) {
    expr = expr.trim();
    
    // Handle power operator first (highest precedence after parens)
    if (expr.contains('**')) {
      final parts = _splitByOperator(expr, '**');
      if (parts.length == 2) {
        final left = _evaluateExpression(parts[0]) as num;
        final right = _evaluateExpression(parts[1]) as num;
        return _power(left, right);
      }
    }
    
    // Handle floor division
    if (expr.contains('//')) {
      final parts = _splitByOperator(expr, '//');
      if (parts.length == 2) {
        final left = _evaluateExpression(parts[0]) as num;
        final right = _evaluateExpression(parts[1]) as num;
        return left ~/ right;
      }
    }
    
    // Handle modulo
    if (expr.contains('%')) {
      final parts = _splitByOperator(expr, '%');
      if (parts.length == 2) {
        final left = _evaluateExpression(parts[0]) as num;
        final right = _evaluateExpression(parts[1]) as num;
        return left % right;
      }
    }
    
    // Handle addition (including string concatenation)
    if (expr.contains('+')) {
      final parts = _splitByOperator(expr, '+');
      if (parts.length >= 2) {
        var result = _evaluateExpression(parts[0]);
        for (var i = 1; i < parts.length; i++) {
          final right = _evaluateExpression(parts[i]);
          if (result is String || right is String) {
            result = _formatValue(result) + _formatValue(right);
          } else if (result is List) {
            result = [...result, ...(right is List ? right : [right])];
          } else {
            result = (result as num) + (right as num);
          }
        }
        return result;
      }
    }
    
    // Handle subtraction
    if (expr.contains('-')) {
      // Be careful with negative numbers
      final parts = _splitByOperator(expr, '-');
      if (parts.length >= 2) {
        var result = _evaluateExpression(parts[0]) as num;
        for (var i = 1; i < parts.length; i++) {
          result = result - (_evaluateExpression(parts[i]) as num);
        }
        return result;
      }
    }
    
    // Handle multiplication
    if (expr.contains('*')) {
      final parts = _splitByOperator(expr, '*');
      if (parts.length >= 2) {
        var result = _evaluateExpression(parts[0]);
        for (var i = 1; i < parts.length; i++) {
          final right = _evaluateExpression(parts[i]);
          if (result is String && right is int) {
            result = result * right;
          } else {
            result = (result as num) * (right as num);
          }
        }
        return result;
      }
    }
    
    // Handle division
    if (expr.contains('/')) {
      final parts = _splitByOperator(expr, '/');
      if (parts.length >= 2) {
        var result = (_evaluateExpression(parts[0]) as num).toDouble();
        for (var i = 1; i < parts.length; i++) {
          result = result / (_evaluateExpression(parts[i]) as num);
        }
        return result;
      }
    }
    
    return _evaluateExpression(expr);
  }

  /// Split expression by operator, respecting parentheses and strings
  List<String> _splitByOperator(String expr, String op) {
    final parts = <String>[];
    var current = StringBuffer();
    var parenDepth = 0;
    var inString = false;
    String? stringChar;
    
    for (var i = 0; i < expr.length; i++) {
      final char = expr[i];
      
      // Handle strings
      if ((char == '"' || char == "'") && (i == 0 || expr[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
      }
      
      if (!inString) {
        if (char == '(' || char == '[') parenDepth++;
        if (char == ')' || char == ']') parenDepth--;
        
        // Check for operator
        if (parenDepth == 0 && expr.substring(i).startsWith(op)) {
          // Don't split ** when looking for *
          if (op == '*' && i + 1 < expr.length && expr[i + 1] == '*') {
            current.write(char);
            continue;
          }
          // Don't split // when looking for /
          if (op == '/' && i + 1 < expr.length && expr[i + 1] == '/') {
            current.write(char);
            continue;
          }
          
          parts.add(current.toString());
          current = StringBuffer();
          i += op.length - 1;
          continue;
        }
      }
      
      current.write(char);
    }
    
    if (current.isNotEmpty) {
      parts.add(current.toString());
    }
    
    return parts;
  }

  /// Handle if statement
  int _handleIf(List<String> lines, int startIndex, int endIndex) {
    final ifLine = lines[startIndex].trim();
    
    // Parse condition
    final conditionMatch = RegExp(r'if\s+(.+?)\s*:').firstMatch(ifLine);
    if (conditionMatch == null) return startIndex + 1;
    
    final condition = conditionMatch.group(1)!;
    final conditionResult = _isTruthy(_evaluateExpression(condition));
    
    // Find if block
    final ifIndent = _getIndent(lines[startIndex]);
    var ifBlockEnd = startIndex + 1;
    
    while (ifBlockEnd < endIndex) {
      final lineIndent = _getIndent(lines[ifBlockEnd]);
      final trimmedLine = lines[ifBlockEnd].trim();
      
      if (trimmedLine.isNotEmpty && lineIndent <= ifIndent) {
        // Check for elif/else
        if (!trimmedLine.startsWith('elif ') && !trimmedLine.startsWith('else:')) {
          break;
        }
        break;
      }
      ifBlockEnd++;
    }
    
    // Execute if block if condition is true
    if (conditionResult) {
      _executeLines(lines, startIndex + 1, ifBlockEnd);
      // Skip any elif/else blocks
      return _skipElifElse(lines, ifBlockEnd, endIndex, ifIndent);
    }
    
    // Look for elif/else
    return _handleElifElse(lines, ifBlockEnd, endIndex, ifIndent);
  }

  /// Skip elif/else blocks after if was executed
  int _skipElifElse(List<String> lines, int startIndex, int endIndex, int baseIndent) {
    var i = startIndex;
    
    while (i < endIndex) {
      final line = lines[i].trim();
      final indent = _getIndent(lines[i]);
      
      if (indent < baseIndent || (indent == baseIndent && !line.startsWith('elif ') && !line.startsWith('else:'))) {
        break;
      }
      
      if (indent == baseIndent && (line.startsWith('elif ') || line.startsWith('else:'))) {
        // Skip this block
        i++;
        while (i < endIndex) {
          final blockIndent = _getIndent(lines[i]);
          if (lines[i].trim().isNotEmpty && blockIndent <= baseIndent) {
            break;
          }
          i++;
        }
      } else {
        i++;
      }
    }
    
    return i;
  }

  /// Handle elif/else blocks
  int _handleElifElse(List<String> lines, int startIndex, int endIndex, int baseIndent) {
    var i = startIndex;
    
    while (i < endIndex) {
      final line = lines[i].trim();
      final indent = _getIndent(lines[i]);
      
      if (indent != baseIndent) {
        break;
      }
      
      // elif
      if (line.startsWith('elif ')) {
        final conditionMatch = RegExp(r'elif\s+(.+?)\s*:').firstMatch(line);
        if (conditionMatch != null) {
          final condition = conditionMatch.group(1)!;
          final conditionResult = _isTruthy(_evaluateExpression(condition));
          
          // Find block end
          var blockEnd = i + 1;
          while (blockEnd < endIndex) {
            final blockIndent = _getIndent(lines[blockEnd]);
            final blockLine = lines[blockEnd].trim();
            if (blockLine.isNotEmpty && blockIndent <= baseIndent) {
              break;
            }
            blockEnd++;
          }
          
          if (conditionResult) {
            _executeLines(lines, i + 1, blockEnd);
            return _skipElifElse(lines, blockEnd, endIndex, baseIndent);
          }
          
          i = blockEnd;
          continue;
        }
      }
      
      // else
      if (line.startsWith('else:')) {
        var blockEnd = i + 1;
        while (blockEnd < endIndex) {
          final blockIndent = _getIndent(lines[blockEnd]);
          if (lines[blockEnd].trim().isNotEmpty && blockIndent <= baseIndent) {
            break;
          }
          blockEnd++;
        }
        
        _executeLines(lines, i + 1, blockEnd);
        return blockEnd;
      }
      
      break;
    }
    
    return i;
  }

  /// Handle for loop
  int _handleFor(List<String> lines, int startIndex, int endIndex) {
    final forLine = lines[startIndex].trim();
    
    // Parse: for var in iterable:
    final match = RegExp(r'for\s+(\w+)\s+in\s+(.+?)\s*:').firstMatch(forLine);
    if (match == null) return startIndex + 1;
    
    final varName = match.group(1)!;
    final iterableExpr = match.group(2)!;
    
    // Get iterable
    final iterable = _evaluateExpression(iterableExpr);
    
    // Find block end
    final baseIndent = _getIndent(lines[startIndex]);
    var blockEnd = startIndex + 1;
    while (blockEnd < endIndex) {
      final indent = _getIndent(lines[blockEnd]);
      if (lines[blockEnd].trim().isNotEmpty && indent <= baseIndent) {
        break;
      }
      blockEnd++;
    }
    
    // Execute loop
    if (iterable is List || iterable is String) {
      final items = iterable is String ? iterable.split('') : (iterable as List);
      for (final item in items) {
        _variables[varName] = item;
        _executeLines(lines, startIndex + 1, blockEnd);
      }
    }
    
    return blockEnd;
  }

  /// Handle while loop
  int _handleWhile(List<String> lines, int startIndex, int endIndex) {
    final whileLine = lines[startIndex].trim();
    
    // Parse: while condition:
    final match = RegExp(r'while\s+(.+?)\s*:').firstMatch(whileLine);
    if (match == null) return startIndex + 1;
    
    final conditionExpr = match.group(1)!;
    
    // Find block end
    final baseIndent = _getIndent(lines[startIndex]);
    var blockEnd = startIndex + 1;
    while (blockEnd < endIndex) {
      final indent = _getIndent(lines[blockEnd]);
      if (lines[blockEnd].trim().isNotEmpty && indent <= baseIndent) {
        break;
      }
      blockEnd++;
    }
    
    // Execute loop (with safety limit)
    var iterations = 0;
    const maxIterations = 1000;
    
    while (_isTruthy(_evaluateExpression(conditionExpr)) && iterations < maxIterations) {
      _executeLines(lines, startIndex + 1, blockEnd);
      iterations++;
    }
    
    if (iterations >= maxIterations) {
      _error = "Loop exceeded maximum iterations (possible infinite loop)";
    }
    
    return blockEnd;
  }

  /// Get indentation level of a line
  int _getIndent(String line) {
    var indent = 0;
    for (final char in line.split('')) {
      if (char == ' ') indent++;
      else if (char == '\t') indent += 4;
      else break;
    }
    return indent;
  }

  /// Check if value is truthy
  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  /// Format value for output
  /// Process escape sequences in strings
  String _processEscapeSequences(String s) {
    return s
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .replaceAll('\\r', '\r')
        .replaceAll("\\'", "'")
        .replaceAll('\\"', '"')
        .replaceAll('\\\\', '\\');
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'None';
    if (value is bool) return value ? 'True' : 'False';
    if (value is int) return value.toString();
    if (value is double) {
      // Format like Python - integers stored as double show without .0
      if (value == value.toInt()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    if (value is List) {
      final items = value.map((v) {
        if (v is String) return "'$v'";
        return _formatValue(v);
      }).join(', ');
      return '[$items]';
    }
    return value.toString();
  }

  /// Get Python type name
  String _getTypeName(dynamic value) {
    if (value == null) return "<class 'NoneType'>";
    if (value is bool) return "<class 'bool'>";
    if (value is int) return "<class 'int'>";
    if (value is double) return "<class 'float'>";
    if (value is String) return "<class 'str'>";
    if (value is List) return "<class 'list'>";
    return "<class 'object'>";
  }

  /// Calculate power
  num _power(num base, num exponent) {
    if (exponent is int && exponent >= 0) {
      num result = 1;
      for (var i = 0; i < exponent; i++) {
        result *= base;
      }
      return result;
    }
    return _pow(base.toDouble(), exponent.toDouble());
  }

  double _pow(double base, double exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return base;
    if (exponent < 0) return 1 / _pow(base, -exponent);
    if (exponent == exponent.toInt()) {
      double result = 1;
      for (var i = 0; i < exponent.toInt(); i++) {
        result *= base;
      }
      return result;
    }
    // For non-integer exponents, use approximation
    return _expApprox(exponent * _lnApprox(base));
  }

  double _lnApprox(double x) {
    if (x <= 0) return double.negativeInfinity;
    double result = 0;
    while (x > 2) { x /= 2.718281828; result++; }
    while (x < 0.5) { x *= 2.718281828; result--; }
    x--;
    double term = x;
    for (int n = 1; n <= 20; n++) {
      result += (n % 2 == 1 ? 1 : -1) * term / n;
      term *= x;
    }
    return result;
  }

  double _expApprox(double x) {
    double result = 1;
    double term = 1;
    for (int n = 1; n <= 20; n++) {
      term *= x / n;
      result += term;
    }
    return result;
  }

  /// Check if string is valid variable name
  bool _isValidVariableName(String name) {
    if (name.isEmpty) return false;
    if (RegExp(r'^\d').hasMatch(name)) return false;
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name);
  }
}

/// Result of code interpretation
class InterpreterResult {
  final String output;
  final String? error;
  final Map<String, dynamic> variables;

  InterpreterResult({
    required this.output,
    this.error,
    required this.variables,
  });

  bool get hasError => error != null;
  bool get isSuccess => !hasError;
}
