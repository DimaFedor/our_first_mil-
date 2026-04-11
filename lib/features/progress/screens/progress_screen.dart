import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/course_content_service.dart';
import '../../../core/services/course_localization_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/models/course_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/services/xp_system.dart';
import '../../../shared/widgets/main_navigation.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  String _t(BuildContext context, String key, String fallback) {
    return AppLocalizations.of(context)?.get(key) ?? fallback;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final userId = ref.watch(currentUserUidProvider);

    final userDataAsync = userId == null
        ? const AsyncValue<UserModel?>.data(null)
        : ref.watch(userDataProvider(userId));
    final progressAsync = ref.watch(allUserProgressProvider);
    final levelInfoAsync = ref.watch(levelInfoProvider);
    final coursesAsync = ref.watch(localizedCoursesProvider);

    final userData = userDataAsync.valueOrNull;
    final progressList = progressAsync.valueOrNull ?? const <CourseProgress>[];
    final courses = coursesAsync.valueOrNull ?? const <Course>[];
    final totalXP = userData?.totalXP ?? 0;
    final levelInfo =
        levelInfoAsync.valueOrNull ?? XPSystem.getLevelInfo(totalXP);
    final snapshots = _buildCourseSnapshots(courses, progressList);

    final completedLessons = snapshots.fold<int>(
      0,
      (sum, snapshot) => sum + snapshot.completedLessons,
    );
    final totalLessons = snapshots.fold<int>(
      0,
      (sum, snapshot) => sum + snapshot.totalLessons,
    );
    final activeCourses = snapshots
        .where((snapshot) => snapshot.isInProgress)
        .length;
    final finishedCourses = snapshots
        .where((snapshot) => snapshot.isCompleted)
        .length;
    final completionRate = totalLessons == 0
        ? 0.0
        : completedLessons / totalLessons;
    final recommendedCourse = _pickRecommendedSnapshot(snapshots);
    final isInitialLoading = coursesAsync.isLoading && snapshots.isEmpty;

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
          child: RefreshIndicator(
            color: const Color(0xFF0066FF),
            backgroundColor: Theme.of(context).colorScheme.surface,
            onRefresh: () => _refreshProgress(ref, userId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Text(
                      _t(context, 'your_progress', 'Your Progress'),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.12, end: 0),
                const SizedBox(height: 8),
                Text(
                  _t(context, 'keep_up_work', 'Keep up the great work!'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onSurface.withValues(alpha: 0.68),
                  ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 20),

                if (isInitialLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (snapshots.isEmpty)
                  _EmptyProgressCard(
                    title: _t(context, 'no_progress_title', 'No progress yet'),
                    subtitle: _t(
                      context,
                      'no_progress_subtitle',
                      'Start a course to unlock your personalized learning insights.',
                    ),
                    buttonLabel: _t(
                      context,
                      'browse_courses',
                      'Browse Courses',
                    ),
                    onBrowse: () =>
                        ref.read(currentTabProvider.notifier).state = 1,
                  )
                else ...[
                  _ProgressHeroCard(
                    levelInfo: levelInfo,
                    totalXP: totalXP,
                    streakDays: userData?.currentStreak ?? 0,
                    daysLabel: _t(context, 'days', 'days'),
                    levelLabel: _t(context, 'level', 'Level'),
                    xpToNextLevelLabel: _t(
                      context,
                      'xp_to_next_level',
                      'XP to next level',
                    ),
                    completedLabel: _t(context, 'completed', 'Completed'),
                  ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    _t(context, 'progress_snapshot', 'Progress Snapshot'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ).animate(delay: 180.ms).fadeIn(),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MetricCard(
                        icon: Icons.emoji_events_outlined,
                        label: _t(context, 'total_xp', 'Total XP'),
                        value: '$totalXP',
                        valueColor: const Color(0xFFF59E0B),
                      ),
                      _MetricCard(
                        icon: Icons.school_outlined,
                        label: _t(
                          context,
                          'lessons_completed',
                          'Lessons Completed',
                        ),
                        value: '$completedLessons/$totalLessons',
                        valueColor: const Color(0xFF10B981),
                      ),
                      _MetricCard(
                        icon: Icons.auto_graph_rounded,
                        label: _t(
                          context,
                          'completion_rate',
                          'Completion Rate',
                        ),
                        value: '${(completionRate * 100).toInt()}%',
                        valueColor: const Color(0xFF2563EB),
                      ),
                      _MetricCard(
                        icon: Icons.rocket_launch_outlined,
                        label: _t(context, 'active_courses', 'Active Courses'),
                        value:
                            '$activeCourses · ${_t(context, 'finished_courses', 'Finished Courses')}: $finishedCourses',
                        valueColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 18),
                  _RecommendationCard(
                    title: _t(
                      context,
                      'recommended_next_step',
                      'Recommended Next Step',
                    ),
                    noRecommendationLabel: _t(
                      context,
                      'browse_courses',
                      'Browse Courses',
                    ),
                    lessonsLeftLabel: _t(
                      context,
                      'lessons_left',
                      'Lessons left',
                    ),
                    continueLabel: _t(
                      context,
                      'continue_learning',
                      'Continue Learning',
                    ),
                    recommendation: recommendedCourse,
                    onBrowse: () =>
                        ref.read(currentTabProvider.notifier).state = 1,
                    onContinue: (course) =>
                        context.push('/course/${course.id}', extra: course),
                  ).animate(delay: 260.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),
                  Text(
                    _t(context, 'course_progress', 'Course Progress'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ).animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 10),
                  for (final snapshot in snapshots)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CourseProgressCard(
                        snapshot: snapshot,
                        statusLabel: _t(
                          context,
                          snapshot.statusKey,
                          snapshot.statusFallback,
                        ),
                        lessonsLabel: _t(context, 'lessons', 'Lessons'),
                        continueLabel: _t(context, 'continue', 'Continue'),
                        onContinue: snapshot.isCompleted
                            ? null
                            : () => context.push(
                                '/course/${snapshot.course.id}',
                                extra: snapshot.course,
                              ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProgress(WidgetRef ref, String? userId) async {
    ref.invalidate(allUserProgressProvider);
    ref.invalidate(levelInfoProvider);
    ref.invalidate(localizedCoursesProvider);
    ref.invalidate(userXPProvider);
    if (userId != null) {
      ref.invalidate(userDataProvider(userId));
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  List<_CourseProgressSnapshot> _buildCourseSnapshots(
    List<Course> courses,
    List<CourseProgress> progressList,
  ) {
    final snapshots = courses
        .map((course) {
          final progress = _findProgress(course, progressList);
          final fallbackTotal = CourseContentService.getLessonsForCourse(
            course.id,
          ).length;
          final totalLessons = course.totalLessons > 0
              ? course.totalLessons
              : fallbackTotal;
          final completedRaw = progress?.completedLessons.length ?? 0;
          final completedLessons = totalLessons > 0
              ? completedRaw.clamp(0, totalLessons)
              : completedRaw;

          final isCompleted =
              totalLessons > 0 && completedLessons >= totalLessons;
          final isInProgress = completedLessons > 0 && !isCompleted;
          final completionRatio = totalLessons == 0
              ? 0.0
              : completedLessons / totalLessons;

          return _CourseProgressSnapshot(
            course: course,
            completedLessons: completedLessons,
            totalLessons: totalLessons,
            completionRatio: completionRatio,
            isInProgress: isInProgress,
            isCompleted: isCompleted,
          );
        })
        .toList(growable: false);

    snapshots.sort((a, b) {
      int priority(_CourseProgressSnapshot item) {
        if (item.isInProgress) return 0;
        if (!item.isCompleted && item.completedLessons == 0) return 1;
        return 2;
      }

      final pCompare = priority(a).compareTo(priority(b));
      if (pCompare != 0) return pCompare;

      final progressCompare = b.completionRatio.compareTo(a.completionRatio);
      if (progressCompare != 0) return progressCompare;

      return a.course.order.compareTo(b.course.order);
    });

    return snapshots;
  }

  _CourseProgressSnapshot? _pickRecommendedSnapshot(
    List<_CourseProgressSnapshot> snapshots,
  ) {
    for (final snapshot in snapshots) {
      if (snapshot.isInProgress) return snapshot;
    }
    for (final snapshot in snapshots) {
      if (!snapshot.isCompleted) return snapshot;
    }
    return snapshots.isEmpty ? null : snapshots.first;
  }

  CourseProgress? _findProgress(
    Course course,
    List<CourseProgress> progressList,
  ) {
    for (final progress in progressList) {
      if (_courseMatchesProgress(course.id, progress.courseId)) {
        return progress;
      }
    }
    return null;
  }

  bool _courseMatchesProgress(String courseId, String progressCourseId) {
    final normalizedCourseId = _normalizeCourseKey(courseId);
    final normalizedProgressId = _normalizeCourseKey(progressCourseId);
    return normalizedProgressId.contains(normalizedCourseId) ||
        normalizedCourseId.contains(normalizedProgressId);
  }

  String _normalizeCourseKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

class _ProgressHeroCard extends StatelessWidget {
  final LevelInfo levelInfo;
  final int totalXP;
  final int streakDays;
  final String daysLabel;
  final String levelLabel;
  final String xpToNextLevelLabel;
  final String completedLabel;

  const _ProgressHeroCard({
    required this.levelInfo,
    required this.totalXP,
    required this.streakDays,
    required this.daysLabel,
    required this.levelLabel,
    required this.xpToNextLevelLabel,
    required this.completedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [
                  const Color(0xFF0066FF).withValues(alpha: 0.35),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                ]
              : [
                  const Color(0xFF0066FF).withValues(alpha: 0.16),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFBFD1FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Center(
                  child: Text(
                    levelInfo.badge,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$levelLabel ${levelInfo.level}',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      levelInfo.title,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.72),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B00),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streakDays $daysLabel',
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalXP XP',
            style: TextStyle(
              color: onSurface,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: levelInfo.progress,
              minHeight: 10,
              backgroundColor: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFD6E2FF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0066FF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            levelInfo.isMaxLevel
                ? completedLabel
                : '$xpToNextLevelLabel: ${levelInfo.xpNeededForNextLevel}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: onSurface.withValues(alpha: 0.65)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final String noRecommendationLabel;
  final String lessonsLeftLabel;
  final String continueLabel;
  final _CourseProgressSnapshot? recommendation;
  final VoidCallback onBrowse;
  final ValueChanged<Course> onContinue;

  const _RecommendationCard({
    required this.title,
    required this.noRecommendationLabel,
    required this.lessonsLeftLabel,
    required this.continueLabel,
    required this.recommendation,
    required this.onBrowse,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [
                  const Color(0xFF1E293B).withValues(alpha: 0.9),
                  const Color(0xFF312E81).withValues(alpha: 0.8),
                ]
              : [const Color(0xFFEFF3FF), const Color(0xFFE8EBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFCCD8FF),
        ),
      ),
      child: recommendation == null
          ? Row(
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: onSurface.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onBrowse,
                  child: Text(noRecommendationLabel),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      recommendation!.course.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation!.course.title,
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$lessonsLeftLabel: ${recommendation!.lessonsLeft}',
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.68),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => onContinue(recommendation!.course),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(continueLabel),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  final _CourseProgressSnapshot snapshot;
  final String statusLabel;
  final String lessonsLabel;
  final String continueLabel;
  final VoidCallback? onContinue;

  const _CourseProgressCard({
    required this.snapshot,
    required this.statusLabel,
    required this.lessonsLabel,
    required this.continueLabel,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final statusColor = snapshot.isCompleted
        ? const Color(0xFF10B981)
        : snapshot.isInProgress
        ? const Color(0xFF2563EB)
        : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(snapshot.course.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  snapshot.course.title,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: snapshot.completionRatio,
              minHeight: 8,
              backgroundColor: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFD6E2FF),
              valueColor: AlwaysStoppedAnimation<Color>(snapshot.course.color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${snapshot.completedLessons}/${snapshot.totalLessons} $lessonsLabel',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(snapshot.completionRatio * 100).toInt()}%',
                style: TextStyle(
                  color: snapshot.course.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (onContinue != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: Text(continueLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onBrowse;

  const _EmptyProgressCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            size: 40,
            color: Color(0xFF0066FF),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.explore_rounded),
            label: Text(buttonLabel),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _CourseProgressSnapshot {
  final Course course;
  final int completedLessons;
  final int totalLessons;
  final double completionRatio;
  final bool isInProgress;
  final bool isCompleted;

  const _CourseProgressSnapshot({
    required this.course,
    required this.completedLessons,
    required this.totalLessons,
    required this.completionRatio,
    required this.isInProgress,
    required this.isCompleted,
  });

  int get lessonsLeft =>
      (totalLessons - completedLessons).clamp(0, totalLessons);

  String get statusKey {
    if (isCompleted) return 'completed';
    if (isInProgress) return 'in_progress';
    return 'not_started';
  }

  String get statusFallback {
    if (isCompleted) return 'Completed';
    if (isInProgress) return 'In Progress';
    return 'Not Started';
  }
}
