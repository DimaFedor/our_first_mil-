import 'package:flutter/material.dart';

@immutable
class GitCommitNode {
  final String id;
  final List<String> parents;
  final int lane;
  final int order;
  final String message;

  const GitCommitNode({
    required this.id,
    required this.parents,
    required this.lane,
    required this.order,
    required this.message,
  });
}

@immutable
class GitSimulationState {
  final List<GitCommitNode> commits;
  final Map<String, String> branches;
  final Map<String, int> branchLanes;
  final String head;

  const GitSimulationState({
    required this.commits,
    required this.branches,
    required this.branchLanes,
    required this.head,
  });

  String? get headCommitId => branches[head];

  int get laneCount {
    if (branchLanes.isEmpty) return 1;
    return branchLanes.values.reduce((a, b) => a > b ? a : b) + 1;
  }

  GitCommitNode? commitById(String id) {
    for (final commit in commits) {
      if (commit.id == id) return commit;
    }
    return null;
  }

  Map<String, List<String>> get branchesByCommit {
    final grouped = <String, List<String>>{};
    for (final entry in branches.entries) {
      grouped.putIfAbsent(entry.value, () => <String>[]).add(entry.key);
    }
    for (final branchesAtCommit in grouped.values) {
      branchesAtCommit.sort((a, b) {
        if (a == head) return -1;
        if (b == head) return 1;
        return a.compareTo(b);
      });
    }
    return grouped;
  }
}

@immutable
class GitSimulationResult {
  final GitSimulationState state;
  final String output;
  final bool hasError;
  final String? error;

  const GitSimulationResult({
    required this.state,
    required this.output,
    required this.hasError,
    this.error,
  });
}

@immutable
class GitChallengeGoal {
  final String? head;
  final Set<String> requiredBranches;
  final int? minCommits;
  final Map<String, String> branchAt;
  final List<GitBranchPair> branchesDiffer;
  final Set<String> mergeCommitOn;

  const GitChallengeGoal({
    this.head,
    this.requiredBranches = const <String>{},
    this.minCommits,
    this.branchAt = const <String, String>{},
    this.branchesDiffer = const <GitBranchPair>[],
    this.mergeCommitOn = const <String>{},
  });

  factory GitChallengeGoal.fromDsl(String dsl) {
    String? head;
    int? minCommits;
    final requiredBranches = <String>{};
    final branchAt = <String, String>{};
    final branchesDiffer = <GitBranchPair>[];
    final mergeCommitOn = <String>{};

    final lines = dsl.split('\n');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('HEAD=')) {
        head = line.substring('HEAD='.length).trim();
        continue;
      }
      if (line.startsWith('MIN_COMMITS=')) {
        minCommits = int.tryParse(line.substring('MIN_COMMITS='.length).trim());
        continue;
      }
      if (line.startsWith('HAS_BRANCH=')) {
        final branch = line.substring('HAS_BRANCH='.length).trim();
        if (branch.isNotEmpty) requiredBranches.add(branch);
        continue;
      }
      if (line.startsWith('BRANCH_AT=')) {
        final rawRule = line.substring('BRANCH_AT='.length).trim();
        final parts = rawRule.split(':');
        if (parts.length == 2) {
          final branch = parts[0].trim();
          final commitId = parts[1].trim();
          if (branch.isNotEmpty && commitId.isNotEmpty) {
            branchAt[branch] = commitId;
          }
        }
        continue;
      }
      if (line.startsWith('BRANCHES_DIFFER=')) {
        final rawRule = line.substring('BRANCHES_DIFFER='.length).trim();
        final parts = rawRule.split(':');
        if (parts.length == 2) {
          final left = parts[0].trim();
          final right = parts[1].trim();
          if (left.isNotEmpty && right.isNotEmpty) {
            branchesDiffer.add(GitBranchPair(left, right));
          }
        }
        continue;
      }
      if (line.startsWith('MERGE_COMMIT_ON=')) {
        final branch = line.substring('MERGE_COMMIT_ON='.length).trim();
        if (branch.isNotEmpty) mergeCommitOn.add(branch);
      }
    }

    return GitChallengeGoal(
      head: head,
      requiredBranches: requiredBranches,
      minCommits: minCommits,
      branchAt: branchAt,
      branchesDiffer: branchesDiffer,
      mergeCommitOn: mergeCommitOn,
    );
  }

  List<String> toChecklist() {
    final checklist = <String>[];

    if (head != null && head!.isNotEmpty) {
      checklist.add('HEAD should be on "$head"');
    }
    if (requiredBranches.isNotEmpty) {
      checklist.add('Create branches: ${requiredBranches.join(', ')}');
    }
    if (minCommits != null) {
      checklist.add('Create at least $minCommits commits');
    }
    for (final entry in branchAt.entries) {
      checklist.add('Point "${entry.key}" at ${entry.value}');
    }
    for (final pair in branchesDiffer) {
      checklist.add(
        'Make "${pair.left}" and "${pair.right}" point to different commits',
      );
    }
    for (final branch in mergeCommitOn) {
      checklist.add('Create a merge commit on "$branch"');
    }

    if (checklist.isEmpty) {
      checklist.add('Run valid git commands to reach the lesson goal');
    }

    return checklist;
  }
}

