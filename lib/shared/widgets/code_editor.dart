import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/sql.dart';

// Custom theme with VS Code-like colors
const codeTheme = {
  'root': TextStyle(
    backgroundColor: Color(0xFF1E1E1E),
    color: Color(0xFFD4D4D4),
  ),
  'keyword': TextStyle(
    color: Color(0xFFC586C0),
  ), // if, for, while - purple/pink
  'built_in': TextStyle(color: Color(0xFFDCDCAA)), // print, console - yellow
  'type': TextStyle(color: Color(0xFF4EC9B0)), // int, float, bool - teal
  'literal': TextStyle(color: Color(0xFF569CD6)), // true, false, null - blue
  'number': TextStyle(color: Color(0xFFB5CEA8)), // numbers - light green
  'string': TextStyle(color: Color(0xFFCE9178)), // strings - orange
  'comment': TextStyle(color: Color(0xFF6A9955)), // comments - green
  'function': TextStyle(color: Color(0xFFDCDCAA)), // function calls - yellow
  'title': TextStyle(color: Color(0xFFDCDCAA)), // function definitions - yellow
  'params': TextStyle(color: Color(0xFF9CDCFE)), // parameters - light blue
  'variable': TextStyle(color: Color(0xFF9CDCFE)), // variables - light blue
  'attr': TextStyle(color: Color(0xFF9CDCFE)), // attributes - light blue
  'meta': TextStyle(color: Color(0xFF569CD6)), // decorators - blue
  'subst': TextStyle(color: Color(0xFFD4D4D4)), // template substitutions
  'tag': TextStyle(color: Color(0xFF569CD6)), // HTML tags - blue
  'name': TextStyle(color: Color(0xFF569CD6)), // tag names - blue
  'attribute': TextStyle(
    color: Color(0xFF9CDCFE),
  ), // HTML attributes - light blue
  'selector-tag': TextStyle(color: Color(0xFFD7BA7D)), // CSS selectors - gold
  'selector-class': TextStyle(color: Color(0xFFD7BA7D)), // CSS classes - gold
  'selector-id': TextStyle(color: Color(0xFFD7BA7D)), // CSS ids - gold
};

/// A code editor widget with syntax highlighting, autocomplete, and error detection
class CodeEditor extends StatefulWidget {
  final TextEditingController controller;
  final String language;
  final Color accentColor;
  final Function(String)? onChanged;
  final List<String>? errors;

