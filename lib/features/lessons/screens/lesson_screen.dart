import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/lesson_localization_service.dart';
import '../../achievements/models/achievement_model.dart';
import '../models/lesson_model.dart';
import '../../courses/models/course_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../../shared/widgets/code_block.dart';
import '../../../shared/widgets/code_editor.dart';
import '../../../core/services/python_interpreter.dart' as py;
import '../../../core/services/js_interpreter.dart' as js;
import '../../../core/services/html_validator.dart';
import '../widgets/git_challenge_widget.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final Course course;
  final Lesson lesson;

  const LessonScreen({super.key, required this.course, required this.lesson});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final localizedLessonsAsync = ref.watch(
      localizedCourseLessonsProvider(widget.course.id),
    );
    final localizedLesson =
        localizedLessonsAsync.valueOrNull?.firstWhere(
          (lesson) => lesson.id == widget.lesson.id,
          orElse: () => widget.lesson,
        ) ??
        widget.lesson;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme
                ? const [
                    Color(0xFF0A0E27),
                    Color(0xFF1A1F3A),
                    Color(0xFF0D1B3A),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFEEF3FF),
                    Color(0xFFE6EEFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(localizedLesson),

              // Tab Bar
              _buildTabBar(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTheoryTab(localizedLesson),
                    _buildQuizTab(localizedLesson),
                    _buildCodingTab(localizedLesson),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Lesson lesson) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.course.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: widget.course.color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.xpReward} XP',
                      style: TextStyle(
                        color: widget.course.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildTabBar() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.course.color,
              widget.course.color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: isDarkTheme ? Colors.white : const Color(0xFF0B1220),
        unselectedLabelColor: onSurface.withValues(alpha: 0.6),
        tabs: [
          Tab(text: AppLocalizations.of(context)?.get('theory') ?? 'Theory'),
          Tab(text: AppLocalizations.of(context)?.get('quiz') ?? 'Quiz'),
          Tab(text: AppLocalizations.of(context)?.get('code') ?? 'Code'),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  Widget _buildTheoryTab(Lesson lesson) {
    if (lesson.theorySlides.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.get('no_theory') ??
              'No theory available',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: lesson.theorySlides.length,
            onPageChanged: (index) {
              setState(() {
                _currentSlideIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _TheorySlideWidget(
                slide: lesson.theorySlides[index],
                courseColor: widget.course.color,
                courseId: widget.course.id,
              );
            },
          ),
        ),

        // Progress Indicator
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              lesson.theorySlides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentSlideIndex == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentSlideIndex == index
                      ? widget.course.color
                      : Colors.white30,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // Continue Button
        if (_currentSlideIndex == lesson.theorySlides.length - 1)
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContinueButton(
              AppLocalizations.of(context)?.get('continue_to_quiz') ??
                  'Continue to Quiz',
            ),
          ),
      ],
    );
  }

  Widget _buildQuizTab(Lesson lesson) {
    if (lesson.quiz == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.get('no_quiz') ?? 'No quiz available',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    return _QuizWidget(
      quiz: lesson.quiz!,
      courseColor: widget.course.color,
      onComplete: () {
        _tabController.animateTo(2);
      },
    );
  }

  Widget _buildCodingTab(Lesson lesson) {
    if (lesson.codingChallenge == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.get('no_coding_challenge') ??
                  'No coding challenge',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildContinueButton(
              AppLocalizations.of(context)?.get('complete_lesson') ??
                  'Complete Lesson',
            ),
          ],
        ),
      );
    }

    final challenge = lesson.codingChallenge!;
    if (challenge.language.toLowerCase() == 'git') {
      return GitChallengeWidget(
        challenge: challenge,
        courseColor: widget.course.color,
        onComplete: () => _handleLessonCompletion(lesson),
      );
    }

    return _CodingChallengeWidget(
      challenge: challenge,
      courseColor: widget.course.color,
      onComplete: () => _handleLessonCompletion(lesson),
    );
  }

  Future<void> _handleLessonCompletion(Lesson lesson) async {
    try {
      AppLogger.debug(
        'Completing lesson: course=${widget.course.id}, lesson=${lesson.id}',
      );

      final unlockedAchievements = await ref
          .read(progressActionsProvider)
          .completeLesson(
            courseId: widget.course.id,
            lessonId: lesson.id,
            xpEarned: lesson.xpReward,
          );

      AppLogger.success('Lesson completed: +${lesson.xpReward} XP');

      if (mounted) {
        if (unlockedAchievements.isNotEmpty) {
          _showAchievementNotifications(unlockedAchievements);
        }
        _showCompletionDialog(lesson.xpReward, unlockedAchievements);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error completing lesson', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving progress. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContinueButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_tabController.index < 2) {
            _tabController.animateTo(_tabController.index + 1);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.course.color,
                widget.course.color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(
    int xpReward, [
    List<Achievement> unlockedAchievements = const [],
  ]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.course.color,
                    widget.course.color.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.get('lesson_completed') ??
                  'Lesson Complete!',
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$xpReward XP',
              style: TextStyle(
                color: widget.course.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏆 Achievement unlocked',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...unlockedAchievements.map(
                      (achievement) => Text(
                        '${achievement.title} (+${achievement.xpReward} XP)',
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  context.pop(); // Go back to course detail using GoRouter
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.get('continue') ?? 'Continue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementNotifications(List<Achievement> achievements) {
    final messenger = ScaffoldMessenger.of(context);
    for (final achievement in achievements) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '🏆 ${achievement.title} unlocked (+${achievement.xpReward} XP)',
          ),
          backgroundColor: const Color(0xFF7C3AED),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// Theory Slide Widget
class _TheorySlideWidget extends StatelessWidget {
  final TheorySlide slide;
  final Color courseColor;
  final String courseId;

  const _TheorySlideWidget({
    required this.slide,
    required this.courseColor,
    required this.courseId,
  });

  String _getLanguageFromCourseId() {
    switch (courseId) {
      case 'python':
        return 'python';
      case 'javascript':
        return 'javascript';
      case 'htmlcss':
        return 'html';
      case 'react':
        return 'javascript';
      case 'sql':
        return 'sql';
      case 'git':
        return 'bash';
      default:
        return 'python';
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.title,
            style: TextStyle(
              color: onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          Text(
            slide.content,
            style: TextStyle(color: onSurface, fontSize: 16, height: 1.6),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

          if (slide.codeSnippet != null) ...[
            const SizedBox(height: 24),
            CodeBlock(
              code: slide.codeSnippet!,
              language: slide.codeLanguage ?? _getLanguageFromCourseId(),
              showLineNumbers: slide.codeSnippet!.contains('\n'),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ],
      ),
    );
  }
}

// Quiz Widget
class _QuizWidget extends StatefulWidget {
  final Quiz quiz;
  final Color courseColor;
  final VoidCallback onComplete;

  const _QuizWidget({
    required this.quiz,
    required this.courseColor,
    required this.onComplete,
  });

  @override
  State<_QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<_QuizWidget> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  int _correctAnswers = 0;
  bool _quizCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Show completion screen if quiz is completed
    if (_quizCompleted) {
      return _buildQuizCompletionScreen();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == widget.quiz.questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Text(
            'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
            style: TextStyle(
              color: widget.courseColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Question
          Text(
            question.question,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == question.correctAnswerIndex;
                final showColors = _showResult;

                return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showResult
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswer = index;
                                  });
                                },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: showColors
                                  ? (isCorrect
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : (isSelected
                                              ? Colors.red.withValues(
                                                  alpha: 0.2,
                                                )
                                              : (isDarkTheme
                                                    ? Colors.white.withValues(
                                                        alpha: 0.05,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.92,
                                                      ))))
                                  : (isSelected
                                        ? widget.courseColor.withValues(
                                            alpha: 0.2,
                                          )
                                        : (isDarkTheme
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.92,
                                                ))),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: showColors
                                    ? (isCorrect
                                          ? Colors.green
                                          : (isSelected
                                                ? Colors.red
                                                : (isDarkTheme
                                                      ? Colors.transparent
                                                      : const Color(
                                                          0xFFD6E2FF,
                                                        ))))
                                    : (isSelected
                                          ? widget.courseColor
                                          : (isDarkTheme
                                                ? Colors.transparent
                                                : const Color(0xFFD6E2FF))),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: showColors
                                        ? (isCorrect
                                              ? Colors.green
                                              : (isSelected
                                                    ? Colors.red
                                                    : (isDarkTheme
                                                          ? Colors.white12
                                                          : onSurface
                                                                .withValues(
                                                                  alpha: 0.08,
                                                                ))))
                                        : (isSelected
                                              ? widget.courseColor
                                              : (isDarkTheme
                                                    ? Colors.white12
                                                    : onSurface.withValues(
                                                        alpha: 0.08,
                                                      ))),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        color: isSelected || showColors
                                            ? Colors.white
                                            : onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    question.options[index],
                                    style: TextStyle(
                                      color: onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (showColors && isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                if (showColors && isSelected && !isCorrect)
                                  const Icon(Icons.cancel, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),

          // Check Answer Button
          if (!_showResult && _selectedAnswer != null)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showResult = true;
                    if (_selectedAnswer == question.correctAnswerIndex) {
                      _correctAnswers++;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.courseColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.get('check_answer') ??
                      'Check Answer',
                ),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0),

          // Next/Finish Button
          if (_showResult)
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastQuestion) {
                        // Show completion screen instead of directly calling onComplete
                        setState(() {
                          _quizCompleted = true;
                        });
                      } else {
                        setState(() {
                          _currentQuestionIndex++;
                          _selectedAnswer = null;
                          _showResult = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.courseColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastQuestion
                          ? (AppLocalizations.of(context)?.get('finish_quiz') ??
                                'Finish Quiz')
                          : (AppLocalizations.of(
                                  context,
                                )?.get('next_question') ??
                                'Next Question'),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildQuizCompletionScreen() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final totalQuestions = widget.quiz.questions.length;
    final percentage = (_correctAnswers / totalQuestions * 100).round();
    final isPassed = percentage >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.refresh,
                size: 60,
                color: isPassed ? Colors.green : Colors.orange,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            // Title
            Text(
              isPassed
                  ? (AppLocalizations.of(context)?.get('quiz_completed') ??
                        'Quiz Completed! 🎉')
                  : (AppLocalizations.of(context)?.get('keep_practicing') ??
                        'Keep Practicing!'),
              style: TextStyle(
                color: onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            // Score
            Text(
              '$_correctAnswers/$totalQuestions correct ($percentage%)',
              style: TextStyle(
                color: widget.courseColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 48),

            // Continue Button
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
                  AppLocalizations.of(context)?.get('continue_to_coding') ??
                      'Continue to Coding Challenge',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),

            // Retry Button (if failed)
            if (!isPassed) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _selectedAnswer = null;
                    _showResult = false;
                    _correctAnswers = 0;
                    _quizCompleted = false;
                  });
                },
                child: Text(
                  AppLocalizations.of(context)?.get('try_again') ?? 'Try Again',
                  style: TextStyle(color: widget.courseColor, fontSize: 16),
                ),
              ).animate(delay: 800.ms).fadeIn(),
            ],
          ],
        ),
      ),
    );
  }
}

// Coding Challenge Widget
class _CodingChallengeWidget extends StatefulWidget {
  final CodingChallenge challenge;
  final Color courseColor;
  final VoidCallback onComplete;

  const _CodingChallengeWidget({
    required this.challenge,
    required this.courseColor,
    required this.onComplete,
  });

  @override
  State<_CodingChallengeWidget> createState() => _CodingChallengeWidgetState();
}

class _CodingChallengeWidgetState extends State<_CodingChallengeWidget> {
  late TextEditingController _codeController;
  bool _showHint = false;
  bool _testsPassed = false;
  bool _isRunning = false;
  String _output = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.challenge.starterCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSQLChallenge = widget.challenge.language.toLowerCase() == 'sql';
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

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
          ),
          const SizedBox(height: 12),
          Text(
            widget.challenge.description,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.75),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (isSQLChallenge) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? const Color(0xFF0D1117)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.courseColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample tables',
                    style: TextStyle(
                      color: widget.courseColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    _sqlTablesPreview(),
                    style: TextStyle(
                      color: isDarkTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Code Editor with syntax highlighting and autocomplete
          CodeEditor(
            controller: _codeController,
            language: widget.challenge.language,
            accentColor: widget.courseColor,
          ),
          const SizedBox(height: 16),

          // Hint Button
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
                _showHint ? 'Hide Hint' : 'Show Hint',
                style: TextStyle(color: widget.courseColor),
              ),
            ),

          if (_showHint && widget.challenge.hint != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: widget.courseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.courseColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.challenge.hint!,
                style: TextStyle(color: onSurface.withValues(alpha: 0.75)),
              ),
            ),

          // Run Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                _isRunning
                    ? (AppLocalizations.of(context)?.get('loading') ??
                          'Loading...')
                    : (AppLocalizations.of(context)?.get('run_code') ??
                          'Run Code'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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

          // Console Output
          if (_output.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError
                      ? Colors.red.withValues(alpha: 0.5)
                      : widget.courseColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.terminal,
                        size: 16,
                        color: _hasError ? Colors.red : widget.courseColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Output',
                        style: TextStyle(
                          color: _hasError ? Colors.red : widget.courseColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _output,
                    style: TextStyle(
                      color: _hasError
                          ? Colors.red.shade300
                          : Colors.green.shade300,
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          ],

          if (_testsPassed) ...[
            const SizedBox(height: 24),
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All tests passed! 🎉',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(duration: 300.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(
                  duration: 500.ms,
                  color: Colors.green.withValues(alpha: 0.5),
                ),
            const SizedBox(height: 16),
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
                child: const Text(
                  'Complete Lesson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
          ],
        ],
      ),
    );
  }

  void _runCode() {
    final code = _codeController.text;

    setState(() {
      _isRunning = true;
      _output = '';
      _hasError = false;
      _testsPassed = false;
    });

    // Simulate code execution with delay for UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // Choose interpreter based on challenge language
      final language = widget.challenge.language.toLowerCase();
      final isJavaScript = language == 'javascript' || language == 'js';
      final isHTML =
          language == 'html' || language == 'html/css' || language == 'css';
      final isSQL = language == 'sql';
      final isReact = language == 'react' || language == 'jsx';

      dynamic result;

      if (isJavaScript || isReact) {
        final jsInterpreter = js.JSInterpreter();
        result = jsInterpreter.execute(code);
      } else if (isHTML) {
        final htmlValidator = HTMLValidator();
        result = htmlValidator.execute(code);
      } else if (isSQL) {
        // For SQL, we validate the code matches expected pattern
        result = _validateSQL(code);
      } else {
        // Default to Python
        final pythonInterpreter = py.PythonInterpreter();
        result = pythonInterpreter.execute(code);
      }

      // Check against test cases
      final testCases = widget.challenge.testCases;
      bool passed = false;
      String? expectedHint;

      if (isSQL && result is _SQLResult) {
        setState(() {
          _isRunning = false;
          _output = result.output;
          _hasError = result.hasError;
          _testsPassed = result.passed;
        });
        return;
      }

      if (result.hasError) {
        setState(() {
          _isRunning = false;
          _output = result.error ?? result.output;
          _hasError = true;
          _testsPassed = false;
        });
        return;
      }

      final actualOutput = result.output.trim();

      if (testCases.isNotEmpty) {
        for (final testCase in testCases) {
          final expected = testCase.expectedOutput.trim();

          // Normalize comparison (handle different line endings)
          final normalizedActual = actualOutput
              .replaceAll('\r\n', '\n')
              .toLowerCase();
          final normalizedExpected = expected
              .replaceAll('\r\n', '\n')
              .toLowerCase();

          if (normalizedActual == normalizedExpected) {
            passed = true;
            break;
          }
        }

        if (!passed && testCases.isNotEmpty) {
          expectedHint = testCases.first.expectedOutput;
        }
      } else {
        // No test cases - accept any output
        passed = actualOutput.isNotEmpty;
      }

      String finalOutput = actualOutput;
      if (!passed && expectedHint != null) {
        finalOutput = '$actualOutput\n\n❌ Expected output: "$expectedHint"';
      } else if (passed) {
        finalOutput = '$actualOutput\n\n✅ Test Passed!';
      }

      setState(() {
        _isRunning = false;
        _output = finalOutput;
        _hasError = false;
        _testsPassed = passed;
      });
    });
  }

  // SQL validation - validates SQL syntax and compares with expected output
  dynamic _validateSQL(String code) {
    final testCases = widget.challenge.testCases;
    final sanitizedCode = _stripSQLComments(code).trim();
    final normalizedCode = _normalizeSQL(sanitizedCode);

    // Basic SQL syntax validation
    final validKeywords = [
      'SELECT',
      'INSERT',
      'UPDATE',
      'DELETE',
      'CREATE',
      'DROP',
      'ALTER',
      'FROM',
      'WHERE',
      'JOIN',
      'LEFT',
      'RIGHT',
      'INNER',
      'GROUP',
      'ORDER',
      'HAVING',
      'LIMIT',
      'INDEX',
      'ON',
      'INTO',
      'VALUES',
      'SET',
      'TABLE',
      'AND',
      'OR',
      'NOT',
      'IN',
      'LIKE',
      'BETWEEN',
      'AS',
      'AVG',
      'SUM',
      'COUNT',
      'MAX',
      'MIN',
    ];

    // Check for common SQL typos
    final typos = {
      'SELCT': 'SELECT',
      'SLECT': 'SELECT',
      'FORM': 'FROM',
      'WERE': 'WHERE',
      'WHER': 'WHERE',
      'INSRT': 'INSERT',
      'DELTE': 'DELETE',
      'UPDTE': 'UPDATE',
    };

    for (final typo in typos.entries) {
      final typoRegex = RegExp(r'\b' + RegExp.escape(typo.key) + r'\b');
      if (typoRegex.hasMatch(normalizedCode)) {
        return _SQLResult(
          output:
              '❌ Typo detected: "${typo.key}" should be "${typo.value}"\n\nYour query:\n${sanitizedCode.isEmpty ? code.trim() : sanitizedCode}',
          hasError: true,
          passed: false,
          error:
              '❌ Typo detected: "${typo.key}" should be "${typo.value}"\n\nYour query:\n${sanitizedCode.isEmpty ? code.trim() : sanitizedCode}',
        );
      }
    }

    for (final testCase in testCases) {
      final expectedNormalized = _normalizeSQL(
        _stripSQLComments(testCase.expectedOutput),
      );

      // Check if code matches expected (case-insensitive, whitespace-normalized)
      if (normalizedCode == expectedNormalized) {
        final resultPreview = _sqlResultPreviewForExpected(
          expectedNormalized: expectedNormalized,
          testCase: testCase,
        );
        return _SQLResult(
          output:
              '✅ Query is correct!\n\nQuery:\n$sanitizedCode\n\nResult:\n$resultPreview',
          hasError: false,
          passed: true,
        );
      }

      // Also check if it contains key parts (more flexible matching)
      final expectedParts = expectedNormalized
          .split(' ')
          .where((p) => validKeywords.contains(p) || p.contains('('));
      final codeParts = normalizedCode
          .split(' ')
          .where((p) => validKeywords.contains(p) || p.contains('('));

      if (expectedParts.length == codeParts.length &&
          expectedParts.every((p) => normalizedCode.contains(p))) {
        final resultPreview = _sqlResultPreviewForExpected(
          expectedNormalized: expectedNormalized,
          testCase: testCase,
        );
        return _SQLResult(
          output:
              '✅ Query is correct!\n\nQuery:\n$sanitizedCode\n\nResult:\n$resultPreview',
          hasError: false,
          passed: true,
        );
      }
    }

    // If no match, provide helpful feedback
    if (testCases.isNotEmpty) {
      final expected = testCases.first.expectedOutput;
      return _SQLResult(
        output:
            '${sanitizedCode.isEmpty ? code.trim() : sanitizedCode}\n\n💡 Hint: Expected structure:\n$expected',
        hasError: false,
        passed: false,
      );
    }

    return _SQLResult(
      output: sanitizedCode.isEmpty ? code.trim() : sanitizedCode,
      hasError: false,
      passed: true,
    );
  }

  String _stripSQLComments(String sql) {
    final withoutBlockComments = sql.replaceAll(
      RegExp(r'/\*[\s\S]*?\*/', multiLine: true),
      ' ',
    );

    return withoutBlockComments
        .split('\n')
        .map((line) {
          final inlineCommentIndex = line.indexOf('--');
          if (inlineCommentIndex == -1) return line;
          return line.substring(0, inlineCommentIndex);
        })
        .join('\n');
  }

  String _normalizeSQL(String sql) {
    return sql.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _sqlTablesPreview() {
    return '''products
id | name        | category     | price
1  | Keyboard    | Electronics  | 49.99
2  | Mouse       | Electronics  | 29.99
3  | Notebook    | Office       | 9.99
4  | Headphones  | Electronics  | 79.99
5  | Coffee Mug  | Home         | 12.50
6  | Monitor     | Electronics  | 199.99

users
id | name   | email                | role
1  | John   | john@gmail.com       | user
2  | Julia  | julia@gmail.com      | user
3  | Alice  | alice@yahoo.com      | admin
4  | Mark   | mark@outlook.com     | user

orders
id | user_id | amount
1  | 1       | 120.00
2  | 1       | 75.50
3  | 3       | 250.00''';
  }

  String _sqlResultPreviewForExpected({
    required String expectedNormalized,
    required TestCase testCase,
  }) {
    final providedPreview = testCase.input.trim();
    if (providedPreview.isNotEmpty) {
      return providedPreview;
    }

    if (expectedNormalized.startsWith('SELECT * FROM PRODUCTS')) {
      return '''id | name        | category     | price
1  | Keyboard    | Electronics  | 49.99
2  | Mouse       | Electronics  | 29.99
3  | Notebook    | Office       | 9.99
4  | Headphones  | Electronics  | 79.99
5  | Coffee Mug  | Home         | 12.50
6  | Monitor     | Electronics  | 199.99''';
    }

    if (expectedNormalized.contains(
      'SELECT NAME, PRICE FROM PRODUCTS WHERE PRICE <= 50',
    )) {
      return '''name       | price
Keyboard   | 49.99
Mouse      | 29.99
Notebook   | 9.99
Coffee Mug | 12.50''';
    }

    if (expectedNormalized.contains(
      "SELECT * FROM USERS WHERE NAME LIKE 'J%' AND EMAIL LIKE '%GMAIL%'",
    )) {
      return '''id | name  | email            | role
1  | John  | john@gmail.com  | user
2  | Julia | julia@gmail.com | user''';
    }

    if (expectedNormalized.contains(
      'SELECT NAME, PRICE FROM PRODUCTS ORDER BY PRICE DESC LIMIT 5',
    )) {
      return '''name        | price
Monitor     | 199.99
Headphones  | 79.99
Keyboard    | 49.99
Mouse       | 29.99
Coffee Mug  | 12.50''';
    }

    if (expectedNormalized.contains(
      'SELECT COUNT(*) AS TOTAL_ORDERS, SUM(AMOUNT) AS TOTAL_AMOUNT, AVG(AMOUNT) AS AVG_AMOUNT FROM ORDERS',
    )) {
      return '''total_orders | total_amount | avg_amount
3            | 445.50       | 148.50''';
    }

    if (expectedNormalized.contains(
      'SELECT CATEGORY, COUNT(*) AS PRODUCT_COUNT FROM PRODUCTS GROUP BY CATEGORY HAVING COUNT(*) > 5 ORDER BY PRODUCT_COUNT DESC',
    )) {
      return '''category     | product_count
Electronics | 7''';
    }

    if (expectedNormalized.contains(
      'SELECT O.ID, U.NAME, O.AMOUNT FROM ORDERS O INNER JOIN USERS U ON O.USER_ID = U.ID',
    )) {
      return '''id | name  | amount
1  | John  | 120.00
2  | John  | 75.50
3  | Alice | 250.00''';
    }

    if (expectedNormalized.contains(
      'SELECT U.NAME, U.EMAIL FROM USERS U LEFT JOIN ORDERS O ON U.ID = O.USER_ID WHERE O.ID IS NULL',
    )) {
      return '''name  | email
Julia | julia@gmail.com
Mark  | mark@outlook.com''';
    }

    if (expectedNormalized.startsWith('INSERT INTO PRODUCTS')) {
      return '1 row inserted.';
    }

    if (expectedNormalized.startsWith('CREATE TABLE CUSTOMERS')) {
      return 'Table "customers" created.';
    }

    return 'Query validated successfully.';
  }
}

class _SQLResult {
  final String output;
  final bool hasError;
  final bool passed;
  final String? error;

  _SQLResult({
    required this.output,
    required this.hasError,
    required this.passed,
    this.error,
  });
}
