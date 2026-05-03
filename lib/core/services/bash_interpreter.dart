/// Bash/Shell interpreter for CLI course challenges
/// Simulates Ubuntu terminal environment with filesystem operations
class BashInterpreter {
  final Map<String, String> _fileSystem = {};
  final List<String> _output = [];
  final List<String> _commandHistory = [];
  String _currentDirectory = '/home/ubuntu';
  String? _error;

  /// Execute bash code and return result
  InterpreterResult execute(String code) {
    _output.clear();
    _error = null;

    try {
      final lines = _preprocessCode(code);
      _executeLines(lines);
    } catch (e) {
      _error = _formatError(e.toString());
    }

    return InterpreterResult(
      output: _output.join('\n'),
      error: _error,
      variables: {
        'pwd': _currentDirectory,
        'fs_tree': _buildFsTree(),
        'fs_contents': _getCurrentDirectoryContents(),
      },
    );
  }

  /// Build file tree for visualization (shows all dirs with paths)
  String _buildFsTree() {
    final dirs = _fileSystem.keys.where((p) => _fileSystem[p] == 'DIR').toList();
    dirs.sort();
    return dirs.join('\n');
  }

  /// Get contents of current directory
  Map<String, bool> _getCurrentDirectoryContents() {
    final contents = <String, bool>{};
    for (final path in _fileSystem.keys) {
      final parentDir = path.substring(0, path.lastIndexOf('/'));
      if (parentDir == _currentDirectory) {
        final name = path.substring(path.lastIndexOf('/') + 1);
        contents[name] = _fileSystem[path] == 'DIR';
      }
    }
    return contents;
  }

  String _formatError(String error) {
    if (error.contains('No such file or directory')) {
      return '❌ bash: No such file or directory\n💡 Hint: Check the path spelling and use pwd to verify location.';
    }
    if (error.contains('Command not found')) {
      return '❌ bash: command not found\n💡 Hint: Check the command name; some commands need specific syntax.';
    }
    if (error.contains('directory is not empty')) {
      return '❌ rmdir: directory not empty\n💡 Hint: Remove files inside first with rm.';
    }
    return '❌ Error: $error\n💡 Hint: Review the command syntax and file paths.';
  }

  List<String> _preprocessCode(String code) {
    final lines = <String>[];
    for (var line in code.split('\n')) {
      // Remove inline comments (# not in quotes)
      final commentIndex = line.indexOf('#');
      if (commentIndex >= 0) {
        final beforeComment = line.substring(0, commentIndex);
        final singleQuotes = "'".allMatches(beforeComment).length;
        final doubleQuotes = '"'.allMatches(beforeComment).length;
        if (singleQuotes % 2 == 0 && doubleQuotes % 2 == 0) {
          line = beforeComment;
        }
      }

      line = line.trim();
      if (line.isNotEmpty) {
        lines.add(line);
      }
    }
    return lines;
  }

  void _executeLines(List<String> lines) {
    for (final line in lines) {
      _commandHistory.add(line);

      // pwd - print working directory
      if (line.trim() == 'pwd') {
        _output.add(_currentDirectory);
        continue;
      }

      // cd - change directory
      if (line.trim().startsWith('cd ')) {
        _handleCd(line);
        continue;
      }

      // ls - list directory
      if (line.trim().startsWith('ls')) {
        _handleLs(line);
        continue;
      }

      // mkdir - make directory
      if (line.trim().startsWith('mkdir ')) {
        _handleMkdir(line);
        continue;
      }

      // touch - create file
      if (line.trim().startsWith('touch ')) {
        _handleTouch(line);
        continue;
      }

      // cat - read file
      if (line.trim().startsWith('cat ')) {
        _handleCat(line);
        continue;
      }

      // echo - print text (with optional redirection)
      if (line.trim().startsWith('echo ')) {
        _handleEcho(line);
        continue;
      }

      // cp - copy file
      if (line.trim().startsWith('cp ')) {
        _handleCp(line);
        continue;
      }

      // mv - move file
      if (line.trim().startsWith('mv ')) {
        _handleMv(line);
        continue;
      }

      // rm - remove file
      if (line.trim().startsWith('rm ')) {
        _handleRm(line);
        continue;
      }

      // rmdir - remove directory
      if (line.trim().startsWith('rmdir ')) {
        _handleRmdir(line);
        continue;
      }

      // grep - search in file
      if (line.trim().startsWith('grep ')) {
        _handleGrep(line);
        continue;
      }

      // find - find files
      if (line.trim().startsWith('find ')) {
        _handleFind(line);
        continue;
      }

      // history - show command history
      if (line.trim() == 'history') {
        _handleHistory();
        continue;
      }

      throw Exception('Command not found: ${line.split(' ').first}');
    }
  }