@immutable
class GitGoalValidationResult {
  final bool isPassed;
  final List<String> failures;

  const GitGoalValidationResult({
    required this.isPassed,
    required this.failures,
  });
}

class GitBranchingSimulator {
  static GitSimulationState initialState() {
    return const GitSimulationState(
      commits: <GitCommitNode>[
        GitCommitNode(
          id: 'C0',
          parents: <String>[],
          lane: 0,
          order: 0,
          message: 'Initial commit',
        ),
      ],
      branches: <String, String>{'main': 'C0'},
      branchLanes: <String, int>{'main': 0},
      head: 'main',
    );
  }

  GitSimulationResult execute(String rawScript) {
    final repo = _MutableGitRepository.initial();
    final commandLines = _parseCommands(rawScript);
    final outputLines = <String>[];

    if (commandLines.isEmpty) {
      const error = 'No commands found. Try: git commit -m "initial"';
      return GitSimulationResult(
        state: repo.toState(),
        output: error,
        hasError: true,
        error: error,
      );
    }

    for (final command in commandLines) {
      outputLines.add('\$ $command');
      try {
        final commandOutput = _runCommand(repo, command);
        if (commandOutput.trim().isNotEmpty) {
          outputLines.add(commandOutput);
        }
      } catch (error) {
        final message = _normalizeError(error);
        outputLines.add('❌ $message');
        outputLines.add('');
        outputLines.add(_summary(repo));
        return GitSimulationResult(
          state: repo.toState(),
          output: outputLines.join('\n'),
          hasError: true,
          error: message,
        );
      }
    }

    outputLines.add('');
    outputLines.add(_summary(repo));

    return GitSimulationResult(
      state: repo.toState(),
      output: outputLines.join('\n'),
      hasError: false,
    );
  }

  GitGoalValidationResult validateGoal({
    required GitSimulationState state,
    required GitChallengeGoal goal,
  }) {
    final failures = <String>[];

    if (goal.head != null && goal.head!.isNotEmpty && state.head != goal.head) {
      failures.add('HEAD is "${state.head}", expected "${goal.head}".');
    }

    for (final requiredBranch in goal.requiredBranches) {
      if (!state.branches.containsKey(requiredBranch)) {
        failures.add('Missing branch "$requiredBranch".');
      }
    }

    if (goal.minCommits != null && state.commits.length < goal.minCommits!) {
      failures.add(
        'Only ${state.commits.length} commits found, expected at least ${goal.minCommits}.',
      );
    }

    for (final entry in goal.branchAt.entries) {
      final actualCommit = state.branches[entry.key];
      if (actualCommit == null) {
        failures.add('Branch "${entry.key}" does not exist.');
        continue;
      }
      if (actualCommit != entry.value) {
        failures.add(
          'Branch "${entry.key}" points to $actualCommit, expected ${entry.value}.',
        );
      }
    }

    for (final pair in goal.branchesDiffer) {
      final leftCommit = state.branches[pair.left];
      final rightCommit = state.branches[pair.right];

      if (leftCommit == null || rightCommit == null) {
        failures.add(
          'Cannot compare "${pair.left}" and "${pair.right}" because one branch is missing.',
        );
        continue;
      }

      if (leftCommit == rightCommit) {
        failures.add(
          'Branches "${pair.left}" and "${pair.right}" still point to the same commit ($leftCommit).',
        );
      }
    }

    for (final branch in goal.mergeCommitOn) {
      final commitId = state.branches[branch];
      if (commitId == null) {
        failures.add('Branch "$branch" does not exist.');
        continue;
      }
      final commit = state.commitById(commitId);
      if (commit == null || commit.parents.length < 2) {
        failures.add('Branch "$branch" does not end with a merge commit.');
      }
    }

    return GitGoalValidationResult(
      isPassed: failures.isEmpty,
      failures: List<String>.unmodifiable(failures),
    );
  }

