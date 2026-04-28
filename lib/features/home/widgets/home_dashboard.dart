import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/course_content_service.dart';
import '../../../core/services/course_localization_service.dart';
import '../../../features/achievements/models/achievement_model.dart';
import '../../../features/achievements/providers/achievement_provider.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/lessons/models/lesson_model.dart';
import '../../../features/progress/providers/progress_provider.dart';
import '../../../features/progress/services/xp_system.dart';
import '../../../shared/widgets/main_navigation.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final userId = ref.watch(currentUserUidProvider);
    final userName = ref.watch(currentUserNameProvider);
    final userDataAsync = userId == null
        ? const AsyncValue<UserModel?>.data(null)
        : ref.watch(userDataProvider(userId));
    final progressAsync = ref.watch(allUserProgressProvider);
    final levelInfoAsync = ref.watch(levelInfoProvider);
    final coursesAsync = ref.watch(localizedCoursesProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    final userData = userDataAsync.valueOrNull;
    final progressList = progressAsync.valueOrNull ?? const <CourseProgress>[];
    final courses = coursesAsync.valueOrNull ?? const <Course>[];
    final achievements =
        achievementsAsync.valueOrNull ?? const <UserAchievement>[];
    final totalLessons = _countCompletedLessons(progressList);
    final totalXP = userData?.totalXP ?? 0;
    final currentStreak = userData?.currentStreak ?? 0;
    final levelInfo =
        levelInfoAsync.valueOrNull ?? XPSystem.getLevelInfo(totalXP);

    final courseSnapshots = _buildCourseSnapshots(courses, progressList);
    final recommendation = _pickRecommendation(courseSnapshots);
    final recentWins = _recentAchievements(achievements);

    return Scaffold(
      body: Stack(
        children: [
          _HomeBackground(isDarkTheme: isDarkTheme),
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF0066FF),
              backgroundColor: colorScheme.surface,
              onRefresh: () => _refreshHome(ref, userId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _HomeHeader(
                    appName:
                        AppLocalizations.of(context)?.get('app_name') ??
                        'CodeLearn',
                    subtitle:
                        AppLocalizations.of(context)?.get('keep_up_work') ??
                        'Keep up the great work!',
                    onProfileTap: () =>
                        ref.read(currentTabProvider.notifier).state = 3,
                  ),
                  const SizedBox(height: 18),
                  _HeroStatusCard(
                        userName: userId == null ? null : userName,
                        skillLevel: userData?.skillLevel,
                        preferredLanguage: userData?.preferredLanguage,
                        levelInfo: levelInfo,
                        totalXP: totalXP,
                        currentStreak: currentStreak,
                        totalLessons: totalLessons,
                        recommendation: recommendation,
                        onContinueTap: () {
                          if (recommendation != null) {
                            _openRecommendation(context, recommendation);
                          } else {
                            ref.read(currentTabProvider.notifier).state = 1;
                          }
                        },
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 16),
                  _QuickActionsGrid(
                    onCoursesTap: () =>
                        ref.read(currentTabProvider.notifier).state = 1,
                    onProgressTap: () =>
                        ref.read(currentTabProvider.notifier).state = 2,
                    onAchievementsTap: () => context.push('/achievements'),
                    onRewardsTap: () => context.push('/xp-rewards'),
                    onProfileTap: () =>
                        ref.read(currentTabProvider.notifier).state = 3,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title:
                        AppLocalizations.of(context)?.get('your_courses') ??
                        'Your courses',
                    actionLabel:
                        AppLocalizations.of(
                          context,
                        )?.get('browse_all_courses') ??
                        'Browse all courses',
                    onActionTap: () =>
                        ref.read(currentTabProvider.notifier).state = 1,
                  ),
                  const SizedBox(height: 12),
                  _CourseRail(
                    snapshots: courseSnapshots,
                    onCourseTap: (course) =>
                        context.push('/course/${course.id}', extra: course),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title:
                        AppLocalizations.of(context)?.get('achievements') ??
                        'Achievements',
                    actionLabel:
                        AppLocalizations.of(
                          context,
                        )?.get('view_all_achievements') ??
                        'View all achievements',
                    onActionTap: () => context.push('/achievements'),
                  ),
                  const SizedBox(height: 12),
                  _AchievementsStrip(
                    unlockedAchievements: recentWins,
                    onViewAllTap: () => context.push('/achievements'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHome(WidgetRef ref, String? userId) async {
    ref.invalidate(allUserProgressProvider);
    ref.invalidate(levelInfoProvider);
    ref.invalidate(localizedCoursesProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(userXPProvider);

    if (userId != null) {
      ref.invalidate(userDataProvider(userId));
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  int _countCompletedLessons(List<CourseProgress> progressList) {
    return progressList.fold<int>(
      0,
      (sum, progress) => sum + progress.completedLessons.length,
    );
  }

  List<_HomeCourseSnapshot> _buildCourseSnapshots(
    List<Course> courses,
    List<CourseProgress> progressList,
  ) {
    final snapshots = courses
        .map((course) {
          final progress = _findProgress(course, progressList);
          final lessons = CourseContentService.getLessonsForCourse(course.id);
          final nextLesson = _nextIncompleteLesson(lessons, progress);

          return _HomeCourseSnapshot(
            course: course,
            progress: progress,
            lessons: lessons,
            nextLesson: nextLesson,
          );
        })
        .toList(growable: false);

    snapshots.sort((a, b) {
      final aScore = _priorityScore(a);
      final bScore = _priorityScore(b);
      if (aScore != bScore) {
        return aScore.compareTo(bScore);
      }

      if (a.completionRatio != b.completionRatio) {
        return b.completionRatio.compareTo(a.completionRatio);
      }

      return a.course.order.compareTo(b.course.order);
    });

    return snapshots;
  }

  int _priorityScore(_HomeCourseSnapshot snapshot) {
    if (snapshot.hasStarted && !snapshot.isCompleted) return 0;
    if (snapshot.isCompleted) return 1;
    return 2;
  }

  _HomeCourseSnapshot? _pickRecommendation(
    List<_HomeCourseSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) return null;
    return snapshots.first;
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

  Lesson? _nextIncompleteLesson(
    List<Lesson> lessons,
    CourseProgress? progress,
  ) {
    if (lessons.isEmpty) return null;

    final completedLessons = progress?.completedLessons.toSet() ?? <String>{};
    for (final lesson in lessons) {
      if (!completedLessons.contains(lesson.id)) {
        return lesson;
      }
    }

    return null;
  }

  List<Achievement> _recentAchievements(List<UserAchievement> unlocked) {
    final achievementsById = {
      for (final achievement in Achievement.getAllAchievements())
        achievement.id: achievement,
    };

    final sorted = [...unlocked]
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

    return sorted
        .map((item) => achievementsById[item.achievementId])
        .whereType<Achievement>()
        .take(4)
        .toList(growable: false);
  }

  void _openRecommendation(
    BuildContext context,
    _HomeCourseSnapshot recommendation,
  ) {
    if (recommendation.nextLesson == null) {
      context.push(
        '/course/${recommendation.course.id}',
        extra: recommendation.course,
      );
      return;
    }

    context.push(
      '/course/${recommendation.course.id}/lesson/${recommendation.nextLesson!.id}',
      extra: {
        'course': recommendation.course,
        'lesson': recommendation.nextLesson!,
      },
    );
  }
}

class _HomeBackground extends StatelessWidget {
  final bool isDarkTheme;

  const _HomeBackground({required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme
                ? const [
                    Color(0xFF081024),
                    Color(0xFF111A38),
                    Color(0xFF0A1530),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFEFF4FF),
                    Color(0xFFE7EEFF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: _GlowOrb(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                size: 220,
              ),
            ),
            Positioned(
              top: 180,
              left: -90,
              child: _GlowOrb(
                color: const Color(0xFF0066FF).withValues(alpha: 0.12),
                size: 200,
              ),
            ),
            Positioned(
              bottom: -90,
              right: -40,
              child: _GlowOrb(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                size: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.02)],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String appName;
  final String subtitle;
  final VoidCallback onProfileTap;

  const _HomeHeader({
    required this.appName,
    required this.subtitle,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFD6E2FF),
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: isDarkTheme
                  ? Colors.white70
                  : onSurface.withValues(alpha: 0.78),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  final String? userName;
  final String? skillLevel;
  final String? preferredLanguage;
  final LevelInfo levelInfo;
  final int totalXP;
  final int currentStreak;
  final int totalLessons;
  final _HomeCourseSnapshot? recommendation;
  final VoidCallback onContinueTap;

  const _HeroStatusCard({
    required this.userName,
    required this.skillLevel,
    required this.preferredLanguage,
    required this.levelInfo,
    required this.totalXP,
    required this.currentStreak,
    required this.totalLessons,
    required this.recommendation,
    required this.onContinueTap,
  });

  String? _formatLanguageFocus(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    switch (languageCode.trim().toLowerCase()) {
      case 'python':
        return 'Python';
      case 'javascript':
        return 'JavaScript';
      case 'cplusplus':
      case 'cpp':
      case 'c++':
        return 'C++';
      case 'sql':
        return 'SQL';
      case 'dart':
        return 'Dart';
      default:
        return languageCode.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final hasUser = userName != null && userName!.isNotEmpty;
    final greeting = hasUser
        ? '${_greetingForHour(DateTime.now().hour, context)}, $userName'
        : (AppLocalizations.of(context)?.get('start_journey') ??
              'Start your journey');
    final learningFocus = _formatLanguageFocus(preferredLanguage);
    final skillLabel = (skillLevel != null && skillLevel!.isNotEmpty)
        ? '${skillLevel![0].toUpperCase()}${skillLevel!.substring(1)}'
        : null;
    final subtitle = totalLessons > 0
        ? (AppLocalizations.of(context)?.get('keep_up_work') ??
              'Keep up the great work!')
        : 'Your first lesson is ready when you are.';
    String personalizedSubtitle = subtitle;
    if (learningFocus != null) {
      personalizedSubtitle = '$personalizedSubtitle · Focus: $learningFocus';
    }
    if (skillLabel != null) {
      personalizedSubtitle = '$personalizedSubtitle · $skillLabel';
    }
    final primaryLabel = totalLessons > 0
        ? (AppLocalizations.of(context)?.get('continue_learning') ??
              'Continue learning')
        : (AppLocalizations.of(context)?.get('start_course') ?? 'Start course');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? const [Color(0xFF121C42), Color(0xFF0B1230), Color(0xFF121A3C)]
              : const [Color(0xFFFFFFFF), Color(0xFFF4F8FF), Color(0xFFEAF1FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E2FF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkTheme ? 0.18 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -18,
            child: _GlowOrb(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              size: 130,
            ),
          ),
          Positioned(
            bottom: -42,
            left: -28,
            child: _GlowOrb(
              color: const Color(0xFF0066FF).withValues(alpha: 0.08),
              size: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          personalizedSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface.withValues(alpha: 0.72),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${AppLocalizations.of(context)?.get('level') ?? 'Level'} ${levelInfo.level} • ${levelInfo.title}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: onSurface.withValues(alpha: 0.86),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          levelInfo.isMaxLevel
                              ? 'Max level reached'
                              : '${levelInfo.xpNeededForNextLevel} XP to Level ${levelInfo.level + 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _LevelOrb(levelInfo: levelInfo),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(
                    icon: Icons.flash_on_rounded,
                    value: '$totalXP',
                    label:
                        AppLocalizations.of(context)?.get('total_xp') ??
                        'Total XP',
                    accent: const Color(0xFFF59E0B),
                    isDarkTheme: isDarkTheme,
                  ),
                  _MetricChip(
                    icon: Icons.local_fire_department_rounded,
                    value: currentStreak > 0 ? '$currentStreak' : '0',
                    label:
                        '${AppLocalizations.of(context)?.get('current_streak') ?? 'Streak'} ${AppLocalizations.of(context)?.get('days') ?? 'days'}',
                    accent: const Color(0xFFFB7185),
                    isDarkTheme: isDarkTheme,
                  ),
                  _MetricChip(
                    icon: Icons.menu_book_rounded,
                    value: '$totalLessons',
                    label:
                        AppLocalizations.of(context)?.get('lessons') ??
                        'Lessons',
                    accent: const Color(0xFF38BDF8),
                    isDarkTheme: isDarkTheme,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: levelInfo.progress,
                  minHeight: 8,
                  backgroundColor: isDarkTheme
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFD9E5FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0066FF),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(levelInfo.progress * 100).round()}% ${AppLocalizations.of(context)?.get('progress_to_next_level') ?? 'to the next level'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 16),
              if (recommendation != null)
                _NextStepCard(
                  recommendation: recommendation!,
                  buttonLabel: primaryLabel,
                  onTap: onContinueTap,
                  isDarkTheme: isDarkTheme,
                )
              else
                _EmptyContinueCard(
                  label: primaryLabel,
                  onTap: onContinueTap,
                  isDarkTheme: isDarkTheme,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelOrb extends StatelessWidget {
  final LevelInfo levelInfo;

  const _LevelOrb({required this.levelInfo});

  @override
  Widget build(BuildContext context) {
    final progress = levelInfo.isMaxLevel ? 1.0 : levelInfo.progress;
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(levelInfo.badge, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 2),
                Text(
                  levelInfo.isMaxLevel ? 'MAX' : 'Lv ${levelInfo.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool isDarkTheme;

  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: isDarkTheme ? 0.22 : 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.62),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final _HomeCourseSnapshot recommendation;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool isDarkTheme;

  const _NextStepCard({
    required this.recommendation,
    required this.buttonLabel,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final course = recommendation.course;
    final nextLesson = recommendation.nextLesson;
    final progressText = recommendation.isCompleted
        ? 'Course complete'
        : '${recommendation.completedLessons}/${recommendation.totalLessons} lessons';
    final secondaryText = nextLesson != null
        ? '${nextLesson.title} • +${nextLesson.xpReward} XP'
        : 'Review the course and keep your momentum going';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                course.color.withValues(alpha: isDarkTheme ? 0.18 : 0.14),
                course.color.withValues(alpha: isDarkTheme ? 0.08 : 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: course.color.withValues(alpha: isDarkTheme ? 0.28 : 0.34),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: course.color.withValues(alpha: 0.18),
                ),
                child: Center(
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.get('continue_learning') ??
                          'Continue learning',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: course.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      secondaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.68),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progressText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward_rounded, color: course.color),
                  const SizedBox(height: 12),
                  _HeroActionPill(label: buttonLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyContinueCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDarkTheme;

  const _EmptyContinueCard({
    required this.label,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDarkTheme ? 0.08 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0066FF).withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.get('start_journey') ??
                          'Start your journey',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open your first course and build momentum from day one.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _HeroActionPill(label: label),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionPill extends StatelessWidget {
  final String label;

  const _HeroActionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108, maxWidth: 156),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onCoursesTap;
  final VoidCallback onProgressTap;
  final VoidCallback onAchievementsTap;
  final VoidCallback onRewardsTap;
  final VoidCallback onProfileTap;

  const _QuickActionsGrid({
    required this.onCoursesTap,
    required this.onProgressTap,
    required this.onAchievementsTap,
    required this.onRewardsTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final actions = [
      _QuickAction(
        label: AppLocalizations.of(context)?.get('courses') ?? 'Courses',
        icon: Icons.school_rounded,
        accent: const Color(0xFF38BDF8),
        onTap: onCoursesTap,
      ),
      _QuickAction(
        label: AppLocalizations.of(context)?.get('progress') ?? 'Progress',
        icon: Icons.trending_up_rounded,
        accent: const Color(0xFF34D399),
        onTap: onProgressTap,
      ),
      _QuickAction(
        label:
            AppLocalizations.of(context)?.get('achievements') ?? 'Achievements',
        icon: Icons.emoji_events_rounded,
        accent: const Color(0xFFF59E0B),
        onTap: onAchievementsTap,
      ),
      _QuickAction(
        label: Localizations.localeOf(context).languageCode == 'uk'
            ? 'EXP Бонуси'
            : 'EXP Rewards',
        icon: Icons.workspace_premium_rounded,
        accent: const Color(0xFF22C55E),
        onTap: onRewardsTap,
      ),
      _QuickAction(
        label: AppLocalizations.of(context)?.get('profile') ?? 'Profile',
        icon: Icons.person_rounded,
        accent: const Color(0xFF8B5CF6),
        onTap: onProfileTap,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions
              .asMap()
              .entries
              .map(
                (entry) => SizedBox(
                  width: width,
                  child:
                      _QuickActionCard(
                            action: entry.value,
                            isDarkTheme: isDarkTheme,
                            onSurface: onSurface,
                          )
                          .animate(
                            delay: Duration(milliseconds: 50 * entry.key),
                          )
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.12, end: 0),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final bool isDarkTheme;
  final Color onSurface;

  const _QuickActionCard({
    required this.action,
    required this.isDarkTheme,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: action.accent.withValues(alpha: isDarkTheme ? 0.2 : 0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDarkTheme ? 0.08 : 0.04,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: action.accent.withValues(alpha: 0.16),
                ),
                child: Icon(action.icon, color: action.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: Color(0xFF0066FF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseRail extends StatelessWidget {
  final List<_HomeCourseSnapshot> snapshots;
  final ValueChanged<Course> onCourseTap;

  const _CourseRail({required this.snapshots, required this.onCourseTap});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final visibleSnapshots = snapshots.take(6).toList(growable: false);

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: visibleSnapshots.length,
        separatorBuilder: (context, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final snapshot = visibleSnapshots[index];
          return SizedBox(
            width: 248,
            child:
                _CourseMomentumCard(
                      snapshot: snapshot,
                      onTap: () => onCourseTap(snapshot.course),
                    )
                    .animate(delay: Duration(milliseconds: 70 * index))
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.14, end: 0),
          );
        },
      ),
    );
  }
}

class _CourseMomentumCard extends StatelessWidget {
  final _HomeCourseSnapshot snapshot;
  final VoidCallback onTap;

  const _CourseMomentumCard({required this.snapshot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final course = snapshot.course;
    final progress = snapshot.completionRatio;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                course.color.withValues(alpha: 0.18),
                course.color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: course.color.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: course.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        course.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _TinyBadge(
                    text: snapshot.isCompleted
                        ? 'Done'
                        : snapshot.hasStarted
                        ? 'Resume'
                        : 'Start',
                    accent: course.color,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                course.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.66),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  valueColor: AlwaysStoppedAnimation<Color>(course.color),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.isCompleted
                    ? '${snapshot.completedLessons}/${snapshot.totalLessons} lessons completed'
                    : '${snapshot.completedLessons}/${snapshot.totalLessons} lessons • ${course.estimatedHours}h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: 0.62),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.nextLesson != null
                          ? snapshot.nextLesson!.title
                          : 'Course review',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: course.color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  final String text;
  final Color accent;

  const _TinyBadge({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AchievementsStrip extends StatelessWidget {
  final List<Achievement> unlockedAchievements;
  final VoidCallback onViewAllTap;

  const _AchievementsStrip({
    required this.unlockedAchievements,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (unlockedAchievements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your first badge is waiting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Finish one lesson to unlock it and see your momentum grow.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onViewAllTap,
              child: Text(
                AppLocalizations.of(context)?.get('view_all_achievements') ??
                    'View all achievements',
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: unlockedAchievements.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final achievement = unlockedAchievements[index];
          return _AchievementCard(achievement: achievement)
              .animate(delay: Duration(milliseconds: 60 * index))
              .fadeIn(duration: 500.ms)
              .slideX(begin: 0.12, end: 0);
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final languageCode = Localizations.localeOf(context).languageCode;
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.color.withValues(alpha: 0.24),
            achievement.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: achievement.color.withValues(alpha: 0.34)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.color.withValues(alpha: 0.18),
            ),
            child: Icon(achievement.icon, color: achievement.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.titleForLocale(languageCode),
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${achievement.xpReward} XP',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _greetingForHour(int hour, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  if (hour < 12) return l10n?.get('greeting_morning') ?? 'Good morning';
  if (hour < 18) return l10n?.get('greeting_afternoon') ?? 'Good afternoon';
  return l10n?.get('greeting_evening') ?? 'Good evening';
}

class _HomeCourseSnapshot {
  final Course course;
  final CourseProgress? progress;
  final List<Lesson> lessons;
  final Lesson? nextLesson;

  const _HomeCourseSnapshot({
    required this.course,
    required this.progress,
    required this.lessons,
    required this.nextLesson,
  });

  int get completedLessons => progress?.completedLessons.length ?? 0;
  int get totalLessons => lessons.length;
  bool get hasStarted => completedLessons > 0;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;
  double get completionRatio =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}