  const CodeEditor({
    super.key,
    required this.controller,
    this.language = 'python',
    this.accentColor = Colors.blue,
    this.onChanged,
    this.errors,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late CodeController _codeController;
  List<String> _suggestions = [];
  int _selectedSuggestionIndex = 0;
  String _currentWord = '';
  List<SyntaxError> _syntaxErrors = [];
  bool _showSuggestions = false;

  // Autocomplete suggestions with descriptions
  static const pythonCompletions = <String, String>{
    'print()': 'Print to console',
    'len()': 'Get length of sequence',
    'range()': 'Generate number sequence',
    'str()': 'Convert to string',
    'int()': 'Convert to integer',
    'float()': 'Convert to float',
    'bool()': 'Convert to boolean',
    'list()': 'Create a list',
    'dict()': 'Create a dictionary',
    'type()': 'Get type of object',
    'input()': 'Read user input',
    'abs()': 'Absolute value',
    'max()': 'Maximum value',
    'min()': 'Minimum value',
    'sum()': 'Sum of sequence',
    'sorted()': 'Return sorted list',
    'enumerate()': 'Enumerate sequence',
    '.append()': 'Add item to list',
    '.extend()': 'Extend list',
    '.pop()': 'Remove and return item',
    '.remove()': 'Remove first occurrence',
    '.upper()': 'Convert to uppercase',
    '.lower()': 'Convert to lowercase',
    '.strip()': 'Remove whitespace',
    '.split()': 'Split string',
    '.join()': 'Join strings',
    '.replace()': 'Replace substring',
    '.find()': 'Find substring index',
    '.keys()': 'Get dictionary keys',
    '.values()': 'Get dictionary values',
    '.items()': 'Get key-value pairs',
    '.get()': 'Get value safely',
    'if': 'Conditional statement',
    'elif': 'Else if condition',
    'else:': 'Else block',
    'for': 'For loop',
    'while': 'While loop',
    'def': 'Define function',
    'return': 'Return value',
    'try:': 'Try block',
    'except': 'Exception handler',
    'finally:': 'Finally block',
    'True': 'Boolean true',
    'False': 'Boolean false',
    'None': 'Null value',
    'and': 'Logical AND',
    'or': 'Logical OR',
    'not': 'Logical NOT',
    'in': 'Membership test',
    'break': 'Exit loop',
    'continue': 'Skip iteration',
  };

  static const pythonKeywords = {
    'if',
    'elif',
    'else',
    'for',
    'while',
    'def',
    'return',
    'try',
    'except',
    'finally',
    'True',
    'False',
    'None',
    'and',
    'or',
    'not',
    'in',
    'break',
    'continue',
    'pass',
    'class',
    'import',
    'from',
    'as',
    'with',
    'lambda',
  };

  // JavaScript completions
  static const jsCompletions = <String, String>{
    'console.log()': 'Print to console',
    'console.error()': 'Print error',
    'console.warn()': 'Print warning',
    'let': 'Declare variable (block scope)',
    'const': 'Declare constant',
    'var': 'Declare variable (function scope)',
    'function': 'Define function',
    'return': 'Return value',
    'if': 'Conditional statement',
    'else': 'Else block',
    'for': 'For loop',
    'while': 'While loop',
    'switch': 'Switch statement',
    'case': 'Switch case',
    'break': 'Exit loop/switch',
    'continue': 'Skip iteration',
    'try': 'Try block',
    'catch': 'Catch exception',
    'finally': 'Finally block',
    'throw': 'Throw exception',
    'async': 'Async function',
    'await': 'Await promise',
    'true': 'Boolean true',
    'false': 'Boolean false',
    'null': 'Null value',
    'undefined': 'Undefined value',
    'typeof': 'Get type of value',
    'instanceof': 'Check instance type',
    '.length': 'Get length',
    '.push()': 'Add to array',
    '.pop()': 'Remove last element',
    '.shift()': 'Remove first element',
    '.unshift()': 'Add to beginning',
    '.slice()': 'Get array portion',
    '.splice()': 'Modify array',
    '.map()': 'Transform array',
    '.filter()': 'Filter array',
    '.reduce()': 'Reduce array',
    '.forEach()': 'Iterate array',
    '.find()': 'Find element',
    '.includes()': 'Check if includes',
    '.indexOf()': 'Find index',
    '.join()': 'Join to string',
    '.split()': 'Split string',
    '.toUpperCase()': 'Convert to uppercase',
    '.toLowerCase()': 'Convert to lowercase',
    '.trim()': 'Remove whitespace',
    '.replace()': 'Replace substring',
    '.substring()': 'Get substring',
    '.charAt()': 'Get character at index',
    '.startsWith()': 'Check start',
    '.endsWith()': 'Check end',
    'parseInt()': 'Parse integer',
    'parseFloat()': 'Parse float',
    'String()': 'Convert to string',
    'Number()': 'Convert to number',
    'Boolean()': 'Convert to boolean',
    'Array.isArray()': 'Check if array',
    'Object.keys()': 'Get object keys',
    'Object.values()': 'Get object values',
    'JSON.parse()': 'Parse JSON',
    'JSON.stringify()': 'Convert to JSON',
    'Math.floor()': 'Round down',
    'Math.ceil()': 'Round up',
    'Math.round()': 'Round to nearest',
    'Math.random()': 'Random number 0-1',
    'Math.max()': 'Maximum value',
    'Math.min()': 'Minimum value',
    'Math.abs()': 'Absolute value',
    '=>': 'Arrow function',
    '...': 'Spread operator',
    '===': 'Strict equality',
    '!==': 'Strict inequality',
  };

  static const jsKeywords = {
    'let',
    'const',
    'var',
    'function',
    'return',
    'if',
    'else',
    'for',
    'while',
    'do',
    'switch',
    'case',
    'break',
    'continue',
    'try',
    'catch',
    'finally',
    'throw',
    'async',
    'await',
    'class',
    'new',
    'this',
    'true',
    'false',
    'null',
    'undefined',
    'typeof',
    'instanceof',
    'import',
    'export',
    'default',
  };

  // C++ completions
  static const cppCompletions = <String, String>{
    '#include <iostream>': 'Input/output header',
    'using namespace std;': 'Use std symbols directly',
    'int main()': 'Program entry point',
    'cout <<': 'Print output',
    'cin >>': 'Read input',
    'endl': 'New line output',
    'int': 'Integer type',
    'double': 'Floating-point type',
    'string': 'Text type',
    'char': 'Character type',
    'bool': 'Boolean type',
    'if': 'Conditional branch',
    'else': 'Else branch',
    'for': 'For loop',
    'while': 'While loop',
    'return': 'Return value',
    'vector<int>': 'Dynamic integer list',
    '.push_back()': 'Append to vector',
    '.size()': 'Collection size',
    'class': 'Class declaration',
    'public:': 'Public class section',
    'private:': 'Private class section',
    'template <typename T>': 'Template declaration',
    'auto': 'Type inference',
    'const': 'Immutable value',
    'nullptr': 'Null pointer',
    'std::': 'Standard library scope',
  };

  static const cppKeywords = {
    'int',
    'double',
    'float',
    'bool',
    'char',
    'string',
    'if',
    'else',
    'for',
    'while',
    'return',
    'class',
    'public',
    'private',
    'protected',
    'template',
    'typename',
    'const',
    'auto',
    'nullptr',
    'include',
    'using',
    'namespace',
    'std',
    'switch',
    'case',
    'break',
    'continue',
    'struct',
    'virtual',
    'override',
    'new',
    'delete',
  };

  // HTML/CSS completions
  static const htmlCompletions = <String, String>{
    '<div>': 'Division container',
    '<span>': 'Inline container',
    '<p>': 'Paragraph',
    '<h1>': 'Heading 1',
    '<h2>': 'Heading 2',
    '<h3>': 'Heading 3',
    '<a>': 'Link/anchor',
    '<img>': 'Image',
    '<ul>': 'Unordered list',
    '<ol>': 'Ordered list',
    '<li>': 'List item',
    '<table>': 'Table',
    '<tr>': 'Table row',
    '<td>': 'Table cell',
    '<th>': 'Table header',
    '<form>': 'Form',
    '<input>': 'Input field',
    '<button>': 'Button',
    '<select>': 'Dropdown',
    '<option>': 'Dropdown option',
    '<textarea>': 'Text area',
    '<label>': 'Form label',
    '<header>': 'Header section',
    '<footer>': 'Footer section',
    '<nav>': 'Navigation',
    '<main>': 'Main content',
    '<section>': 'Section',
    '<article>': 'Article',
    '<aside>': 'Sidebar',
    'class=""': 'CSS class attribute',
    'id=""': 'Element ID',
    'style=""': 'Inline styles',
    'href=""': 'Link URL',
    'src=""': 'Source URL',
    'alt=""': 'Alternative text',
    // CSS properties
    'color:': 'Text color',
    'background:': 'Background',
    'background-color:': 'Background color',
    'font-size:': 'Font size',
    'font-family:': 'Font family',
    'font-weight:': 'Font weight',
    'margin:': 'Outer spacing',
    'padding:': 'Inner spacing',
    'border:': 'Border',
    'border-radius:': 'Rounded corners',
    'width:': 'Element width',
    'height:': 'Element height',
    'display:': 'Display type',
    'flex': 'Flexbox display',
    'grid': 'Grid display',
    'position:': 'Positioning',
    'top:': 'Top position',
    'left:': 'Left position',
    'right:': 'Right position',
    'bottom:': 'Bottom position',
    'z-index:': 'Stack order',
    'justify-content:': 'Flex main axis',
    'align-items:': 'Flex cross axis',
    'flex-direction:': 'Flex direction',
    'gap:': 'Flex/grid gap',
    'text-align:': 'Text alignment',
    'text-decoration:': 'Text decoration',
    'opacity:': 'Transparency',
    'transition:': 'CSS transition',
    'transform:': 'CSS transform',
    'box-shadow:': 'Box shadow',
    '@media': 'Media query',
  };

  // SQL completions
  static const sqlCompletions = <String, String>{
    'SELECT': 'Select columns',
    'FROM': 'Specify table',
    'WHERE': 'Filter condition',
    'AND': 'Combine conditions',
    'OR': 'Alternative condition',
    'NOT': 'Negate condition',
    'IN': 'Match any value in list',
    'BETWEEN': 'Range condition',
    'LIKE': 'Pattern matching',
    'ORDER BY': 'Sort results',
    'ASC': 'Ascending order',
    'DESC': 'Descending order',
    'LIMIT': 'Limit results',
    'OFFSET': 'Skip rows',
    'GROUP BY': 'Group rows',
    'HAVING': 'Filter groups',
    'COUNT()': 'Count rows',
    'SUM()': 'Sum values',
    'AVG()': 'Average value',
    'MIN()': 'Minimum value',
    'MAX()': 'Maximum value',
    'INNER JOIN': 'Join matching rows',
    'LEFT JOIN': 'Join all left rows',
    'RIGHT JOIN': 'Join all right rows',
    'FULL JOIN': 'Join all rows',
    'ON': 'Join condition',
    'AS': 'Alias name',
    'DISTINCT': 'Unique values only',
    'INSERT INTO': 'Insert row',
    'VALUES': 'Values to insert',
    'UPDATE': 'Update rows',
    'SET': 'Set column value',
    'DELETE FROM': 'Delete rows',
    'CREATE TABLE': 'Create new table',
    'DROP TABLE': 'Delete table',
    'ALTER TABLE': 'Modify table',
    'ADD COLUMN': 'Add new column',
    'PRIMARY KEY': 'Primary key',
    'FOREIGN KEY': 'Foreign key',
    'REFERENCES': 'Reference table',
    'NOT NULL': 'Require value',
    'UNIQUE': 'Unique constraint',
    'DEFAULT': 'Default value',
    'AUTO_INCREMENT': 'Auto increment',
    'INTEGER': 'Integer type',
    'VARCHAR()': 'Variable string',
    'TEXT': 'Text type',
    'BOOLEAN': 'Boolean type',
    'DATE': 'Date type',
    'DATETIME': 'DateTime type',
    'DECIMAL()': 'Decimal type',
    'NULL': 'Null value',
    'IS NULL': 'Check if null',
    'IS NOT NULL': 'Check if not null',
    'COALESCE()': 'First non-null',
    'CASE': 'Conditional logic',
    'WHEN': 'Case condition',
    'THEN': 'Case result',
    'ELSE': 'Default case',
    'END': 'End case',
  };

  static const sqlKeywords = {
    'SELECT',
    'FROM',
    'WHERE',
    'AND',
    'OR',
    'NOT',
    'IN',
    'BETWEEN',
    'LIKE',
    'ORDER',
    'BY',
    'ASC',
    'DESC',
    'LIMIT',
    'OFFSET',
    'GROUP',
    'HAVING',
    'JOIN',
    'INNER',
    'LEFT',
    'RIGHT',
    'FULL',
    'ON',
    'AS',
    'DISTINCT',
    'INSERT',
    'INTO',
    'VALUES',
    'UPDATE',
    'SET',
    'DELETE',
    'CREATE',
    'DROP',
    'ALTER',
    'TABLE',
    'ADD',
    'COLUMN',
    'PRIMARY',
    'KEY',
    'FOREIGN',
    'REFERENCES',
    'NULL',
    'UNIQUE',
    'DEFAULT',
    'CASE',
    'WHEN',
    'THEN',
    'ELSE',
    'END',
  };

  // React completions (extends JS completions)
  static const reactCompletions = <String, String>{
    // Core React
    'import React': 'Import React',
    'useState()': 'State hook',
    'useEffect()': 'Side effect hook',
    'useContext()': 'Context hook',
    'useRef()': 'Reference hook',
    'useMemo()': 'Memoize value',
    'useCallback()': 'Memoize function',
    'useReducer()': 'Reducer hook',
    // Components
    'function Component()': 'Function component',
    'export default': 'Default export',
    'return ()': 'Return JSX',
    'props': 'Component props',
    'children': 'Child elements',
    // JSX
    'className=""': 'CSS class',
    'onClick={}': 'Click handler',
    'onChange={}': 'Change handler',
    'onSubmit={}': 'Submit handler',
    'style={{}}': 'Inline styles',
    'key={}': 'List key',
    '{...props}': 'Spread props',
    // Hooks patterns
    'const [state, setState]': 'State declaration',
    'setInterval()': 'Set interval',
    'clearInterval()': 'Clear interval',
    // Common
    'event.preventDefault()': 'Prevent default',
    'event.target.value': 'Input value',
    '.map()': 'Map array to JSX',
    '.filter()': 'Filter array',
    // Conditional
    '{condition && <JSX>}': 'Conditional render',
    '{condition ? <A> : <B>}': 'Ternary render',
    // Fragment
    '<></>': 'Fragment shorthand',
    '<Fragment>': 'Fragment element',
    // JS from jsCompletions
    'console.log()': 'Log to console',
    'const': 'Constant variable',
    'let': 'Mutable variable',
    'function': 'Function declaration',
    'async': 'Async function',
    'await': 'Await promise',
    '=>': 'Arrow function',
    '...': 'Spread operator',
    'true': 'Boolean true',
    'false': 'Boolean false',
    'null': 'Null value',
  };

  /// Get completions based on language
  Map<String, String> get _completions {
    switch (widget.language.toLowerCase()) {
      case 'javascript':
      case 'js':
        return jsCompletions;
      case 'react':
      case 'jsx':
        return reactCompletions;
      case 'cpp':
      case 'c++':
      case 'cplusplus':
        return cppCompletions;
      case 'sql':
        return sqlCompletions;
      case 'html':
      case 'css':
      case 'html/css':
        return htmlCompletions;
      default:
        return pythonCompletions;
    }
  }

  /// Get language mode for syntax highlighting
  dynamic get _languageMode {
    switch (widget.language.toLowerCase()) {
      case 'javascript':
      case 'js':
      case 'react':
      case 'jsx':
        return javascript;
      case 'cpp':
      case 'c++':
      case 'cplusplus':
        return javascript;
      case 'sql':
        return sql;
      case 'html':
        return xml;
      case 'css':
        return css;
      default:
        return python;
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.controller.text,
      language: _languageMode,
    );
    _codeController.addListener(_onCodeChanged);
    widget.controller.addListener(_syncFromExternal);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    widget.controller.removeListener(_syncFromExternal);
    _codeController.dispose();
    super.dispose();
  }

  void _syncFromExternal() {
    if (_codeController.text != widget.controller.text) {
      _codeController.text = widget.controller.text;
    }
  }

  void _onCodeChanged() {
    if (widget.controller.text != _codeController.text) {
      widget.controller.text = _codeController.text;
    }
    widget.onChanged?.call(_codeController.text);
    _checkSyntax();
    _updateSuggestions();
  }

  void _checkSyntax() {
    final code = _codeController.text;
    final errors = <SyntaxError>[];
    final lines = code.split('\n');
    final language = widget.language.toLowerCase();
    final isPython = language == 'python';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check for common syntax errors

      // Unclosed strings
      final singleQuotes = "'".allMatches(line).length;
      final doubleQuotes = '"'.allMatches(line).length;
      if (singleQuotes % 2 != 0 &&
          !line.contains('"""') &&
          !line.contains("'''")) {
        errors.add(SyntaxError(i, "Unclosed string (missing ')"));
      }
      if (doubleQuotes % 2 != 0 &&
          !line.contains('"""') &&
          !line.contains("'''")) {
        errors.add(SyntaxError(i, 'Unclosed string (missing ")'));
      }

      if (isPython) {
        // Missing colon after if/elif/else/for/while/def/class/try/except/finally
        if (RegExp(
          r'^(if|elif|for|while|def|class|try|except|finally)\s+.+[^:]$',
        ).hasMatch(trimmed)) {
          errors.add(SyntaxError(i, 'Missing colon (:) at end of statement'));
        }
        if (trimmed == 'else' || trimmed == 'try' || trimmed == 'finally') {
          errors.add(SyntaxError(i, 'Missing colon (:) after $trimmed'));
        }
      }

      // Unclosed parentheses
      final openParens = '('.allMatches(line).length;
      final closeParens = ')'.allMatches(line).length;
      if (openParens > closeParens) {
        errors.add(SyntaxError(i, 'Unclosed parenthesis'));
      }
      if (closeParens > openParens) {
        errors.add(SyntaxError(i, 'Extra closing parenthesis'));
      }

      // Unclosed brackets
      final openBrackets = '['.allMatches(line).length;
      final closeBrackets = ']'.allMatches(line).length;
      if (openBrackets > closeBrackets) {
        errors.add(SyntaxError(i, 'Unclosed bracket'));
      }
      if (closeBrackets > openBrackets) {
        errors.add(SyntaxError(i, 'Extra closing bracket'));
      }

      // Assignment vs comparison warning
      if (RegExp(r'\bif\s+\w+\s*=[^=]').hasMatch(trimmed)) {
        errors.add(SyntaxError(i, 'Use == for comparison, not ='));
      }

      // Invalid variable names
      final varMatch = RegExp(r'^(\d\w*)\s*=').firstMatch(trimmed);
      if (varMatch != null) {
        errors.add(SyntaxError(i, 'Variable name cannot start with a number'));
      }

      // print without parentheses (Python 2 style)
      if (isPython && RegExp(r'^print\s+[^(]').hasMatch(trimmed)) {
        errors.add(SyntaxError(i, 'print needs parentheses: print(...)'));
      }
    }

    setState(() {
      _syntaxErrors = errors;
    });
  }

  void _updateSuggestions() {
    final text = _codeController.text;
    final cursorPos = _codeController.selection.baseOffset;

    if (cursorPos < 0 || cursorPos > text.length) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    // Get current word being typed (word characters only, not parentheses)
    final beforeCursor = text.substring(0, cursorPos);
    final wordMatch = RegExp(
      r'[a-zA-Z_][a-zA-Z0-9_]*$',
    ).firstMatch(beforeCursor);

    if (wordMatch == null || wordMatch.group(0)!.length < 2) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    _currentWord = wordMatch.group(0)!.toLowerCase();

    // Filter suggestions from current language completions
    final matches = _completions.keys
        .where((s) {
          final compareStr = s
              .replaceAll('()', '')
              .replaceAll(':', '')
              .replaceAll('', '')
              .toLowerCase();
          // Show if starts with current word, or is exact match with special chars
          if (compareStr.startsWith(_currentWord)) {
            // Don't show if exact match without special chars
            if (compareStr == _currentWord && s == _currentWord) return false;
            return true;
          }
          return false;
        })
        .take(6)
        .toList();

    setState(() {
      if (matches.isEmpty) {
        _showSuggestions = false;
        _suggestions = [];
      } else {
        _suggestions = matches;
        _selectedSuggestionIndex = 0;
        _showSuggestions = true;
      }
    });
  }

  void _insertSuggestion(String suggestion) {
    final text = _codeController.text;
    final cursorPos = _codeController.selection.baseOffset;

    // Find where current word starts (match what we used in _updateSuggestions)
    final beforeCursor = text.substring(0, cursorPos);
    final wordMatch = RegExp(
      r'[a-zA-Z_][a-zA-Z0-9_]*$',
    ).firstMatch(beforeCursor);

    if (wordMatch != null) {
      final wordStart = wordMatch.start;
      // If suggestion starts with dot (method), don't replace the dot if present before word
      String insertText = suggestion;
      if (suggestion.startsWith('.') &&
          wordStart > 0 &&
          text[wordStart - 1] == '.') {
        insertText = suggestion.substring(1); // Remove leading dot
      }

      final newText =
          text.substring(0, wordStart) + insertText + text.substring(cursorPos);

      _codeController.text = newText;

      // Position cursor
      int newCursorPos = wordStart + insertText.length;
      if (insertText.endsWith('()')) {
        newCursorPos--; // Put cursor inside parentheses
      }

      _codeController.selection = TextSelection.collapsed(offset: newCursorPos);
    }

    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  IconData _getIconForSuggestion(String suggestion) {
    if (suggestion.endsWith('()')) return Icons.functions;
    if (suggestion.startsWith('.')) return Icons.extension;
    if (suggestion.startsWith('<')) return Icons.code; // HTML tags
    if (suggestion.contains(':') && !suggestion.contains('::')) {
      return Icons.style; // CSS properties
    }

    // Check if keyword based on current language
    final lang = widget.language.toLowerCase();
    Set<String> keywords;
    if (lang == 'javascript' ||
        lang == 'js' ||
        lang == 'react' ||
        lang == 'jsx') {
      keywords = jsKeywords;
    } else if (lang == 'cpp' || lang == 'c++' || lang == 'cplusplus') {
      keywords = cppKeywords;
    } else if (lang == 'sql') {
      keywords = sqlKeywords;
    } else {
      keywords = pythonKeywords;
    }

    if (keywords.contains(suggestion.replaceAll(':', '').toUpperCase()) ||
        keywords.contains(suggestion.replaceAll(':', ''))) {
      return Icons.code;
    }
    return Icons.abc;
  }

  Color _getColorForSuggestion(String suggestion) {
    if (suggestion.endsWith('()')) return Colors.amber;
    if (suggestion.startsWith('.')) return Colors.cyan;
    if (suggestion.startsWith('<')) return Colors.blue; // HTML tags
    if (suggestion.contains(':') && !suggestion.contains('::')) {
      return Colors.purple; // CSS properties
    }
    if (suggestion == '=>' || suggestion == '...') return Colors.green;

    // SQL keywords - blue theme
    final lang = widget.language.toLowerCase();
    if (lang == 'sql') {
      if (sqlKeywords.contains(suggestion.toUpperCase())) return Colors.blue;
    }

    // Check if keyword based on current language
    Set<String> keywords;
    if (lang == 'javascript' ||
        lang == 'js' ||
        lang == 'react' ||
        lang == 'jsx') {
      keywords = jsKeywords;
    } else if (lang == 'cpp' || lang == 'c++' || lang == 'cplusplus') {
      keywords = cppKeywords;
    } else {
      keywords = pythonKeywords;
    }

    if (keywords.contains(suggestion.replaceAll(':', ''))) return Colors.purple;
    return Colors.blue;
  }

  String _languageLabel(String language) {
    final normalized = language.trim().toLowerCase();
    if (normalized == 'cpp' ||
        normalized == 'c++' ||
        normalized == 'cplusplus') {
      return 'C++';
    }
    return language.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Editor
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _syntaxErrors.isNotEmpty
                  ? Colors.red.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _languageLabel(widget.language),
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_syntaxErrors.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 12,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_syntaxErrors.length} ${_syntaxErrors.length == 1 ? 'error' : 'errors'}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green.withValues(alpha: 0.7),
                      ),
                  ],
                ),
              ),
              // Code area with syntax highlighting
              SizedBox(
                height: 280,
                child: CodeTheme(
                  data: CodeThemeData(styles: codeTheme),
                  child: CodeField(
                    controller: _codeController,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: 1.5,
                    ),
                    lineNumberStyle: LineNumberStyle(
                      textStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    cursorColor: widget.accentColor,
                    background: Colors.transparent,
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Autocomplete suggestions (below editor)
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: widget.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Suggestions',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap to insert',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Suggestions list
                ...(_suggestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final suggestion = entry.value;
                  final description = _completions[suggestion] ?? '';
                  final isSelected = index == _selectedSuggestionIndex;

                  return InkWell(
                    onTap: () => _insertSuggestion(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.accentColor.withValues(alpha: 0.2)
                            : null,
                        border: Border(
                          bottom: index < _suggestions.length - 1
                              ? BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05),
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getColorForSuggestion(
                                suggestion,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _getIconForSuggestion(suggestion),
                              size: 14,
                              color: _getColorForSuggestion(suggestion),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (description.isNotEmpty)
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_return,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                })),
              ],
            ),
          ),

        // Error panel
        if (_syntaxErrors.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Syntax ${_syntaxErrors.length == 1 ? 'Error' : 'Errors'}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(_syntaxErrors
                    .take(3)
                    .map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Line ${error.line + 1}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error.message,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (_syntaxErrors.length > 3)
                  Text(
                    '... and ${_syntaxErrors.length - 3} more',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class SyntaxError {
  final int line;
  final String message;

  SyntaxError(this.line, this.message);
}
