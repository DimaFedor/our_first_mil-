class BashInterpreter {
  final Map<String, String> fileSystem = {};
  final List<String> output = [];
  final List<String> commandHistory = [];
  String currentDirectory = '/home/ubuntu';
  String? error;

  InterpreterResult execute(String code) {
    output.clear();
    error = null;

    try {
      final lines = preprocessCode(code);
      executeLines(lines);
    } catch (e) {
      error = formatError(e.toString());
    }

    return InterpreterResult(
      output: output.join('\n'),
      error: error,
      variables: {
        'pwd': currentDirectory,
        'fs_tree': buildFsTree(),
        'fs_contents': getCurrentDirectoryContents(),
      },
    );
  }

  String buildFsTree() {
    final dirs = fileSystem.keys.where((p) => fileSystem[p] == 'DIR').toList();
    dirs.sort();
    return dirs.join('\n');
  }

  Map<String, bool> getCurrentDirectoryContents() {
    final contents = <String, bool>{};
    for (final path in fileSystem.keys) {
      final parentDir = path.substring(0, path.lastIndexOf('/'));
      if (parentDir == currentDirectory) {
        final name = path.substring(path.lastIndexOf('/') + 1);
        contents[name] = fileSystem[path] == 'DIR';
      }
    }
    return contents;
  }

  String formatError(String error) {
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

  List<String> preprocessCode(String code) {
    final lines = <String>[];
    for (var line in code.split('\n')) {
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

  void executeLines(List<String> lines) {
    for (final line in lines) {
      commandHistory.add(line);

      if (line.trim() == 'pwd') {
        output.add(currentDirectory);
        continue;
      }

      if (line.trim().startsWith('cd ')) {
        handleCd(line);
        continue;
      }

      if (line.trim().startsWith('ls')) {
        handleLs(line);
        continue;
      }

      if (line.trim().startsWith('mkdir ')) {
        handleMkdir(line);
        continue;
      }

      if (line.trim().startsWith('touch ')) {
        handleTouch(line);
        continue;
      }

      if (line.trim().startsWith('cat ')) {
        handleCat(line);
        continue;
      }

      if (line.trim().startsWith('echo ')) {
        handleEcho(line);
        continue;
      }

      if (line.trim().startsWith('cp ')) {
        handleCp(line);
        continue;
      }

      if (line.trim().startsWith('mv ')) {
        handleMv(line);
        continue;
      }

      if (line.trim().startsWith('rm ')) {
        handleRm(line);
        continue;
      }

      if (line.trim().startsWith('rmdir ')) {
        handleRmdir(line);
        continue;
      }

      if (line.trim().startsWith('grep ')) {
        handleGrep(line);
        continue;
      }

      if (line.trim().startsWith('find ')) {
        handleFind(line);
        continue;
      }

      if (line.trim() == 'history') {
        handleHistory();
        continue;
      }

      throw Exception('Command not found: ${line.split(' ').first}');
    }
  }

  void handleCd(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('cd: missing argument');
    }

    final target = parts[1];
    final newDir = resolvePath(target);

    if (!directoryExists(newDir) && target != '/') {
      throw Exception('cd: $target: No such file or directory');
    }

    currentDirectory = newDir;
  }

  void handleLs(String line) {
    final args = line.trim().split(RegExp(r'\s+'));
    final showHidden = args.contains('-a');
    final path = args.length > 1 && !args[1].startsWith('-')
        ? resolvePath(args[1])
        : currentDirectory;

    if (!directoryExists(path)) {
      throw Exception('ls: cannot access $path: No such file or directory');
    }

    final items = listDirectory(path, showHidden: showHidden);
    for (final item in items) {
      output.add(item);
    }
  }

  void handleMkdir(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('mkdir: missing operand');
    }

    final dirPath = resolvePath(parts[1]);
    if (directoryExists(dirPath)) {
      throw Exception('mkdir: cannot create directory $dirPath: File exists');
    }

    fileSystem[dirPath] = 'DIR';
  }

  void handleTouch(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('touch: missing file operand');
    }

    final filePath = resolvePath(parts[1]);
    if (!fileSystem.containsKey(filePath)) {
      fileSystem[filePath] = '';
    }
  }

  void handleCat(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('cat: missing file operand');
    }

    final filePath = resolvePath(parts[1]);
    if (!fileSystem.containsKey(filePath)) {
      throw Exception('cat: $filePath: No such file or directory');
    }

    final content = fileSystem[filePath];
    if (content == 'DIR') {
      throw Exception('cat: $filePath: Is a directory');
    }

    output.add(content ?? '');
  }

  void handleEcho(String line) {
    final trimmed = line.trim();

    if (trimmed.contains('>')) {
      final parts = trimmed.split(RegExp(r'\s*>\s*'));
      if (parts.length != 2) {
        throw Exception('echo: invalid redirection');
      }

      final textPart = parts[0].replaceFirst(RegExp(r'^echo\s+'), '');
      final filePath = resolvePath(parts[1].trim());
      final text = unquoteString(textPart);

      fileSystem[filePath] = text;
      return;
    }

    final textPart = trimmed.replaceFirst(RegExp(r'^echo\s+'), '');
    final text = unquoteString(textPart);
    output.add(text);
  }

  void handleCp(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('cp: missing operand');
    }

    final src = resolvePath(parts[1]);
    final dst = resolvePath(parts[2]);

    if (!fileSystem.containsKey(src)) {
      throw Exception('cp: cannot stat $src: No such file or directory');
    }

    fileSystem[dst] = fileSystem[src]!;
  }

  void handleMv(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('mv: missing operand');
    }

    final src = resolvePath(parts[1]);
    final dst = resolvePath(parts[2]);

    if (!fileSystem.containsKey(src)) {
      throw Exception('mv: cannot stat $src: No such file or directory');
    }

    fileSystem[dst] = fileSystem[src]!;
    fileSystem.remove(src);
  }

  void handleRm(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('rm: missing operand');
    }

    final filePath = resolvePath(parts[1]);
    if (!fileSystem.containsKey(filePath)) {
      throw Exception('rm: cannot remove $filePath: No such file or directory');
    }

    if (fileSystem[filePath] == 'DIR') {
      throw Exception(
        'rm: cannot remove $filePath: Is a directory (use rmdir)',
      );
    }

    fileSystem.remove(filePath);
  }

  void handleRmdir(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw Exception('rmdir: missing operand');
    }

    final dirPath = resolvePath(parts[1]);
    if (!directoryExists(dirPath)) {
      throw Exception(
        'rmdir: cannot remove $dirPath: No such file or directory',
      );
    }

    final hasContents = fileSystem.keys.any(
      (key) => key.startsWith('$dirPath/') && key != dirPath,
    );
    if (hasContents) {
      throw Exception('rmdir: failed to remove $dirPath: Directory not empty');
    }

    fileSystem.remove(dirPath);
  }

  void handleGrep(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length < 3) {
      throw Exception('grep: usage: grep pattern file');
    }

    final pattern = parts[1];
    final filePath = resolvePath(parts[2]);

    if (!fileSystem.containsKey(filePath)) {
      throw Exception('grep: $filePath: No such file or directory');
    }

    final content = fileSystem[filePath] ?? '';
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.contains(pattern)) {
        output.add(line);
      }
    }
  }

  void handleFind(String line) {
    final trimmed = line.trim();

    if (trimmed.contains('-name')) {
      final parts = trimmed.split(RegExp(r'\s+'));
      final nameIndex = parts.indexOf('-name');
      if (nameIndex < 0 || nameIndex + 1 >= parts.length) {
        throw Exception('find: -name requires an argument');
      }

      final pattern = unquoteString(parts[nameIndex + 1]);
      final regex = RegExp(
        '^${RegExp.escape(pattern).replaceAll(r'\*', '.*')}'
        r'$',
      );

      for (final filePath in fileSystem.keys) {
        if (fileSystem[filePath] != 'DIR') {
          final fileName = filePath.split('/').last;
          if (regex.hasMatch(fileName)) {
            output.add('./${filePath.split('/').skip(3).join('/')}');
          }
        }
      }
      return;
    }

    throw Exception('find: unsupported syntax');
  }

  void handleHistory() {
    for (var i = 0; i < commandHistory.length; i++) {
      output.add('${i + 1} ${commandHistory[i]}');
    }
  }

  String resolvePath(String path) {
    if (path.startsWith('/')) {
      return path;
    }
    if (path == '.') {
      return currentDirectory;
    }
    if (path.startsWith('./')) {
      return '$currentDirectory/${path.substring(2)}';
    }
    return '$currentDirectory/$path';
  }

  bool directoryExists(String path) {
    if (path == '/home/ubuntu') return true;
    return fileSystem.containsKey(path) && fileSystem[path] == 'DIR';
  }

  List<String> listDirectory(String path, {bool showHidden = false}) {
    final items = <String>[];
    final prefix = path.endsWith('/') ? path : '$path/';

    for (final key in fileSystem.keys) {
      if (key.startsWith(prefix)) {
        final relative = key.substring(prefix.length);
        if (!relative.contains('/')) {
          if (showHidden || !relative.startsWith('.')) {
            items.add(relative);
          }
        }
      }
    }

    if (showHidden && path == currentDirectory) {
      items.add('.bashrc');
      items.add('.profile');
    }

    return items.toSet().toList()..sort();
  }

  String unquoteString(String str) {
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