  List<String> _parseCommands(String rawScript) {
    final flattened = rawScript.replaceAll(';', '\n');
    final commands = <String>[];

    for (final rawLine in flattened.split('\n')) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final commentIndex = trimmed.indexOf('#');
      if (commentIndex > 0) {
        final withoutComment = trimmed.substring(0, commentIndex).trim();
        if (withoutComment.isNotEmpty) {
          commands.add(withoutComment);
        }
      } else {
        commands.add(trimmed);
      }
    }

    return commands;
  }

  String _runCommand(_MutableGitRepository repo, String command) {
    final normalized = command.trim();
    final tokens = normalized.split(RegExp(r'\s+'));
    if (tokens.isEmpty || tokens.first != 'git') {
      throw StateError('Only commands starting with "git" are supported.');
    }
    if (tokens.length < 2) {
      throw StateError('Incomplete git command.');
    }

    final verb = tokens[1];
    switch (verb) {
      case 'init':
        return 'Initialized empty Git repository in-memory.';
      case 'status':
        final headCommit = repo.branches[repo.head];
        return 'On branch ${repo.head}\nLatest commit: $headCommit';
      case 'branch':
        return _handleBranch(repo, tokens);
      case 'checkout':
      case 'switch':
        return _handleCheckout(repo, tokens);
      case 'commit':
        return _handleCommit(repo, normalized);
      case 'merge':
        return _handleMerge(repo, tokens);
      case 'log':
        return _handleLog(repo);
      default:
        throw StateError(
          'Unsupported command "$normalized". Supported: git status, git commit, git branch, git checkout, git switch, git merge, git log.',
        );
    }
  }

  String _handleBranch(_MutableGitRepository repo, List<String> tokens) {
    if (tokens.length == 2) {
      final sorted = repo.branches.keys.toList()..sort();
      return sorted
          .map((branch) {
            final marker = branch == repo.head ? '*' : ' ';
            return '$marker $branch -> ${repo.branches[branch]}';
          })
          .join('\n');
    }

    final branchName = tokens[2].trim();
    _validateBranchName(branchName);

    if (repo.branches.containsKey(branchName)) {
      throw StateError('Branch "$branchName" already exists.');
    }

    repo.branches[branchName] = repo.branches[repo.head]!;
    repo.branchLanes[branchName] = repo.nextLane;
    repo.nextLane += 1;

    return 'Created branch "$branchName" at ${repo.branches[branchName]}.';
  }

  String _handleCheckout(_MutableGitRepository repo, List<String> tokens) {
    if (tokens.length < 3) {
      throw StateError('Specify branch name: git checkout <branch>.');
    }

    if (tokens[2] == '-b' || tokens[2] == '-c') {
      if (tokens.length < 4) {
        throw StateError('Specify new branch name after ${tokens[2]}.');
      }
      final newBranch = tokens[3].trim();
      _validateBranchName(newBranch);
      if (repo.branches.containsKey(newBranch)) {
        throw StateError('Branch "$newBranch" already exists.');
      }
      repo.branches[newBranch] = repo.branches[repo.head]!;
      repo.branchLanes[newBranch] = repo.nextLane;
      repo.nextLane += 1;
      repo.head = newBranch;
      return 'Created and switched to branch "$newBranch".';
    }

    final targetBranch = tokens[2].trim();
    if (!repo.branches.containsKey(targetBranch)) {
      throw StateError('Branch "$targetBranch" does not exist.');
    }
    repo.head = targetBranch;
    return 'Switched to branch "$targetBranch".';
  }

  String _handleCommit(_MutableGitRepository repo, String command) {
    final currentBranch = repo.head;
    final currentCommit = repo.branches[currentBranch]!;

    final messageMatch = RegExp(r'''-m\s+(['"])(.*?)\1''').firstMatch(command);
    final message =
        messageMatch?.group(2) ??
        'Commit ${repo.nextCommitNumber + 1} on $currentBranch';

    final newCommitId = 'C${repo.nextCommitNumber + 1}';
    repo.nextCommitNumber += 1;

    repo.commits[newCommitId] = GitCommitNode(
      id: newCommitId,
      parents: <String>[currentCommit],
      lane: repo.branchLanes[currentBranch] ?? 0,
      order: repo.nextCommitNumber,
      message: message,
    );
    repo.branches[currentBranch] = newCommitId;

    return 'Created commit $newCommitId on "$currentBranch": $message';
  }

  String _handleMerge(_MutableGitRepository repo, List<String> tokens) {
    if (tokens.length < 3) {
      throw StateError('Specify branch to merge: git merge <branch>.');
    }

    final sourceBranch = tokens[2].trim();
    if (!repo.branches.containsKey(sourceBranch)) {
      throw StateError('Branch "$sourceBranch" does not exist.');
    }
    if (sourceBranch == repo.head) {
      throw StateError('Cannot merge a branch into itself.');
    }

    final targetCommit = repo.branches[sourceBranch]!;
    final currentCommit = repo.branches[repo.head]!;
    if (targetCommit == currentCommit) {
      return 'Already up to date.';
    }

    final mergeCommitId = 'C${repo.nextCommitNumber + 1}';
    repo.nextCommitNumber += 1;
    repo.commits[mergeCommitId] = GitCommitNode(
      id: mergeCommitId,
      parents: <String>[currentCommit, targetCommit],
      lane: repo.branchLanes[repo.head] ?? 0,
      order: repo.nextCommitNumber,
      message: 'Merge branch "$sourceBranch"',
    );
    repo.branches[repo.head] = mergeCommitId;

    return 'Merged "$sourceBranch" into "${repo.head}" with commit $mergeCommitId.';
  }

  String _handleLog(_MutableGitRepository repo) {
    final sorted = repo.commits.values.toList()
      ..sort((a, b) => b.order.compareTo(a.order));
    return sorted.map((commit) => '${commit.id} ${commit.message}').join('\n');
  }

  String _summary(_MutableGitRepository repo) {
    final branchNames = repo.branches.keys.toList()..sort();
    final branchSummary = branchNames
        .map((branch) => '$branch:${repo.branches[branch]}')
        .join(', ');
    return 'HEAD=${repo.head}\nBRANCHES=$branchSummary\nCOMMITS=${repo.commits.length}';
  }

  void _validateBranchName(String branchName) {
    if (branchName.isEmpty) {
      throw StateError('Branch name cannot be empty.');
    }
    final invalidChars = RegExp(r'[^a-zA-Z0-9._/-]');
    if (invalidChars.hasMatch(branchName)) {
      throw StateError(
        'Branch "$branchName" contains invalid characters. Use letters, digits, ., _, /, -',
      );
    }
  }

  String _normalizeError(Object error) {
    return error
        .toString()
        .replaceFirst(RegExp(r'^Bad state:\s*'), '')
        .replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _MutableGitRepository {
  final Map<String, GitCommitNode> commits;
  final Map<String, String> branches;
  final Map<String, int> branchLanes;
  String head;
  int nextCommitNumber;
  int nextLane;

  _MutableGitRepository({
    required this.commits,
    required this.branches,
    required this.branchLanes,
    required this.head,
    required this.nextCommitNumber,
    required this.nextLane,
  });

  factory _MutableGitRepository.initial() {
    return _MutableGitRepository(
      commits: <String, GitCommitNode>{
        'C0': const GitCommitNode(
          id: 'C0',
          parents: <String>[],
          lane: 0,
          order: 0,
          message: 'Initial commit',
        ),
      },
      branches: <String, String>{'main': 'C0'},
      branchLanes: <String, int>{'main': 0},
      head: 'main',
      nextCommitNumber: 0,
      nextLane: 1,
    );
  }

  GitSimulationState toState() {
    final sortedCommits = commits.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return GitSimulationState(
      commits: List<GitCommitNode>.unmodifiable(sortedCommits),
      branches: Map<String, String>.unmodifiable(
        Map<String, String>.from(branches),
      ),
      branchLanes: Map<String, int>.unmodifiable(
        Map<String, int>.from(branchLanes),
      ),
      head: head,
    );
  }
}

@immutable
class GitBranchPair {
  final String left;
  final String right;

  const GitBranchPair(this.left, this.right);
}
