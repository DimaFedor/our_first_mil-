import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/git_branching_simulator.dart';
import '../models/lesson_model.dart';

class GitChallengeWidget extends StatefulWidget {
  final CodingChallenge challenge;
  final Color courseColor;
  final VoidCallback onComplete;

  const GitChallengeWidget({
    super.key,
    required this.challenge,
    required this.courseColor,
    required this.onComplete,
  });

  @override
  State<GitChallengeWidget> createState() => _GitChallengeWidgetState();
}

class _GitChallengeWidgetState extends State<GitChallengeWidget> {
  final GitBranchingSimulator _simulator = GitBranchingSimulator();
  late final TextEditingController _commandsController;
  late final GitChallengeGoal _goal;

  GitSimulationState _state = GitBranchingSimulator.initialState();
  String _output = '';
  bool _hasError = false;
  bool _testsPassed = false;
  bool _isRunning = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _commandsController = TextEditingController(
      text: widget.challenge.starterCode,
    );
    final goalDsl = widget.challenge.testCases.isNotEmpty
        ? widget.challenge.testCases.first.expectedOutput
        : '';
    _goal = GitChallengeGoal.fromDsl(goalDsl);
  }

  @override
  void dispose() {
    _commandsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final goalText = widget.challenge.testCases.isNotEmpty
        ? widget.challenge.testCases.first.input.trim()
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.challenge.title,
            style: TextStyle(
              color: onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: 10),
          Text(
            widget.challenge.description,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.75),
              fontSize: 16,
              height: 1.45,
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          _GoalCard(
            courseColor: widget.courseColor,
            goalText: goalText,
            checklist: _goal.toChecklist(),
          ),
          const SizedBox(height: 16),
          _GraphCard(
            state: _state,
            courseColor: widget.courseColor,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 16),
          _QuickCommandBar(
            courseColor: widget.courseColor,
            onInsert: _insertCommand,
          ),
          const SizedBox(height: 16),
          _buildCommandEditor(isDarkTheme, l10n),
          const SizedBox(height: 12),
          if (widget.challenge.hint != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showHint = !_showHint;
                });
              },
              icon: Icon(
                _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                color: widget.courseColor,
              ),
              label: Text(
                _showHint
                    ? l10n?.get('hide_hint') ?? 'Hide Hint'
                    : l10n?.get('show_hint') ?? 'Show Hint',
                style: TextStyle(color: widget.courseColor),
              ),
            ),
          if (_showHint && widget.challenge.hint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: widget.courseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.courseColor.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                widget.challenge.hint!,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.78),
                  height: 1.4,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runSimulation,
                    icon: _isRunning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isRunning
                          ? l10n?.get('running') ?? 'Running...'
                          : l10n?.get('run_simulation') ?? 'Run Simulation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.courseColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _isRunning ? null : _resetSimulation,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n?.get('reset') ?? 'Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onSurface,
                    side: BorderSide(color: onSurface.withValues(alpha: 0.22)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OutputCard(
              output: _output,
              hasError: _hasError,
              courseColor: widget.courseColor,
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0),
          ],
          if (_testsPassed) ...[
            const SizedBox(height: 16),
            _SuccessCard(
              courseColor: widget.courseColor,
            ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.courseColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n?.get('complete_lesson') ?? 'Complete Lesson',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommandEditor(bool isDarkTheme, AppLocalizations? l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError
              ? Colors.red.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.32),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.get('git_terminal') ?? 'Git Terminal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.courseColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'GIT',
                    style: TextStyle(
                      color: widget.courseColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _commandsController,
            maxLines: 9,
            minLines: 9,
            style: TextStyle(
              color: isDarkTheme ? Colors.grey.shade100 : Colors.grey.shade200,
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.5,
            ),
            cursorColor: widget.courseColor,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              hintText:
                  l10n?.get('type_git_commands') ?? 'Type git commands here...',
              hintStyle: const TextStyle(
                color: Color(0xFF7D8590),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _insertCommand(String command) {
    final current = _commandsController.text.trimRight();
    if (current.isEmpty) {
      _commandsController.text = command;
      return;
    }

    if (current.endsWith('\n')) {
      _commandsController.text = '$current$command';
    } else {
      _commandsController.text = '$current\n$command';
    }
  }

  Future<void> _runSimulation() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isRunning = true;
      _hasError = false;
      _testsPassed = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;

    final result = _simulator.execute(_commandsController.text);
    final validation = _simulator.validateGoal(
      state: result.state,
      goal: _goal,
    );

    var finalOutput = result.output.trim();
    if (result.hasError) {
      setState(() {
        _state = result.state;
        _output = finalOutput;
        _hasError = true;
        _testsPassed = false;
        _isRunning = false;
      });
      return;
    }

    if (validation.isPassed) {
      finalOutput =
          '$finalOutput\n\n✅ ${l10n?.get('git_goal_complete') ?? 'Goal complete!'}';
    } else {
      finalOutput =
          '$finalOutput\n\n❌ ${l10n?.get('git_goal_not_completed') ?? 'Goal not completed yet:'}\n${validation.failures.map((f) => '• $f').join('\n')}';
    }

    setState(() {
      _state = result.state;
      _output = finalOutput;
      _hasError = false;
      _testsPassed = validation.isPassed;
      _isRunning = false;
    });
  }

  void _resetSimulation() {
    setState(() {
      _state = GitBranchingSimulator.initialState();
      _output = '';
      _hasError = false;
      _testsPassed = false;
      _isRunning = false;
    });
  }
}

class _GoalCard extends StatelessWidget {
  final Color courseColor;
  final String goalText;
  final List<String> checklist;

  const _GoalCard({
    required this.courseColor,
    required this.goalText,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: courseColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: courseColor, size: 16),
              const SizedBox(width: 8),
              Text(
                l10n?.get('challenge_goal') ?? 'Challenge Goal',
                style: TextStyle(
                  color: courseColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (goalText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              goalText,
              style: TextStyle(color: onSurface, fontSize: 14, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          ...checklist.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCommandBar extends StatelessWidget {
  final Color courseColor;
  final ValueChanged<String> onInsert;

  const _QuickCommandBar({required this.courseColor, required this.onInsert});

  @override
  Widget build(BuildContext context) {
    const quickCommands = <String>[
      'git status',
      'git commit -m "init"',
      'git branch feature',
      'git checkout feature',
      'git checkout -b feature',
      'git merge feature',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickCommands
          .map(
            (command) => InkWell(
              onTap: () => onInsert(command),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: courseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: courseColor.withValues(alpha: 0.32),
                  ),
                ),
                child: Text(
                  command,
                  style: TextStyle(
                    color: courseColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _GraphCard extends StatelessWidget {
  final GitSimulationState state;
  final Color courseColor;
  final bool isDarkTheme;

  const _GraphCard({
    required this.state,
    required this.courseColor,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: courseColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_rounded, color: courseColor, size: 16),
              const SizedBox(width: 8),
              Text(
                l10n?.get('repository_graph') ?? 'Repository Graph',
                style: TextStyle(
                  color: courseColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: 350.ms,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _GitGraphView(
              key: ValueKey(
                '${state.commits.length}-${state.head}-${state.branches}',
              ),
              state: state,
              courseColor: courseColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GitGraphView extends StatelessWidget {
  final GitSimulationState state;
  final Color courseColor;

  const _GitGraphView({
    super.key,
    required this.state,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    final commits = state.commits;
    final laneWidth = 128.0;
    final rowHeight = 88.0;
    final width = (state.laneCount * laneWidth) + 120;
    final height = (commits.length * rowHeight) + 100;

    final positions = <String, Offset>{};
    for (final commit in commits) {
      positions[commit.id] = Offset(
        64 + commit.lane * laneWidth,
        52 + commit.order * rowHeight,
      );
    }

    final branchesByCommit = state.branchesByCommit;

    return SizedBox(
      height: 310,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, height),
                  painter: _GitEdgePainter(
                    commits: commits,
                    positions: positions,
                    courseColor: courseColor,
                  ),
                ),
                for (final commit in commits)
                  _CommitNode(
                    commit: commit,
                    position: positions[commit.id]!,
                    state: state,
                    color: _laneColor(commit.lane, courseColor),
                  ),
                for (final entry in branchesByCommit.entries)
                  ..._branchTags(
                    commitId: entry.key,
                    branches: entry.value,
                    position: positions[entry.key],
                    state: state,
                    courseColor: courseColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _branchTags({
    required String commitId,
    required List<String> branches,
    required Offset? position,
    required GitSimulationState state,
    required Color courseColor,
  }) {
    if (position == null) return const <Widget>[];

    return List<Widget>.generate(branches.length, (index) {
      final branch = branches[index];
      final isHead = branch == state.head;
      return Positioned(
        left: position.dx + 20 + (index * 74),
        top: position.dy - 28,
        child: AnimatedContainer(
          duration: 240.ms,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: isHead
                ? const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                  )
                : LinearGradient(
                    colors: [courseColor, courseColor.withValues(alpha: 0.75)],
                  ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isHead ? 'HEAD:$branch' : branch,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    });
  }
}

class _CommitNode extends StatelessWidget {
  final GitCommitNode commit;
  final Offset position;
  final GitSimulationState state;
  final Color color;

  const _CommitNode({
    required this.commit,
    required this.position,
    required this.state,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isHeadTip = state.branches[state.head] == commit.id;
    final isAnyTip = state.branches.values.contains(commit.id);
    final size = isHeadTip ? 44.0 : 36.0;

    return Positioned(
      left: position.dx - (size / 2),
      top: position.dy - (size / 2),
      child: AnimatedContainer(
        duration: 260.ms,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHeadTip ? color : color.withValues(alpha: 0.9),
          border: Border.all(
            color: isAnyTip
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            width: isAnyTip ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          commit.id,
          style: TextStyle(
            color: Colors.white,
            fontSize: isHeadTip ? 11 : 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _GitEdgePainter extends CustomPainter {
  final List<GitCommitNode> commits;
  final Map<String, Offset> positions;
  final Color courseColor;

  _GitEdgePainter({
    required this.commits,
    required this.positions,
    required this.courseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    for (final commit in commits) {
      final child = positions[commit.id];
      if (child == null) continue;

      for (final parentId in commit.parents) {
        final parent = positions[parentId];
        if (parent == null) continue;

        paint.color = _laneColor(
          commit.lane,
          courseColor,
        ).withValues(alpha: 0.78);

        final path = Path()
          ..moveTo(parent.dx, parent.dy)
          ..cubicTo(
            parent.dx,
            parent.dy + 24,
            child.dx,
            child.dy - 24,
            child.dx,
            child.dy,
          );
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GitEdgePainter oldDelegate) {
    return oldDelegate.commits != commits ||
        oldDelegate.positions != positions ||
        oldDelegate.courseColor != courseColor;
  }
}

class _OutputCard extends StatelessWidget {
  final String output;
  final bool hasError;
  final Color courseColor;

  const _OutputCard({
    required this.output,
    required this.hasError,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? Colors.red.withValues(alpha: 0.55)
              : courseColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.terminal_rounded,
                color: hasError ? Colors.red : courseColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                hasError
                    ? l10n?.get('simulation_error') ?? 'Simulation error'
                    : l10n?.get('simulation_output') ?? 'Simulation output',
                style: TextStyle(
                  color: hasError ? Colors.red : courseColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            output,
            style: TextStyle(
              color: hasError ? Colors.red.shade300 : Colors.green.shade300,
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final Color courseColor;

  const _SuccessCard({required this.courseColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n?.get('git_goal_success') ??
                  'Great work! You reached the Git goal. Complete the lesson to get XP.',
              style: TextStyle(color: onSurface, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

Color _laneColor(int lane, Color fallback) {
  const palette = <Color>[
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF22C55E),
  ];

  if (lane < palette.length) {
    return palette[lane];
  }
  return fallback;
}
