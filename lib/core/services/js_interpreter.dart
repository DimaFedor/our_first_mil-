/// Simple JavaScript interpreter for code challenges
/// Handles basic JS syntax: variables, console.log(), arithmetic, strings, arrays, objects, conditionals
class JSInterpreter {
  final Map<String, dynamic> _variables = {};
  final List<String> _output = [];
  String? _error;

  /// Execute JavaScript code and return the result
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
    
    // Common JavaScript error translations
    final errorPatterns = {
      'undefined': '❌ ReferenceError: Variable is not defined\n💡 Hint: Make sure you declared the variable with let, const, or var.',
      'is not a function': '❌ TypeError: Not a function\n💡 Hint: Check if you\'re calling a function correctly.',
      'cannot read property': '❌ TypeError: Cannot read property of undefined\n💡 Hint: The object might be undefined or null.',
      'unexpected token': '❌ SyntaxError: Unexpected token\n💡 Hint: Check for missing brackets, parentheses, or semicolons.',
      'invalid syntax': '❌ SyntaxError: Invalid syntax\n💡 Hint: Check your code structure.',
    };
    
    for (final pattern in errorPatterns.entries) {
      if (error.toLowerCase().contains(pattern.key)) {
        return pattern.value;
      }
    }
    
    return '❌ Error: $error\n💡 Hint: Check your code for typos or syntax errors.';
  }

  /// Preprocess code - remove comments, normalize
  List<String> _preprocessCode(String code) {
    final lines = <String>[];
    var inMultilineComment = false;
    
    for (var line in code.split('\n')) {
      // Handle multiline comments
      if (inMultilineComment) {
        final endIndex = line.indexOf('*/');
        if (endIndex >= 0) {
          line = line.substring(endIndex + 2);
          inMultilineComment = false;
        } else {
          continue;
        }
      }
      
      // Remove multiline comment starts
      while (line.contains('/*')) {
        final startIndex = line.indexOf('/*');
        final endIndex = line.indexOf('*/', startIndex);
        if (endIndex >= 0) {
          line = line.substring(0, startIndex) + line.substring(endIndex + 2);
        } else {
          line = line.substring(0, startIndex);
          inMultilineComment = true;
          break;
        }
      }
      
      // Remove single-line comments
      final commentIndex = line.indexOf('//');
      if (commentIndex >= 0) {
        final beforeComment = line.substring(0, commentIndex);
        final singleQuotes = "'".allMatches(beforeComment).length;
        final doubleQuotes = '"'.allMatches(beforeComment).length;
        final backticks = '`'.allMatches(beforeComment).length;
        if (singleQuotes % 2 == 0 && doubleQuotes % 2 == 0 && backticks % 2 == 0) {
          line = beforeComment;
        }
      }
      
      line = line.trimRight();
      // Remove trailing semicolons for easier parsing
      if (line.endsWith(';')) {
        line = line.substring(0, line.length - 1).trimRight();
      }
      
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
      if (_error != null) return;
      
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        i++;
        continue;
      }

      // console.log() statement
      if (line.startsWith('console.log(') && line.endsWith(')')) {
        _handleConsoleLog(line);
        i++;
        continue;
      }

      // Variable declaration: let, const, var
      if (line.startsWith('let ') || line.startsWith('const ') || line.startsWith('var ')) {
        _handleVariableDeclaration(line);
        i++;
        continue;
      }

      // If statement
      if (line.startsWith('if ') || line.startsWith('if(')) {
        i = _handleIfStatement(lines, i, end);
        continue;
      }

      // For loop
      if (line.startsWith('for ') || line.startsWith('for(')) {
        i = _handleForLoop(lines, i, end);
        continue;
      }

      // While loop
      if (line.startsWith('while ') || line.startsWith('while(')) {
        i = _handleWhileLoop(lines, i, end);
        continue;
      }

      // Function declaration
      if (line.startsWith('function ')) {
        i = _handleFunctionDeclaration(lines, i, end);
        continue;
      }

      // Arrow function assignment
      if (_isArrowFunctionAssignment(line)) {
        _handleArrowFunction(line);
        i++;
        continue;
      }

      // Assignment (variable = value)
      if (_isAssignment(line)) {
        _handleAssignment(line);
        i++;
        continue;
      }

      // Augmented assignment (+=, -=, etc.)
      if (_isAugmentedAssignment(line)) {
        _handleAugmentedAssignment(line);
        i++;
        continue;
      }

      // Increment/Decrement (i++, i--, ++i, --i)
      if (_isIncrementDecrement(line)) {
        _handleIncrementDecrement(line);
        i++;
        continue;
      }

      // Method call on variable (arr.push(), str.toUpperCase())
      if (_isMethodCall(line)) {
        _handleMethodCall(line);
        i++;
        continue;
      }

      // Function call
      if (_isFunctionCall(line)) {
        _handleFunctionCall(line);
        i++;
        continue;
      }

      i++;
    }
  }

  /// Handle console.log() statements
  void _handleConsoleLog(String line) {
    final content = line.substring(12, line.length - 1).trim();
    
    if (content.isEmpty) {
      _output.add('');
      return;
    }

    final args = _parseArguments(content);
    final outputParts = <String>[];

    for (var arg in args) {
      arg = arg.trim();
      final value = _evaluateExpression(arg);
      outputParts.add(_formatValue(value));
    }

    _output.add(outputParts.join(' '));
  }

  /// Handle variable declarations (let, const, var)
  void _handleVariableDeclaration(String line) {
    String declaration;
    if (line.startsWith('let ')) {
      declaration = line.substring(4);
    } else if (line.startsWith('const ')) {
      declaration = line.substring(6);
    } else {
      declaration = line.substring(4); // var
    }

    // Handle multiple declarations: let a = 1, b = 2
    final declarations = _splitDeclarations(declaration);
    
    for (final decl in declarations) {
      if (decl.contains('=')) {
        final eqIndex = decl.indexOf('=');
        final varName = decl.substring(0, eqIndex).trim();
        final expression = decl.substring(eqIndex + 1).trim();
        
        if (!_isValidVariableName(varName)) {
          _error = "Invalid variable name: $varName";
          return;
        }
        
        _variables[varName] = _evaluateExpression(expression);
      } else {
        final varName = decl.trim();
        if (_isValidVariableName(varName)) {
          _variables[varName] = null; // undefined
        }
      }
    }
  }

  /// Split multiple variable declarations
  List<String> _splitDeclarations(String declaration) {
    final result = <String>[];
    var current = StringBuffer();
    var depth = 0;
    var inString = false;
    String? stringChar;

    for (var i = 0; i < declaration.length; i++) {
      final char = declaration[i];

      if ((char == '"' || char == "'" || char == '`') && 
          (i == 0 || declaration[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
      }

      if (!inString) {
        if (char == '(' || char == '[' || char == '{') depth++;
        if (char == ')' || char == ']' || char == '}') depth--;

        if (char == ',' && depth == 0) {
          result.add(current.toString());
          current = StringBuffer();
          continue;
        }
      }

      current.write(char);
    }

    if (current.isNotEmpty) {
      result.add(current.toString());
    }

    return result;
  }

  /// Handle regular assignment
  void _handleAssignment(String line) {
    final eqIndex = _findAssignmentIndex(line);
    if (eqIndex < 0) return;

    final varName = line.substring(0, eqIndex).trim();
    final expression = line.substring(eqIndex + 1).trim();

    // Handle array index assignment: arr[0] = value
    if (varName.contains('[') && varName.endsWith(']')) {
      _handleIndexAssignment(varName, expression);
      return;
    }

    // Handle object property assignment: obj.prop = value
    if (varName.contains('.')) {
      _handlePropertyAssignment(varName, expression);
      return;
    }

    if (!_isValidVariableName(varName)) {
      _error = "Invalid variable name: $varName";
      return;
    }

    _variables[varName] = _evaluateExpression(expression);
  }

  /// Find the assignment index (= but not ==, ===, !=, etc.)
  int _findAssignmentIndex(String line) {
    var inString = false;
    String? stringChar;
    var depth = 0;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if ((char == '"' || char == "'" || char == '`') && 
          (i == 0 || line[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
      }

      if (!inString) {
        if (char == '(' || char == '[' || char == '{') depth++;
        if (char == ')' || char == ']' || char == '}') depth--;

        if (char == '=' && depth == 0) {
          // Check it's not ==, ===, !=, !==, <=, >=, =>
          final prev = i > 0 ? line[i - 1] : '';
          final next = i < line.length - 1 ? line[i + 1] : '';
          
          if (prev != '=' && prev != '!' && prev != '<' && prev != '>' &&
              next != '=' && next != '>') {
            return i;
          }
        }
      }
    }

    return -1;
  }

  /// Handle array index assignment
  void _handleIndexAssignment(String varName, String expression) {
    final bracketIndex = varName.indexOf('[');
    final arrName = varName.substring(0, bracketIndex);
    final indexStr = varName.substring(bracketIndex + 1, varName.length - 1);
    
    final arr = _variables[arrName];
    final index = _evaluateExpression(indexStr);
    final value = _evaluateExpression(expression);

    if (arr is List && index is int) {
      if (index >= 0 && index < arr.length) {
        arr[index] = value;
      } else if (index >= arr.length) {
        // Extend array
        while (arr.length <= index) {
          arr.add(null);
        }
        arr[index] = value;
      }
    } else if (arr is Map && index != null) {
      arr[index.toString()] = value;
    }
  }

  /// Handle object property assignment
  void _handlePropertyAssignment(String varName, String expression) {
    final parts = varName.split('.');
    final objName = parts[0];
    
    var obj = _variables[objName];
    if (obj is! Map) return;

    final value = _evaluateExpression(expression);
    
    if (parts.length == 2) {
      obj[parts[1]] = value;
    } else {
      // Nested property
      for (var i = 1; i < parts.length - 1; i++) {
        obj = obj[parts[i]];
        if (obj is! Map) return;
      }
      obj[parts.last] = value;
    }
  }

  /// Handle augmented assignment (+=, -=, etc.)
  void _handleAugmentedAssignment(String line) {
    final patterns = ['+=', '-=', '*=', '/=', '%=', '**='];
    
    for (final pattern in patterns) {
      final index = line.indexOf(pattern);
      if (index > 0) {
        final varName = line.substring(0, index).trim();
        final expression = line.substring(index + pattern.length).trim();

        if (!_variables.containsKey(varName)) {
          _error = "Variable '$varName' is not defined";
          return;
        }

        final currentValue = _variables[varName];
        final addValue = _evaluateExpression(expression);

        dynamic newValue;
        switch (pattern) {
          case '+=':
            if (currentValue is String) {
              newValue = currentValue + _formatValue(addValue);
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
            newValue = (currentValue as num) * (addValue as num);
            break;
          case '/=':
            newValue = (currentValue as num) / (addValue as num);
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

  /// Handle increment/decrement (i++, i--, ++i, --i)
  void _handleIncrementDecrement(String line) {
    if (line.endsWith('++')) {
      final varName = line.substring(0, line.length - 2).trim();
      if (_variables.containsKey(varName)) {
        _variables[varName] = (_variables[varName] as num) + 1;
      }
    } else if (line.endsWith('--')) {
      final varName = line.substring(0, line.length - 2).trim();
      if (_variables.containsKey(varName)) {
        _variables[varName] = (_variables[varName] as num) - 1;
      }
    } else if (line.startsWith('++')) {
      final varName = line.substring(2).trim();
      if (_variables.containsKey(varName)) {
        _variables[varName] = (_variables[varName] as num) + 1;
      }
    } else if (line.startsWith('--')) {
      final varName = line.substring(2).trim();
      if (_variables.containsKey(varName)) {
        _variables[varName] = (_variables[varName] as num) - 1;
      }
    }
  }

  /// Handle method calls on variables
  void _handleMethodCall(String line) {
    // Extract variable and method
    final dotIndex = line.indexOf('.');
    if (dotIndex < 0) return;

    final varName = line.substring(0, dotIndex);
    final methodPart = line.substring(dotIndex + 1);

    if (!_variables.containsKey(varName)) return;

    var value = _variables[varName];

    // Parse method name and args
    final parenIndex = methodPart.indexOf('(');
    if (parenIndex < 0) return;

    final methodName = methodPart.substring(0, parenIndex);
    final argsStr = methodPart.substring(parenIndex + 1, methodPart.length - 1);
    final args = argsStr.isEmpty ? <dynamic>[] : _parseArguments(argsStr).map((a) => _evaluateExpression(a)).toList();

    // Array methods
    if (value is List) {
      switch (methodName) {
        case 'push':
          value.addAll(args);
          break;
        case 'pop':
          if (value.isNotEmpty) value.removeLast();
          break;
        case 'shift':
          if (value.isNotEmpty) value.removeAt(0);
          break;
        case 'unshift':
          value.insertAll(0, args);
          break;
        case 'splice':
          if (args.isNotEmpty) {
            final start = args[0] as int;
            final deleteCount = args.length > 1 ? args[1] as int : value.length - start;
            value.removeRange(start, start + deleteCount);
            if (args.length > 2) {
              value.insertAll(start, args.sublist(2));
            }
          }
          break;
        case 'reverse':
          _variables[varName] = value.reversed.toList();
          break;
        case 'sort':
          value.sort();
          break;
      }
    }

    // String methods (modify if stored)
    if (value is String) {
      String? newValue;
      switch (methodName) {
        case 'toUpperCase':
          newValue = value.toUpperCase();
          break;
        case 'toLowerCase':
          newValue = value.toLowerCase();
          break;
        case 'trim':
          newValue = value.trim();
          break;
      }
      if (newValue != null) {
        _variables[varName] = newValue;
      }
    }
  }

  /// Handle if statement
  int _handleIfStatement(List<String> lines, int start, int end) {
    final line = lines[start].trim();
    
    // Extract condition
    final conditionStart = line.indexOf('(');
    final conditionEnd = _findMatchingParen(line, conditionStart);
    if (conditionStart < 0 || conditionEnd < 0) return start + 1;

    final condition = line.substring(conditionStart + 1, conditionEnd);
    final conditionResult = _isTruthy(_evaluateExpression(condition));

    // Find if block
    final ifBlockStart = start + 1;
    var ifBlockEnd = ifBlockStart;
    var braceDepth = 0;
    var foundBrace = line.contains('{');
    
    if (foundBrace) {
      braceDepth = 1;
      for (var i = ifBlockStart; i < end; i++) {
        final l = lines[i];
        braceDepth += '{'.allMatches(l).length;
        braceDepth -= '}'.allMatches(l).length;
        if (braceDepth == 0) {
          ifBlockEnd = i + 1;
          break;
        }
      }
    } else {
      ifBlockEnd = ifBlockStart + 1;
    }

    // Find else block
    var elseBlockStart = -1;
    var elseBlockEnd = -1;
    
    if (ifBlockEnd < end) {
      final nextLine = lines[ifBlockEnd - 1].trim();
      final afterBrace = ifBlockEnd < end ? lines[ifBlockEnd].trim() : '';
      
      if (nextLine.contains('else') || afterBrace.startsWith('else')) {
        elseBlockStart = ifBlockEnd;
        if (afterBrace.startsWith('else')) {
          elseBlockStart = ifBlockEnd;
        }
        
        // Find else block end
        if (elseBlockStart < end) {
          final elseLine = lines[elseBlockStart].trim();
          if (elseLine.contains('{')) {
            braceDepth = 1;
            for (var i = elseBlockStart + 1; i < end; i++) {
              final l = lines[i];
              braceDepth += '{'.allMatches(l).length;
              braceDepth -= '}'.allMatches(l).length;
              if (braceDepth == 0) {
                elseBlockEnd = i + 1;
                break;
              }
            }
          } else {
            elseBlockEnd = elseBlockStart + 2;
          }
        }
      }
    }

    if (conditionResult) {
      _executeLines(lines, ifBlockStart, ifBlockEnd - 1);
    } else if (elseBlockStart >= 0) {
      _executeLines(lines, elseBlockStart + 1, elseBlockEnd - 1);
    }

    return elseBlockEnd > 0 ? elseBlockEnd : ifBlockEnd;
  }

  /// Handle for loop
  int _handleForLoop(List<String> lines, int start, int end) {
    final line = lines[start].trim();
    
    final parenStart = line.indexOf('(');
    final parenEnd = _findMatchingParen(line, parenStart);
    if (parenStart < 0 || parenEnd < 0) return start + 1;

    final forContent = line.substring(parenStart + 1, parenEnd);

    // Find loop body
    final bodyStart = start + 1;
    var bodyEnd = bodyStart;
    
    if (line.contains('{')) {
      var braceDepth = 1;
      for (var i = bodyStart; i < end; i++) {
        final l = lines[i];
        braceDepth += '{'.allMatches(l).length;
        braceDepth -= '}'.allMatches(l).length;
        if (braceDepth == 0) {
          bodyEnd = i;
          break;
        }
      }
    } else {
      bodyEnd = bodyStart + 1;
    }

    // Check for for...of loop
    if (forContent.contains(' of ')) {
      _executeForOfLoop(forContent, lines, bodyStart, bodyEnd);
    }
    // Check for for...in loop
    else if (forContent.contains(' in ')) {
      _executeForInLoop(forContent, lines, bodyStart, bodyEnd);
    }
    // Regular for loop
    else {
      _executeRegularForLoop(forContent, lines, bodyStart, bodyEnd);
    }

    return bodyEnd + 1;
  }

  /// Execute for...of loop
  void _executeForOfLoop(String forContent, List<String> lines, int bodyStart, int bodyEnd) {
    final parts = forContent.split(' of ');
    var varDecl = parts[0].trim();
    final iterableExpr = parts[1].trim();

    // Remove let/const/var
    if (varDecl.startsWith('let ')) varDecl = varDecl.substring(4);
    if (varDecl.startsWith('const ')) varDecl = varDecl.substring(6);
    if (varDecl.startsWith('var ')) varDecl = varDecl.substring(4);
    varDecl = varDecl.trim();

    final iterable = _evaluateExpression(iterableExpr);
    
    if (iterable is List) {
      for (final item in iterable) {
        _variables[varDecl] = item;
        _executeLines(lines, bodyStart, bodyEnd);
        if (_error != null) break;
      }
    } else if (iterable is String) {
      for (final char in iterable.split('')) {
        _variables[varDecl] = char;
        _executeLines(lines, bodyStart, bodyEnd);
        if (_error != null) break;
      }
    }
  }

  /// Execute for...in loop
  void _executeForInLoop(String forContent, List<String> lines, int bodyStart, int bodyEnd) {
    final parts = forContent.split(' in ');
    var varDecl = parts[0].trim();
    final objExpr = parts[1].trim();

    if (varDecl.startsWith('let ')) varDecl = varDecl.substring(4);
    if (varDecl.startsWith('const ')) varDecl = varDecl.substring(6);
    if (varDecl.startsWith('var ')) varDecl = varDecl.substring(4);
    varDecl = varDecl.trim();

    final obj = _evaluateExpression(objExpr);
    
    if (obj is Map) {
      for (final key in obj.keys) {
        _variables[varDecl] = key;
        _executeLines(lines, bodyStart, bodyEnd);
        if (_error != null) break;
      }
    } else if (obj is List) {
      for (var i = 0; i < obj.length; i++) {
        _variables[varDecl] = i;
        _executeLines(lines, bodyStart, bodyEnd);
        if (_error != null) break;
      }
    }
  }

  /// Execute regular for loop
  void _executeRegularForLoop(String forContent, List<String> lines, int bodyStart, int bodyEnd) {
    final parts = forContent.split(';');
    if (parts.length != 3) return;

    final init = parts[0].trim();
    final condition = parts[1].trim();
    final update = parts[2].trim();

    // Execute initialization
    if (init.isNotEmpty) {
      if (init.startsWith('let ') || init.startsWith('var ') || init.startsWith('const ')) {
        _handleVariableDeclaration(init);
      } else {
        _handleAssignment(init);
      }
    }

    // Loop
    var iterations = 0;
    const maxIterations = 1000;
    
    while (_isTruthy(_evaluateExpression(condition)) && iterations < maxIterations) {
      _executeLines(lines, bodyStart, bodyEnd);
      if (_error != null) break;

      // Execute update
      if (update.isNotEmpty) {
        if (_isIncrementDecrement(update)) {
          _handleIncrementDecrement(update);
        } else if (_isAugmentedAssignment(update)) {
          _handleAugmentedAssignment(update);
        } else {
          _handleAssignment(update);
        }
      }

      iterations++;
    }

    if (iterations >= maxIterations) {
      _error = "Loop exceeded maximum iterations";
    }
  }

  /// Handle while loop
  int _handleWhileLoop(List<String> lines, int start, int end) {
    final line = lines[start].trim();
    
    final parenStart = line.indexOf('(');
    final parenEnd = _findMatchingParen(line, parenStart);
    if (parenStart < 0 || parenEnd < 0) return start + 1;

    final condition = line.substring(parenStart + 1, parenEnd);

    // Find loop body
    final bodyStart = start + 1;
    var bodyEnd = bodyStart;
    
    if (line.contains('{')) {
      var braceDepth = 1;
      for (var i = bodyStart; i < end; i++) {
        final l = lines[i];
        braceDepth += '{'.allMatches(l).length;
        braceDepth -= '}'.allMatches(l).length;
        if (braceDepth == 0) {
          bodyEnd = i;
          break;
        }
      }
    } else {
      bodyEnd = bodyStart + 1;
    }

    var iterations = 0;
    const maxIterations = 1000;

    while (_isTruthy(_evaluateExpression(condition)) && iterations < maxIterations) {
      _executeLines(lines, bodyStart, bodyEnd);
      if (_error != null) break;
      iterations++;
    }

    if (iterations >= maxIterations) {
      _error = "Loop exceeded maximum iterations";
    }

    return bodyEnd + 1;
  }

  /// Handle function declaration
  int _handleFunctionDeclaration(List<String> lines, int start, int end) {
    final line = lines[start].trim();
    
    // Extract function name
    final nameStart = 9; // "function ".length
    final parenIndex = line.indexOf('(');
    final funcName = line.substring(nameStart, parenIndex).trim();
    
    // Extract parameters
    final parenEnd = line.indexOf(')');
    final paramsStr = line.substring(parenIndex + 1, parenEnd);
    final params = paramsStr.isEmpty ? <String>[] : paramsStr.split(',').map((p) => p.trim()).toList();

    // Find function body
    final bodyStart = start + 1;
    var bodyEnd = bodyStart;
    
    if (line.contains('{')) {
      var braceDepth = 1;
      for (var i = bodyStart; i < end; i++) {
        final l = lines[i];
        braceDepth += '{'.allMatches(l).length;
        braceDepth -= '}'.allMatches(l).length;
        if (braceDepth == 0) {
          bodyEnd = i;
          break;
        }
      }
    }

    // Store function
    _variables[funcName] = _JSFunction(params, lines.sublist(bodyStart, bodyEnd));

    return bodyEnd + 1;
  }

  /// Handle arrow function assignment
  void _handleArrowFunction(String line) {
    final eqIndex = line.indexOf('=');
    var varDecl = line.substring(0, eqIndex).trim();
    final arrowPart = line.substring(eqIndex + 1).trim();

    // Remove let/const/var
    if (varDecl.startsWith('let ')) varDecl = varDecl.substring(4);
    if (varDecl.startsWith('const ')) varDecl = varDecl.substring(6);
    if (varDecl.startsWith('var ')) varDecl = varDecl.substring(4);
    varDecl = varDecl.trim();

    // Parse arrow function: (params) => body or param => body
    final arrowIndex = arrowPart.indexOf('=>');
    var paramsStr = arrowPart.substring(0, arrowIndex).trim();
    var body = arrowPart.substring(arrowIndex + 2).trim();

    // Remove parentheses from params
    if (paramsStr.startsWith('(') && paramsStr.endsWith(')')) {
      paramsStr = paramsStr.substring(1, paramsStr.length - 1);
    }

    final params = paramsStr.isEmpty ? <String>[] : paramsStr.split(',').map((p) => p.trim()).toList();

    // Handle single expression body
    if (!body.startsWith('{')) {
      body = 'return $body';
    } else {
      body = body.substring(1, body.length - 1).trim();
    }

    _variables[varDecl] = _JSFunction(params, [body]);
  }

  /// Handle function call
  void _handleFunctionCall(String line) {
    final parenIndex = line.indexOf('(');
    final funcName = line.substring(0, parenIndex).trim();
    final argsStr = line.substring(parenIndex + 1, line.length - 1);
    
    _callFunction(funcName, argsStr);
  }

  /// Call a function
  dynamic _callFunction(String funcName, String argsStr) {
    final func = _variables[funcName];
    if (func is! _JSFunction) return null;

    final args = argsStr.isEmpty ? <dynamic>[] : _parseArguments(argsStr).map((a) => _evaluateExpression(a)).toList();

    // Set parameters
    for (var i = 0; i < func.params.length; i++) {
      _variables[func.params[i]] = i < args.length ? args[i] : null;
    }

    // Execute function body
    dynamic returnValue;
    for (final bodyLine in func.body) {
      if (bodyLine.trim().startsWith('return ')) {
        returnValue = _evaluateExpression(bodyLine.trim().substring(7));
        break;
      }
      _executeLines([bodyLine], 0, 1);
    }

    // Restore variables (keep global changes)
    for (final param in func.params) {
      _variables.remove(param);
    }

    return returnValue;
  }

  /// Evaluate expression
  dynamic _evaluateExpression(String expr) {
    expr = expr.trim();

    if (expr.isEmpty) return null;

    // Boolean literals
    if (expr == 'true') return true;
    if (expr == 'false') return false;
    if (expr == 'null') return null;
    if (expr == 'undefined') return null;

    // String literal
    if ((expr.startsWith('"') && expr.endsWith('"')) ||
        (expr.startsWith("'") && expr.endsWith("'"))) {
      return _processEscapeSequences(expr.substring(1, expr.length - 1));
    }

    // Template literal
    if (expr.startsWith('`') && expr.endsWith('`')) {
      return _evaluateTemplateLiteral(expr.substring(1, expr.length - 1));
    }

    // Array literal
    if (expr.startsWith('[') && expr.endsWith(']')) {
      return _evaluateArray(expr);
    }

    // Object literal
    if (expr.startsWith('{') && expr.endsWith('}')) {
      return _evaluateObject(expr);
    }

    // Parenthesized expression
    if (expr.startsWith('(') && expr.endsWith(')')) {
      return _evaluateExpression(expr.substring(1, expr.length - 1));
    }

    // Number
    final intValue = int.tryParse(expr);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(expr);
    if (doubleValue != null) return doubleValue;

    // Variable reference
    if (_isValidVariableName(expr) && _variables.containsKey(expr)) {
      return _variables[expr];
    }

    // Array methods that return values
    if (expr.contains('.') && expr.contains('(')) {
      return _evaluateMethodChain(expr);
    }

    // Property access
    if (expr.contains('.') && !expr.contains('(')) {
      return _evaluatePropertyAccess(expr);
    }

    // Array indexing
    if (expr.contains('[') && expr.endsWith(']') && !expr.startsWith('[')) {
      return _evaluateIndexing(expr);
    }

    // Function call
    if (expr.contains('(') && expr.endsWith(')')) {
      final parenIndex = expr.indexOf('(');
      final funcName = expr.substring(0, parenIndex);
      final argsStr = expr.substring(parenIndex + 1, expr.length - 1);
      
      // Built-in functions
      final result = _evaluateBuiltinFunction(funcName, argsStr);
      if (result != null) return result;
      
      // User-defined functions
      return _callFunction(funcName, argsStr);
    }

    // Ternary operator
    if (expr.contains('?') && expr.contains(':')) {
      return _evaluateTernary(expr);
    }

    // Comparison operators
    for (final op in ['===', '!==', '==', '!=', '<=', '>=', '<', '>']) {
      final parts = _splitByOperator(expr, op);
      if (parts != null) {
        final left = _evaluateExpression(parts[0]);
        final right = _evaluateExpression(parts[1]);
        return _compare(left, right, op);
      }
    }

    // Logical operators
    if (expr.contains('&&')) {
      final parts = _splitByOperator(expr, '&&');
      if (parts != null) {
        return _isTruthy(_evaluateExpression(parts[0])) && _isTruthy(_evaluateExpression(parts[1]));
      }
    }
    if (expr.contains('||')) {
      final parts = _splitByOperator(expr, '||');
      if (parts != null) {
        return _isTruthy(_evaluateExpression(parts[0])) || _isTruthy(_evaluateExpression(parts[1]));
      }
    }

    // Arithmetic
    return _evaluateArithmetic(expr);
  }

  /// Evaluate template literal
  String _evaluateTemplateLiteral(String content) {
    final result = StringBuffer();
    var i = 0;
    
    while (i < content.length) {
      if (content[i] == '\$' && i + 1 < content.length && content[i + 1] == '{') {
        // Find matching closing brace
        var depth = 1;
        var j = i + 2;
        while (j < content.length && depth > 0) {
          if (content[j] == '{') depth++;
          if (content[j] == '}') depth--;
          j++;
        }
        
        final expr = content.substring(i + 2, j - 1);
        final value = _evaluateExpression(expr);
        result.write(_formatValue(value));
        i = j;
      } else {
        result.write(content[i]);
        i++;
      }
    }
    
    return _processEscapeSequences(result.toString());
  }

  /// Evaluate array literal
  List<dynamic> _evaluateArray(String expr) {
    final content = expr.substring(1, expr.length - 1).trim();
    if (content.isEmpty) return [];
    
    final items = _parseArguments(content);
    return items.map((item) => _evaluateExpression(item)).toList();
  }

  /// Evaluate object literal
  Map<String, dynamic> _evaluateObject(String expr) {
    final content = expr.substring(1, expr.length - 1).trim();
    if (content.isEmpty) return {};
    
    final result = <String, dynamic>{};
    final pairs = _parseArguments(content);
    
    for (final pair in pairs) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        var key = pair.substring(0, colonIndex).trim();
        final value = pair.substring(colonIndex + 1).trim();
        
        // Remove quotes from key if present
        if ((key.startsWith('"') && key.endsWith('"')) ||
            (key.startsWith("'") && key.endsWith("'"))) {
          key = key.substring(1, key.length - 1);
        }
        
        result[key] = _evaluateExpression(value);
      }
    }
    
    return result;
  }

  /// Evaluate method chain
  dynamic _evaluateMethodChain(String expr) {
    // Split by dots, respecting parentheses
    final parts = <String>[];
    var current = StringBuffer();
    var depth = 0;
    
    for (var i = 0; i < expr.length; i++) {
      final char = expr[i];
      if (char == '(' || char == '[') depth++;
      if (char == ')' || char == ']') depth--;
      
      if (char == '.' && depth == 0) {
        parts.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    if (current.isNotEmpty) parts.add(current.toString());
    
    // Evaluate chain
    dynamic value = _evaluateExpression(parts[0]);
    
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];
      
      if (part.contains('(')) {
        // Method call
        final parenIndex = part.indexOf('(');
        final methodName = part.substring(0, parenIndex);
        final argsStr = part.substring(parenIndex + 1, part.length - 1);
        final args = argsStr.isEmpty ? <dynamic>[] : _parseArguments(argsStr).map((a) => _evaluateExpression(a)).toList();
        
        value = _callMethod(value, methodName, args);
      } else {
        // Property access
        if (value is Map) {
          value = value[part];
        } else if (value is List && part == 'length') {
          value = value.length;
        } else if (value is String && part == 'length') {
          value = value.length;
        }
      }
    }
    
    return value;
  }

  /// Call method on value
  dynamic _callMethod(dynamic value, String methodName, List<dynamic> args) {
    // Array methods
    if (value is List) {
      switch (methodName) {
        case 'length':
          return value.length;
        case 'push':
          value.addAll(args);
          return value.length;
        case 'pop':
          return value.isNotEmpty ? value.removeLast() : null;
        case 'shift':
          return value.isNotEmpty ? value.removeAt(0) : null;
        case 'unshift':
          value.insertAll(0, args);
          return value.length;
        case 'join':
          return value.map((e) => _formatValue(e)).join(args.isNotEmpty ? args[0].toString() : ',');
        case 'reverse':
          return value.reversed.toList();
        case 'slice':
          final start = args.isNotEmpty ? args[0] as int : 0;
          final end = args.length > 1 ? args[1] as int : value.length;
          return value.sublist(start, end);
        case 'indexOf':
          return value.indexOf(args[0]);
        case 'includes':
          return value.contains(args[0]);
        case 'filter':
          // Simple filter - evaluate function for each element
          return value.where((e) => _isTruthy(e)).toList();
        case 'map':
          // Simple map - return copy
          return List.from(value);
        case 'forEach':
          return null;
        case 'find':
          return value.isNotEmpty ? value.first : null;
        case 'concat':
          final result = List.from(value);
          for (final arg in args) {
            if (arg is List) {
              result.addAll(arg);
            } else {
              result.add(arg);
            }
          }
          return result;
      }
    }

    // String methods
    if (value is String) {
      switch (methodName) {
        case 'length':
          return value.length;
        case 'toUpperCase':
          return value.toUpperCase();
        case 'toLowerCase':
          return value.toLowerCase();
        case 'trim':
          return value.trim();
        case 'split':
          return value.split(args.isNotEmpty ? args[0].toString() : '');
        case 'slice':
        case 'substring':
          final start = args.isNotEmpty ? args[0] as int : 0;
          final end = args.length > 1 ? args[1] as int : value.length;
          return value.substring(start, end);
        case 'charAt':
          final index = args.isNotEmpty ? args[0] as int : 0;
          return index < value.length ? value[index] : '';
        case 'indexOf':
          return value.indexOf(args[0].toString());
        case 'includes':
          return value.contains(args[0].toString());
        case 'replace':
          if (args.length >= 2) {
            return value.replaceFirst(args[0].toString(), args[1].toString());
          }
          return value;
        case 'replaceAll':
          if (args.length >= 2) {
            return value.replaceAll(args[0].toString(), args[1].toString());
          }
          return value;
        case 'startsWith':
          return value.startsWith(args[0].toString());
        case 'endsWith':
          return value.endsWith(args[0].toString());
        case 'repeat':
          return value * (args.isNotEmpty ? args[0] as int : 1);
        case 'padStart':
          final targetLength = args.isNotEmpty ? args[0] as int : value.length;
          final padString = args.length > 1 ? args[1].toString() : ' ';
          return value.padLeft(targetLength, padString);
        case 'padEnd':
          final targetLength = args.isNotEmpty ? args[0] as int : value.length;
          final padString = args.length > 1 ? args[1].toString() : ' ';
          return value.padRight(targetLength, padString);
      }
    }

    // Object methods
    if (value is Map) {
      switch (methodName) {
        case 'keys':
          return value.keys.toList();
        case 'values':
          return value.values.toList();
        case 'entries':
          return value.entries.map((e) => [e.key, e.value]).toList();
        case 'hasOwnProperty':
          return value.containsKey(args[0].toString());
      }
    }

    // Number methods
    if (value is num) {
      switch (methodName) {
        case 'toFixed':
          return (value as double).toStringAsFixed(args.isNotEmpty ? args[0] as int : 0);
        case 'toString':
          return value.toString();
      }
    }

    return null;
  }

  /// Evaluate property access
  dynamic _evaluatePropertyAccess(String expr) {
    final parts = expr.split('.');
    dynamic value = _evaluateExpression(parts[0]);
    
    for (var i = 1; i < parts.length; i++) {
      if (value is Map) {
        value = value[parts[i]];
      } else if (value is List && parts[i] == 'length') {
        value = value.length;
      } else if (value is String && parts[i] == 'length') {
        value = value.length;
      } else {
        return null;
      }
    }
    
    return value;
  }

  /// Evaluate indexing
  dynamic _evaluateIndexing(String expr) {
    final bracketIndex = expr.lastIndexOf('[');
    final varPart = expr.substring(0, bracketIndex);
    final indexPart = expr.substring(bracketIndex + 1, expr.length - 1);

    final value = _evaluateExpression(varPart);
    final index = _evaluateExpression(indexPart);

    if (value is List && index is int) {
      if (index >= 0 && index < value.length) {
        return value[index];
      }
      return null;
    }
    if (value is String && index is int) {
      if (index >= 0 && index < value.length) {
        return value[index];
      }
      return '';
    }
    if (value is Map) {
      return value[index.toString()];
    }

    return null;
  }

  /// Evaluate built-in functions
  dynamic _evaluateBuiltinFunction(String funcName, String argsStr) {
    final args = argsStr.isEmpty ? <dynamic>[] : _parseArguments(argsStr).map((a) => _evaluateExpression(a)).toList();

    switch (funcName) {
      case 'parseInt':
        if (args.isNotEmpty) {
          return int.tryParse(args[0].toString()) ?? 0;
        }
        return 0;
      case 'parseFloat':
        if (args.isNotEmpty) {
          return double.tryParse(args[0].toString()) ?? 0.0;
        }
        return 0.0;
      case 'String':
        return args.isNotEmpty ? _formatValue(args[0]) : '';
      case 'Number':
        if (args.isNotEmpty) {
          return num.tryParse(args[0].toString()) ?? 0;
        }
        return 0;
      case 'Boolean':
        return args.isNotEmpty ? _isTruthy(args[0]) : false;
      case 'Array':
        if (args.length == 1 && args[0] is int) {
          return List.filled(args[0], null);
        }
        return List.from(args);
      case 'Object':
        return <String, dynamic>{};
      case 'isNaN':
        if (args.isNotEmpty) {
          final num = double.tryParse(args[0].toString());
          return num == null || num.isNaN;
        }
        return true;
      case 'isFinite':
        if (args.isNotEmpty) {
          final num = double.tryParse(args[0].toString());
          return num != null && num.isFinite;
        }
        return false;
      case 'typeof':
        if (args.isNotEmpty) {
          return _typeof(args[0]);
        }
        return 'undefined';
      // Math functions
      case 'Math.abs':
        return args.isNotEmpty ? (args[0] as num).abs() : 0;
      case 'Math.floor':
        return args.isNotEmpty ? (args[0] as num).floor() : 0;
      case 'Math.ceil':
        return args.isNotEmpty ? (args[0] as num).ceil() : 0;
      case 'Math.round':
        return args.isNotEmpty ? (args[0] as num).round() : 0;
      case 'Math.max':
        return args.isNotEmpty ? args.reduce((a, b) => (a as num) > (b as num) ? a : b) : double.negativeInfinity;
      case 'Math.min':
        return args.isNotEmpty ? args.reduce((a, b) => (a as num) < (b as num) ? a : b) : double.infinity;
      case 'Math.pow':
        return args.length >= 2 ? _power(args[0] as num, args[1] as num) : 0;
      case 'Math.sqrt':
        return args.isNotEmpty ? (args[0] as num).toDouble().abs() : 0;
      case 'Math.random':
        return 0.5; // Deterministic for testing
    }

    return null;
  }

  /// Evaluate ternary operator
  dynamic _evaluateTernary(String expr) {
    var depth = 0;
    var questionIndex = -1;
    var colonIndex = -1;

    for (var i = 0; i < expr.length; i++) {
      final char = expr[i];
      if (char == '(' || char == '[' || char == '{') depth++;
      if (char == ')' || char == ']' || char == '}') depth--;

      if (depth == 0) {
        if (char == '?' && questionIndex < 0) {
          questionIndex = i;
        } else if (char == ':' && questionIndex >= 0 && colonIndex < 0) {
          colonIndex = i;
        }
      }
    }

    if (questionIndex > 0 && colonIndex > questionIndex) {
      final condition = expr.substring(0, questionIndex);
      final truePart = expr.substring(questionIndex + 1, colonIndex);
      final falsePart = expr.substring(colonIndex + 1);

      return _isTruthy(_evaluateExpression(condition))
          ? _evaluateExpression(truePart)
          : _evaluateExpression(falsePart);
    }

    return null;
  }

  /// Evaluate arithmetic expression
  dynamic _evaluateArithmetic(String expr) {
    // Handle ** (power) first
    var parts = _splitByOperator(expr, '**');
    if (parts != null) {
      final left = _evaluateExpression(parts[0]) as num;
      final right = _evaluateExpression(parts[1]) as num;
      return _power(left, right);
    }

    // Handle + (addition/concatenation)
    parts = _splitByOperator(expr, '+');
    if (parts != null) {
      final left = _evaluateExpression(parts[0]);
      final right = _evaluateExpression(parts[1]);
      if (left is String || right is String) {
        return _formatValue(left) + _formatValue(right);
      }
      return (left as num) + (right as num);
    }

    // Handle - (subtraction)
    parts = _splitByOperator(expr, '-');
    if (parts != null && parts[0].isNotEmpty) {
      final left = _evaluateExpression(parts[0]) as num;
      final right = _evaluateExpression(parts[1]) as num;
      return left - right;
    }

    // Handle * (multiplication)
    parts = _splitByOperator(expr, '*');
    if (parts != null) {
      final left = _evaluateExpression(parts[0]) as num;
      final right = _evaluateExpression(parts[1]) as num;
      return left * right;
    }

    // Handle / (division)
    parts = _splitByOperator(expr, '/');
    if (parts != null) {
      final left = _evaluateExpression(parts[0]) as num;
      final right = _evaluateExpression(parts[1]) as num;
      return left / right;
    }

    // Handle % (modulo)
    parts = _splitByOperator(expr, '%');
    if (parts != null) {
      final left = _evaluateExpression(parts[0]) as num;
      final right = _evaluateExpression(parts[1]) as num;
      return left % right;
    }

    return expr;
  }

  /// Split expression by operator
  List<String>? _splitByOperator(String expr, String op) {
    var depth = 0;
    var inString = false;
    String? stringChar;

    for (var i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];

      if ((char == '"' || char == "'" || char == '`') && 
          (i == 0 || expr[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
      }

      if (!inString) {
        if (char == ')' || char == ']' || char == '}') depth++;
        if (char == '(' || char == '[' || char == '{') depth--;

        if (depth == 0 && i >= op.length - 1) {
          final potentialOp = expr.substring(i - op.length + 1, i + 1);
          if (potentialOp == op) {
            // Check for multi-char operators
            if (op == '=' && i > 0 && '=!<>'.contains(expr[i - 1])) continue;
            if (op == '=' && i < expr.length - 1 && expr[i + 1] == '=') continue;
            if (op == '*' && i > 0 && expr[i - 1] == '*') continue;
            if (op == '*' && i < expr.length - 1 && expr[i + 1] == '*') continue;
            
            return [expr.substring(0, i - op.length + 1), expr.substring(i + 1)];
          }
        }
      }
    }

    return null;
  }

  /// Compare values
  dynamic _compare(dynamic left, dynamic right, String op) {
    switch (op) {
      case '===':
        return left == right && left.runtimeType == right.runtimeType;
      case '!==':
        return left != right || left.runtimeType != right.runtimeType;
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '<':
        return (left as Comparable).compareTo(right) < 0;
      case '>':
        return (left as Comparable).compareTo(right) > 0;
      case '<=':
        return (left as Comparable).compareTo(right) <= 0;
      case '>=':
        return (left as Comparable).compareTo(right) >= 0;
    }
    return false;
  }

  /// Parse comma-separated arguments
  List<String> _parseArguments(String content) {
    final args = <String>[];
    var current = StringBuffer();
    var depth = 0;
    var inString = false;
    String? stringChar;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      if ((char == '"' || char == "'" || char == '`') && 
          (i == 0 || content[i - 1] != '\\')) {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
      }

      if (!inString) {
        if (char == '(' || char == '[' || char == '{') depth++;
        if (char == ')' || char == ']' || char == '}') depth--;

        if (char == ',' && depth == 0) {
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

  /// Find matching parenthesis
  int _findMatchingParen(String str, int start) {
    if (start < 0 || start >= str.length) return -1;
    var depth = 1;
    for (var i = start + 1; i < str.length; i++) {
      if (str[i] == '(') depth++;
      if (str[i] == ')') depth--;
      if (depth == 0) return i;
    }
    return -1;
  }

  /// Process escape sequences
  String _processEscapeSequences(String s) {
    return s
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .replaceAll('\\r', '\r')
        .replaceAll("\\'", "'")
        .replaceAll('\\"', '"')
        .replaceAll('\\`', '`')
        .replaceAll('\\\\', '\\');
  }

  /// Format value for output
  String _formatValue(dynamic value) {
    if (value == null) return 'undefined';
    if (value is bool) return value.toString();
    if (value is int) return value.toString();
    if (value is double) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    if (value is List) {
      return '[${value.map((v) => v is String ? '"$v"' : _formatValue(v)).join(', ')}]';
    }
    if (value is Map) {
      final pairs = value.entries.map((e) => '${e.key}: ${e.value is String ? '"${e.value}"' : _formatValue(e.value)}');
      return '{ ${pairs.join(', ')} }';
    }
    return value.toString();
  }

  /// Get typeof value
  String _typeof(dynamic value) {
    if (value == null) return 'undefined';
    if (value is bool) return 'boolean';
    if (value is num) return 'number';
    if (value is String) return 'string';
    if (value is List) return 'object';
    if (value is Map) return 'object';
    if (value is _JSFunction) return 'function';
    return 'object';
  }

  /// Check if value is truthy
  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0 && !value.isNaN;
    if (value is String) return value.isNotEmpty;
    if (value is List) return true;
    if (value is Map) return true;
    return true;
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
    return base;
  }

  /// Check if line is assignment
  bool _isAssignment(String line) {
    return _findAssignmentIndex(line) > 0;
  }

  /// Check if line is augmented assignment
  bool _isAugmentedAssignment(String line) {
    return line.contains('+=') || line.contains('-=') || 
           line.contains('*=') || line.contains('/=') || 
           line.contains('%=') || line.contains('**=');
  }

  /// Check if line is increment/decrement
  bool _isIncrementDecrement(String line) {
    return line.endsWith('++') || line.endsWith('--') ||
           line.startsWith('++') || line.startsWith('--');
  }

  /// Check if line is method call
  bool _isMethodCall(String line) {
    return line.contains('.') && line.contains('(') && line.endsWith(')') &&
           !line.startsWith('console.');
  }

  /// Check if line is function call
  bool _isFunctionCall(String line) {
    return line.contains('(') && line.endsWith(')') && 
           !line.contains('.') && !line.contains('=');
  }

  /// Check if line is arrow function assignment
  bool _isArrowFunctionAssignment(String line) {
    return line.contains('=>') && line.contains('=');
  }

  /// Check if name is valid variable name
  bool _isValidVariableName(String name) {
    if (name.isEmpty) return false;
    if (RegExp(r'^[0-9]').hasMatch(name)) return false;
    if (!RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$').hasMatch(name)) return false;
    
    const reserved = {'let', 'const', 'var', 'function', 'return', 'if', 'else', 
                      'for', 'while', 'do', 'switch', 'case', 'break', 'continue',
                      'try', 'catch', 'finally', 'throw', 'class', 'new', 'this',
                      'true', 'false', 'null', 'undefined', 'typeof', 'instanceof'};
    return !reserved.contains(name);
  }
}

/// Represents a JavaScript function
class _JSFunction {
  final List<String> params;
  final List<String> body;

  _JSFunction(this.params, this.body);
}

/// Result of interpreter execution
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
}