  void _handleCd(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('cd: missing argument');
    }

    final target = parts[1];
    final newDir = _resolvePath(target);

    if (!_directoryExists(newDir) && target != '/') {
      throw Exception('cd: $target: No such file or directory');
    }

    _currentDirectory = newDir;
  }

  void _handleLs(String line) {
    final args = line.trim().split(RegExp(r'\s+'));
    final showHidden = args.contains('-a');
    final path = args.length > 1 && !args[1].startsWith('-')
        ? _resolvePath(args[1])
        : _currentDirectory;

    if (!_directoryExists(path)) {
      throw Exception('ls: cannot access $path: No such file or directory');
    }

    final items = _listDirectory(path, showHidden: showHidden);
    for (final item in items) {
      _output.add(item);
    }
  }

  void _handleMkdir(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('mkdir: missing operand');
    }

    final dirPath = _resolvePath(parts[1]);
    if (_directoryExists(dirPath)) {
      throw Exception('mkdir: cannot create directory $dirPath: File exists');
    }

    _fileSystem[dirPath] = 'DIR';
  }

  void _handleTouch(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('touch: missing file operand');
    }

    final filePath = _resolvePath(parts[1]);
    if (!_fileSystem.containsKey(filePath)) {
      _fileSystem[filePath] = '';
    }
  }

  void _handleCat(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('cat: missing file operand');
    }

    final filePath = _resolvePath(parts[1]);
    if (!_fileSystem.containsKey(filePath)) {
      throw Exception('cat: $filePath: No such file or directory');
    }

    final content = _fileSystem[filePath];
    if (content == 'DIR') {
      throw Exception('cat: $filePath: Is a directory');
    }

    _output.add(content ?? '');
  }

  void _handleEcho(String line) {
    final trimmed = line.trim();

    // Check for output redirection
    if (trimmed.contains('>')) {
      final parts = trimmed.split(RegExp(r'\s*>\s*'));
      if (parts.length != 2) {
        throw Exception('echo: invalid redirection');
      }

      final textPart = parts[0].replaceFirst(RegExp(r'^echo\s+'), '');
      final filePath = _resolvePath(parts[1].trim());
      final text = _unquoteString(textPart);

      _fileSystem[filePath] = text;
      return;
    }

    final textPart = trimmed.replaceFirst(RegExp(r'^echo\s+'), '');
    final text = _unquoteString(textPart);
    _output.add(text);
  }

  void _handleCp(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('cp: missing operand');
    }

    final src = _resolvePath(parts[1]);
    final dst = _resolvePath(parts[2]);

    if (!_fileSystem.containsKey(src)) {
      throw Exception('cp: cannot stat $src: No such file or directory');
    }

    _fileSystem[dst] = _fileSystem[src]!;
  }

  void _handleMv(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('mv: missing operand');
    }

    final src = _resolvePath(parts[1]);
    final dst = _resolvePath(parts[2]);

    if (!_fileSystem.containsKey(src)) {
      throw Exception('mv: cannot stat $src: No such file or directory');
    }

    _fileSystem[dst] = _fileSystem[src]!;
    _fileSystem.remove(src);
  }

  void _handleRm(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('rm: missing operand');
    }

    final filePath = _resolvePath(parts[1]);
    if (!_fileSystem.containsKey(filePath)) {
      throw Exception('rm: cannot remove $filePath: No such file or directory');
    }

    if (_fileSystem[filePath] == 'DIR') {
      throw Exception(
          'rm: cannot remove $filePath: Is a directory (use rmdir)');
    }

    _fileSystem.remove(filePath);
  }

  void _handleRmdir(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('rmdir: missing operand');
    }

    final dirPath = _resolvePath(parts[1]);
    if (!_directoryExists(dirPath)) {
      throw Exception('rmdir: cannot remove $dirPath: No such file or directory');
    }

    // Check if directory is empty
    final hasContents = _fileSystem.keys
        .any((key) => key.startsWith(dirPath + '/') && key != dirPath);
    if (hasContents) {
      throw Exception('rmdir: failed to remove $dirPath: Directory not empty');
    }

    _fileSystem.remove(dirPath);
  }

  void _handleGrep(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('grep: usage: grep pattern file');
    }

    final pattern = parts[1];
    final filePath = _resolvePath(parts[2]);

    if (!_fileSystem.containsKey(filePath)) {
      throw Exception('grep: $filePath: No such file or directory');
    }

    final content = _fileSystem[filePath] ?? '';
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.contains(pattern)) {
        _output.add(line);
      }
    }
  }

  void _handleFind(String line) {
    final trimmed = line.trim();

    // Simple find . -name "*.txt"
    if (trimmed.contains('-name')) {
      final parts = trimmed.split(RegExp(r'\s+'));
      final nameIndex = parts.indexOf('-name');
      if (nameIndex < 0 || nameIndex + 1 >= parts.length) {
        throw Exception('find: -name requires an argument');
      }

      final pattern = _unquoteString(parts[nameIndex + 1]);
      final regex = RegExp('^' + pattern.replaceAll('*', '.*') + r'$');

      for (final filePath in _fileSystem.keys) {
        if (_fileSystem[filePath] != 'DIR') {
          final fileName = filePath.split('/').last;
          if (regex.hasMatch(fileName)) {
            _output.add('./' + filePath.split('/').skip(3).join('/'));
          }
        }
      }
      return;
    }

    throw Exception('find: unsupported syntax');
  }

  void _handleHistory() {
    for (var i = 0; i < _commandHistory.length; i++) {
      _output.add('${i + 1} ${_commandHistory[i]}');
    }
  }

  String _resolvePath(String path) {
    if (path.startsWith('/')) {
      return path;
    }
    if (path == '.') {
      return _currentDirectory;
    }
    if (path.startsWith('./')) {
      return _currentDirectory + '/' + path.substring(2);
    }
    return _currentDirectory + '/' + path;
  }

  bool _directoryExists(String path) {
    if (path == '/home/ubuntu') return true;
    return _fileSystem.containsKey(path) && _fileSystem[path] == 'DIR';
  }

  List<String> _listDirectory(String path, {bool showHidden = false}) {
    final items = <String>[];
    final prefix = path.endsWith('/') ? path : path + '/';

    for (final key in _fileSystem.keys) {
      if (key.startsWith(prefix)) {
        final relative = key.substring(prefix.length);
        if (!relative.contains('/')) {
          // Direct child
          if (showHidden || !relative.startsWith('.')) {
            items.add(relative);
          }
        }
      }
    }

    // Add hidden files if requested
    if (showHidden && path == _currentDirectory) {
      items.add('.bashrc');
      items.add('.profile');
    }

    return items.toSet().toList()..sort();
  }

  String _unquoteString(String str) {
    if ((str.startsWith('"') && str.endsWith('"')) ||
        (str.startsWith("'") && str.endsWith("'"))) {
      return str.substring(1, str.length - 1);
    }
    return str;
  }
}

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
