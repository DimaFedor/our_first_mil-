import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../../design_system/course_glyph.dart';
import '../../../design_system/theme.dart';
import '../../../infrastructure/audio/feedback_service.dart';
import '../../catalog/domain/content.dart';
import '../../journey/presentation/journey_screen.dart';
import '../../practice/data/practice_runner.dart';
import '../../practice/domain/practice_result.dart';
import '../../practice/presentation/code_editor.dart';
import '../../practice/presentation/practice_views.dart';
import '../../progress/domain/learning_data.dart';
import '../domain/learning_session.dart';
import '../application/lesson_application.dart';
import 'theory_content.dart';

class LessonScreen extends ConsumerWidget {
  final String courseId;
  final String lessonId;
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) => AsyncContent(
      value: ref.watch(lessonsProvider(courseId)),
      retry: () => ref.invalidate(lessonsProvider(courseId)),
      builder: (lessons) {
        final index = lessons.indexWhere((item) => item.id == lessonId);
        if (index < 0) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.notFound)),
          );
        }
        final lesson = lessons[index];
        if (index > 0 &&
            !data.completions.containsKey(lessons[index - 1].id) &&
            !data.completions.containsKey(lesson.id)) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.locked)),
          );
        }
        return LessonWorkspace(
          key: ValueKey('${ref.watch(accountProvider)}:$lessonId'),
          lesson: lesson,
          lessons: lessons,
          initial: data.sessions[lessonId],
          preferences: data.preferences,
        );
      },
    ),
  );
}

class LessonWorkspace extends ConsumerStatefulWidget {
  final Lesson lesson;
  final List<Lesson> lessons;
  final LearningSession? initial;
  final Preferences preferences;
  const LessonWorkspace({
    super.key,
    required this.lesson,
    required this.lessons,
    required this.initial,
    required this.preferences,
  });
  @override
  ConsumerState<LessonWorkspace> createState() => LessonWorkspaceState();
}

class LessonWorkspaceState extends ConsumerState<LessonWorkspace> {
  late LearningSession session;
  late TextEditingController editor;
  late String account;
  late LessonApplication application;
  final PracticeRunner runner = PracticeRunner();
  int questionIndex = 0;
  String? selected;
  bool checked = false;
  bool running = false;
  bool completing = false;
  PracticeResult? result;
  CompletionResult? completion;
  String? saveError;

  @override
  void initState() {
    super.initState();
    account = ref.read(accountProvider);
    application = LessonApplication(
      repository: ref.read(repositoryProvider),
      runner: runner,
      account: account,
    );
    final saved = widget.initial;
    session = saved != null && saved.contentVersion == widget.lesson.version
        ? saved
        : LearningSession(
            lessonId: widget.lesson.id,
            contentVersion: widget.lesson.version,
            code: widget.lesson.challenge?.starterCode ?? '',
          );
    editor = CodeEditingController(
      language: widget.lesson.challenge?.language ?? '',
      text: session.code,
    );
    questionIndex = widget.lesson.questions.indexWhere(
      (item) => !session.answers.containsKey(item.id),
    );
    if (questionIndex < 0) questionIndex = widget.lesson.questions.length;
  }

  @override
  void dispose() {
    runner.cancel();
    editor.dispose();
    super.dispose();
  }

  Future<void> persist() async {
    try {
      await ref.read(repositoryProvider).saveSession(account, session);
    } on Exception catch (error) {
      if (mounted) setState(() => saveError = failureMessage(context, error));
    }
  }

  void update(LearningSession next) {
    setState(() {
      session = next;
      saveError = null;
    });
    unawaited(persist());
  }

  void moveTo(LearningStage stage) {
    if (stage == LearningStage.practice && !session.quizPassed(widget.lesson)) {
      showMessage(context, context.l10n.quizRequired);
      return;
    }
    update(session.copyWith(stage: stage));
  }

  Future<void> checkCode() async {
    if (running || widget.lesson.challenge == null) return;
    setState(() {
      running = true;
      result = null;
    });
    final code = editor.text;
    final next = await application.check(widget.lesson, code);
    if (!mounted) return;
    setState(() {
      running = false;
      result = next;
    });
    update(session.copyWith(code: code, practicePassed: next.passed));
    await ref
        .read(feedbackProvider)
        .play(
          next.passed ? FeedbackCue.codePassed : FeedbackCue.incorrect,
          widget.preferences,
        );
  }

  Future<void> finish() async {
    if (completing) return;
    setState(() => completing = true);
    try {
      final outcome = await application.complete(
        widget.lesson,
        session,
        widget.lessons.length,
      );
      await ref.read(dataProvider.notifier).reload();
      if (!mounted) return;
      setState(() {
        completion = outcome;
        session = session.copyWith(stage: LearningStage.complete);
      });
      await ref
          .read(feedbackProvider)
          .play(
            outcome.levelUp
                ? FeedbackCue.level
                : outcome.achievements.isNotEmpty
                ? FeedbackCue.achievement
                : FeedbackCue.complete,
            widget.preferences,
          );
    } on Exception catch (error) {
      if (mounted) showMessage(context, failureMessage(context, error));
    } finally {
      if (mounted) setState(() => completing = false);
    }
  }

  void answer() {
    final questions = widget.lesson.questions;
    if (questionIndex >= questions.length || selected == null) return;
    final question = questions[questionIndex];
    update(
      session.copyWith(answers: {...session.answers, question.id: selected!}),
    );
    setState(() => checked = true);
    unawaited(
      ref
          .read(feedbackProvider)
          .play(
            selected == question.correctOptionId
                ? FeedbackCue.correct
                : FeedbackCue.incorrect,
            widget.preferences,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: Center(
              child: Text(
                '${lesson.xp} XP',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final entry in {
                  LearningStage.theory: l.theory,
                  LearningStage.quiz: l.quiz,
                  LearningStage.practice: l.practice,
                }.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: session.stage == entry.key,
                    onSelected: (value) => moveTo(entry.key),
                  ),
              ],
            ),
          ),
          if (lesson.sourceLocale != widget.preferences.learningLocale)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l.sourceFallback,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (saveError != null)
            MaterialBanner(
              content: Text(saveError!),
              actions: [TextButton(onPressed: persist, child: Text(l.retry))],
            ),
          Expanded(
            child: PageBody(
              maxWidth: session.stage == LearningStage.practice ? 1160 : 720,
              children: switch (session.stage) {
                LearningStage.theory => buildTheory(
                  context,
                  lesson,
                  session,
                  update,
                  moveTo,
                ),
                LearningStage.quiz => quiz(context),
                LearningStage.practice => practice(context),
                LearningStage.complete => complete(context),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> quiz(BuildContext context) {
    final questions = widget.lesson.questions;
    final l = context.l10n;
    if (questionIndex >= questions.length) {
      final passed = session.quizPassed(widget.lesson);
      return [
        EmptyState(
          icon: passed ? Icons.task_alt_rounded : Icons.refresh_rounded,
          title: passed ? l.quizPassed : l.quizFailed,
          body: l.correctCount(
            session.correctAnswers(widget.lesson),
            questions.length,
          ),
          action: FilledButton(
            onPressed: () {
              if (passed) {
                moveTo(LearningStage.practice);
              } else {
                setState(() {
                  questionIndex = 0;
                  selected = null;
                  checked = false;
                });
                update(session.copyWith(answers: {}, practicePassed: false));
              }
            },
            child: Text(passed ? l.practice : l.retryQuiz),
          ),
        ),
      ];
    }
    final question = questions[questionIndex];
    return [
      Text(
        '${questionIndex + 1} / ${questions.length}',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      const SizedBox(height: 14),
      LinearProgressIndicator(
        value: questionIndex / questions.length,
        borderRadius: BorderRadius.circular(8),
      ),
      const SizedBox(height: 28),
      Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 24),
      RadioGroup<String>(
        groupValue: selected,
        onChanged: (value) {
          if (!checked) setState(() => selected = value);
        },
        child: Column(
          children: [
            for (var index = 0; index < question.options.length; index++) ...[
              Card(
                color: selected == question.optionIds[index]
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: RadioListTile<String>(
                  value: question.optionIds[index],
                  enabled: !checked,
                  title: Text(question.options[index]),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      if (checked)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected == question.correctOptionId ? l.correct : l.incorrect,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(question.explanation),
            ],
          ),
        ),
      const SizedBox(height: 24),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FilledButton(
          onPressed: selected == null
              ? null
              : () {
                  if (!checked) {
                    answer();
                  } else {
                    setState(() {
                      questionIndex++;
                      selected = null;
                      checked = false;
                    });
                  }
                },
          child: Text(checked ? l.next : l.checkAnswer),
        ),
      ),
    ];
  }

  List<Widget> practice(BuildContext context) {
    final challenge = widget.lesson.challenge;
    final l = context.l10n;
    if (challenge == null) {
      return [
        FilledButton(
          onPressed: completing ? null : finish,
          child: Text(l.completeLesson),
        ),
      ];
    }
    final condition = Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(challenge.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SelectableText(
            challenge.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Text(l.simulatorNotice, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: session.hintRevealed
                ? null
                : () => runAction(context, () async {
                    await ref
                        .read(repositoryProvider)
                        .revealHint(account, session);
                    update(session.copyWith(hintRevealed: true));
                    await ref.read(dataProvider.notifier).reload();
                    await ref
                        .read(feedbackProvider)
                        .play(FeedbackCue.hint, widget.preferences);
                  }),
            icon: const Icon(Icons.lightbulb_outline_rounded),
            label: Text(l.hint),
          ),
          if (session.hintRevealed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(challenge.hint),
            ),
          if (result?.visualization.isNotEmpty ?? false) ...[
            const SizedBox(height: 20),
            SimulationView(value: result!.visualization),
          ],
        ],
      ),
    );
    final coding = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111113),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C2C30)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.code_rounded, color: brandMint, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    challenge.language,
                    style: const TextStyle(color: Color(0xFF98979F)),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l.resetCode,
                    onPressed: () {
                      editor.text = challenge.starterCode;
                      update(
                        session.copyWith(
                          code: editor.text,
                          practicePassed: false,
                        ),
                      );
                      setState(() => result = null);
                    },
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      color: Color(0xFF98979F),
                    ),
                  ),
                ],
              ),
              LearningCodeEditor(
                controller: editor,
                readOnly: running,
                onChanged: (value) {
                  update(session.copyWith(code: value, practicePassed: false));
                  if (result != null) setState(() => result = null);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l.draftSaved, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: running ? null : () => runAction(context, checkCode),
              icon: running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(running ? l.running : l.runCode),
            ),
            if (running)
              OutlinedButton(
                onPressed: runner.cancel,
                child: Text(l.cancelRun),
              ),
            OutlinedButton.icon(
              onPressed: () => saveSnippet(context),
              icon: const Icon(Icons.bookmark_border_rounded),
              label: Text(l.savePortfolio),
            ),
          ],
        ),
        if (result != null) ...[
          const SizedBox(height: 20),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result!.passed ? l.testPassed : l.testFailed,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l.practiceChecks(result!.passedCount, result!.totalCount)),
                if (result!.output.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  CodePanel(code: result!.output, language: ''),
                ],
                if (result!.diagnostic.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(switch (result!.diagnostic) {
                      'resultMismatch' => l.outputMismatch,
                      'timeout' => l.executionTimeout,
                      'cancelled' => l.executionStopped,
                      'workerUnavailable' => l.practiceUnavailable,
                      'unsupportedCode' => l.unsupportedCode,
                      _ => result!.diagnostic,
                    }),
                  ),
              ],
            ),
          ),
        ],
        if (session.practicePassed) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: completing ? null : finish,
            icon: const Icon(Icons.check_rounded),
            label: Text(l.completeLesson),
          ),
        ],
      ],
    );
    return [
      LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 850
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: condition),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: coding),
                ],
              )
            : Column(children: [condition, const SizedBox(height: 20), coding]),
      ),
    ];
  }

  Future<void> saveSnippet(BuildContext context) async {
    final entry = PortfolioEntry.fromJson({
      'id': 'snippet:${DateTime.now().microsecondsSinceEpoch}',
      'title': widget.lesson.title,
      'language': widget.lesson.challenge?.language ?? '',
      'code': editor.text,
      'notes': '',
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    await runAction(
      context,
      () => ref
          .read(dataProvider.notifier)
          .perform(
            (repository, account) => repository.savePortfolio(account, entry),
          ),
      success: context.l10n.saved,
    );
  }

  List<Widget> complete(BuildContext context) {
    final l = context.l10n;
    final index = widget.lessons.indexWhere(
      (item) => item.id == widget.lesson.id,
    );
    return [
      Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: courseColor(widget.lesson.courseId),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color:
                    courseColor(widget.lesson.courseId).computeLuminance() > .5
                    ? const Color(0xFF1A1A18)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              l.lessonComplete,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              completion?.applied == true
                  ? l.completionReward(completion!.xp, completion!.credits)
                  : l.alreadyCompleted,
              textAlign: TextAlign.center,
            ),
            for (final id in completion?.achievements ?? const <String>[])
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFF9F0A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${l.newAchievement}: ${achievementLabel(context, id)}',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            if (index + 1 < widget.lessons.length)
              FilledButton.icon(
                onPressed: () => context.pushReplacement(
                  '/course/${widget.lesson.courseId}/lesson/${widget.lessons[index + 1].id}',
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l.nextLesson),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/course/${widget.lesson.courseId}'),
              child: Text(l.returnCourse),
            ),
          ],
        ),
      ),
    ];
  }
}
