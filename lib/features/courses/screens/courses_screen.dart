import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/course_content_service.dart';
import '../../../core/services/course_localization_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/course_model.dart';
import '../../lessons/models/lesson_model.dart';

enum _CourseFilter { all, inProgress, completed, newCourses }

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  _CourseFilter _selectedFilter = _CourseFilter.all;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final userId = ref.watch(currentUserUidProvider);
    final userDataAsync = userId == null
        ? const AsyncValue<UserModel?>.data(null)
        : ref.watch(userDataProvider(userId));
    final progressAsync = ref.watch(allUserProgressProvider);
    final coursesAsync = ref.watch(localizedCoursesProvider);

    final userData = userDataAsync.valueOrNull;
    final progressList = progressAsync.valueOrNull ?? const <CourseProgress>[];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme
                ? const [
                    Color(0xFF081024),
                    Color(0xFF121B38),
                    Color(0xFF0A1630),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFEFF4FF),
                    Color(0xFFE7EEFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: coursesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _CoursesErrorState(
              error: error,
              onRetry: () => _refresh(ref, userId),
            ),
            data: (courses) {
              final snapshots = _buildSnapshots(courses, progressList);
              final filteredSnapshots = _filterSnapshots(snapshots);
              final stats = _CourseStats.fromSnapshots(snapshots);
              final featuredSnapshot = filteredSnapshots.isEmpty
                  ? null
                  : filteredSnapshots.first;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 1100
                      ? 3
                      : constraints.maxWidth >= 700
                      ? 2
                      : 1;

                  return RefreshIndicator(
                    color: const Color(0xFF0066FF),
                    backgroundColor: colorScheme.surface,
                    onRefresh: () => _refresh(ref, userId),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child:
                                _CoursesHeroCard(
                                      stats: stats,
                                      userXp: userData?.totalXP ?? 0,
                                      currentStreak:
                                          userData?.currentStreak ?? 0,
                                      featuredSnapshot: featuredSnapshot,
                                      isDarkTheme: isDarkTheme,
                                      onFeaturedTap: featuredSnapshot == null
                                          ? null
                                          : () => _openCourse(
                                              context,
                                              featuredSnapshot,
                                            ),
                                      onBrowseTap: () {
                                        setState(() {
                                          _selectedFilter = _CourseFilter.all;
                                        });
                                      },
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideY(begin: 0.08, end: 0),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: _FilterBar(
                              filters: _buildFilters(snapshots, context),
                              selectedFilter: _selectedFilter,
                              onChanged: (filter) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${filteredSnapshots.length} '
                                    '${AppLocalizations.of(context)?.get('courses') ?? 'courses'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.get('choose_learning_path') ??
                                      'Choose your learning path',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        if (filteredSnapshots.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            sliver: SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyCoursesState(
                                onShowAll: () {
                                  setState(() {
                                    _selectedFilter = _CourseFilter.all;
                                  });
                                },
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: crossAxisCount == 1
                                        ? 340
                                        : 348,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final snapshot = filteredSnapshots[index];
                                return _CourseCard(
                                      snapshot: snapshot,
                                      isDarkTheme: isDarkTheme,
                                      onTap: () =>
                                          _openCourse(context, snapshot),
                                    )
                                    .animate(
                                      delay: Duration(milliseconds: 70 * index),
                                    )
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: 0.12, end: 0);
                              }, childCount: filteredSnapshots.length),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref, String? userId) async {
    ref.invalidate(localizedCoursesProvider);
    ref.invalidate(allUserProgressProvider);

    if (userId != null) {
      ref.invalidate(userDataProvider(userId));
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  List<_CourseSnapshot> _buildSnapshots(
    List<Course> courses,
    List<CourseProgress> progressList,
  ) {
    final snapshots = courses
        .map((course) {
          final progress = _findProgress(course, progressList);
          final lessons = CourseContentService.getLessonsForCourse(course.id);
          final nextLesson = _nextIncompleteLesson(lessons, progress);

          return _CourseSnapshot(
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

  int _priorityScore(_CourseSnapshot snapshot) {
    if (snapshot.isInProgress) return 0;
    if (snapshot.isNew) return 1;
    return 2;
  }

  List<_CourseSnapshot> _filterSnapshots(List<_CourseSnapshot> snapshots) {
    return snapshots
        .where((snapshot) {
          switch (_selectedFilter) {
            case _CourseFilter.all:
              return true;
            case _CourseFilter.inProgress:
              return snapshot.isInProgress;
            case _CourseFilter.completed:
              return snapshot.isCompleted;
            case _CourseFilter.newCourses:
              return snapshot.isNew;
          }
        })
        .toList(growable: false);
  }

  List<_CourseFilterItem> _buildFilters(
    List<_CourseSnapshot> snapshots,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    final completedLabel = l10n?.get('completed') ?? 'Completed';

    return [
      _CourseFilterItem(
        filter: _CourseFilter.all,
        label: l10n?.get('filter_all') ?? 'All',
        count: snapshots.length,
      ),
      _CourseFilterItem(
        filter: _CourseFilter.inProgress,
        label: l10n?.get('in_progress') ?? 'In progress',
        count: snapshots.where((snapshot) => snapshot.isInProgress).length,
      ),
      _CourseFilterItem(
        filter: _CourseFilter.completed,
        label: completedLabel,
        count: snapshots.where((snapshot) => snapshot.isCompleted).length,
      ),
      _CourseFilterItem(
        filter: _CourseFilter.newCourses,
        label: l10n?.get('filter_new') ?? 'New',
        count: snapshots.where((snapshot) => snapshot.isNew).length,
      ),
    ];
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

  void _openCourse(BuildContext context, _CourseSnapshot snapshot) {
    context.push('/course/${snapshot.course.id}', extra: snapshot.course);
  }
}

/*
class _CoursesHeroCard extends StatelessWidget {
  final _CourseStats stats;
  final int userXp;
  final int currentStreak;
  final _CourseSnapshot? featuredSnapshot;
  final VoidCallback? onFeaturedTap;
  final VoidCallback onBrowseTap;
  final bool isDarkTheme;

  const _CoursesHeroCard({
    required this.stats,
    required this.userXp,
    required this.currentStreak,
    required this.featuredSnapshot,
    required this.onFeaturedTap,
    required this.onBrowseTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heroTextColor = isDarkTheme ? Colors.white : const Color(0xFF0F172A);
    final heroMutedColor = heroTextColor.withValues(alpha: 0.72);
    final progressText =
        '${stats.completionPercent}% ${l10n?.get('progress') ?? 'Progress'}';
    final streakLabel = currentStreak > 0
        ? '$currentStreak ${l10n?.get('streak_days') ?? 'day streak'}'
        : l10n?.get('start_streak') ?? 'Start a streak';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? const [Color(0xFF18203D), Color(0xFF111B34), Color(0xFF091226)]
              : const [Color(0xFFFFFFFF), Color(0xFFF2F7FF), Color(0xFFE7EEFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkTheme ? 0.18 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -24,
            child: _HeroGlowOrb(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
              size: 160,
            ),
          ),
          Positioned(
            left: -36,
            bottom: -40,
            child: _HeroGlowOrb(
              color: const Color(0xFF0066FF).withValues(alpha: 0.12),
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
                          l10n?.get('courses') ?? 'Courses',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: heroTextColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n?.get('choose_learning_path') ??
                              'Choose your learning path',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: heroMutedColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      _HeroBadge(
                        icon: Icons.star_rounded,
                        label: '$userXp XP',
                        color: const Color(0xFFF59E0B),
                        textColor: heroTextColor,
                        backgroundColor: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                      _HeroBadge(
                        icon: Icons.local_fire_department_rounded,
                        label: streakLabel,
                        color: const Color(0xFFEF4444),
                        textColor: heroTextColor,
                        backgroundColor: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricTile(
                    value: '${stats.totalCourses}',
                    label: l10n?.get('courses') ?? 'Courses',
                    color: const Color(0xFF38BDF8),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.inProgressCourses}',
                    label: l10n?.get('in_progress') ?? 'In progress',
                    color: const Color(0xFF34D399),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.completedCourses}',
                    label: l10n?.get('completed') ?? 'Completed',
                    color: const Color(0xFFF59E0B),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.completedLessons}/${stats.totalLessons}',
                    label: l10n?.get('lessons') ?? 'Lessons',
                    color: const Color(0xFF8B5CF6),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: stats.completionRatio,
                  minHeight: 8,
                  backgroundColor: heroTextColor.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0066FF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progressText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: heroMutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${stats.completedLessons} ${l10n?.get('lessons_completed') ?? 'lessons completed'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: heroMutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (featuredSnapshot != null)
                _NextActionCard(
                  snapshot: featuredSnapshot!,
                  textColor: heroTextColor,
                  mutedColor: heroMutedColor,
                  isDarkTheme: isDarkTheme,
                  onTap: onFeaturedTap ?? onBrowseTap,
                )
              else
                _BrowsePromptCard(
                  textColor: heroTextColor,
                  mutedColor: heroMutedColor,
                  isDarkTheme: isDarkTheme,
                  onTap: onBrowseTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final _CourseSnapshot snapshot;
  final Color textColor;
  final Color mutedColor;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _NextActionCard({
    required this.snapshot,
    required this.textColor,
    required this.mutedColor,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = snapshot.course;
    final actionLabel = snapshot.actionLabel(context);
    final statusColor = snapshot.statusColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: statusColor.withValues(alpha: isDarkTheme ? 0.28 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: course.color.withValues(alpha: 0.16),
                ),
                child: Center(
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.focusText(context),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.completedLessons}/${snapshot.totalLessons} '
                      '${AppLocalizations.of(context)?.get('lessons') ?? 'Lessons'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionPill(label: actionLabel, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowsePromptCard extends StatelessWidget {
  final Color textColor;
  final Color mutedColor;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _BrowsePromptCard({
    required this.textColor,
    required this.mutedColor,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n?.get('start_first_course_title') ??
                          'Start your first course',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.get('start_first_course_desc') ??
                          'Open the course library and pick a path that fits your current goal.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionPill(
                label: l10n?.get('browse') ?? 'Browse',
                color: const Color(0xFF0066FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<_CourseFilterItem> filters;
  final _CourseFilter selectedFilter;
  final ValueChanged<_CourseFilter> onChanged;

  const _FilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters
          .map(
            (filter) => _FilterChip(
              item: filter,
              selected: filter.filter == selectedFilter,
              onTap: () => onChanged(filter.filter),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final _CourseFilterItem item;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                  )
                : null,
            color: selected
                ? null
                : theme.colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : onSurface.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: selected ? Colors.white : onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${item.count}',
                  style: TextStyle(
                    color: selected ? Colors.white : onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseSnapshot snapshot;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _CourseCard({
    required this.snapshot,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final course = snapshot.course;
    final statusColor = snapshot.statusColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: statusColor.withValues(alpha: isDarkTheme ? 0.24 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isDarkTheme ? 0.14 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -18,
                child: _HeroGlowOrb(
                  color: course.color.withValues(alpha: 0.12),
                  size: 92,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: course.color.withValues(alpha: 0.16),
                        ),
                        child: Center(
                          child: Text(
                            course.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(
                        label: snapshot.statusLabel(context),
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _TagChip(
                        label: course.difficulty,
                        color: course.color,
                        isDarkTheme: isDarkTheme,
                      ),
                      ...course.tags
                          .take(2)
                          .map(
                            (tag) => _TagChip(
                              label: tag,
                              color: course.color,
                              isDarkTheme: isDarkTheme,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.focusText(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.play_circle_outline_rounded,
                        label:
                            '${snapshot.completedLessons}/${snapshot.totalLessons}',
                        color: course.color,
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: '${course.estimatedHours}h',
                        color: course.color,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: snapshot.completionRatio,
                      minHeight: 7,
                      backgroundColor: onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${snapshot.completedLessons}/${snapshot.totalLessons} '
                          '${AppLocalizations.of(context)?.get('lessons') ?? 'Lessons'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                      ),
                      _ActionPill(
                        label: snapshot.actionLabel(context),
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCoursesState extends StatelessWidget {
  final VoidCallback onShowAll;

  const _EmptyCoursesState({required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0066FF).withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF0066FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.get('no_courses_match_filter') ??
                'No courses match this filter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.get('no_courses_match_filter_desc') ??
                'Switch back to all courses to keep exploring your learning paths.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.68),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onShowAll,
            child: Text(
              l10n?.get('show_all_courses') ?? 'Show all courses',
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _CoursesErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: onSurface.withValues(alpha: 0.7),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n?.get('error') ?? 'Error'}: $error',
              style: TextStyle(color: onSurface.withValues(alpha: 0.78)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n?.get('retry') ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

*/
class _CoursesHeroCard extends StatelessWidget {
  final _CourseStats stats;
  final int userXp;
  final int currentStreak;
  final _CourseSnapshot? featuredSnapshot;
  final VoidCallback? onFeaturedTap;
  final VoidCallback onBrowseTap;
  final bool isDarkTheme;

  const _CoursesHeroCard({
    required this.stats,
    required this.userXp,
    required this.currentStreak,
    required this.featuredSnapshot,
    required this.onFeaturedTap,
    required this.onBrowseTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final heroTextColor = isDarkTheme ? Colors.white : const Color(0xFF0F172A);
    final heroMutedColor = heroTextColor.withValues(alpha: 0.72);
    final progressText =
        '${stats.completionPercent}% ${AppLocalizations.of(context)?.get('progress') ?? 'Progress'}';
    final streakLabel = currentStreak > 0
        ? '$currentStreak day streak'
        : 'Start a streak';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? const [Color(0xFF18203D), Color(0xFF111B34), Color(0xFF091226)]
              : const [Color(0xFFFFFFFF), Color(0xFFF2F7FF), Color(0xFFE7EEFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkTheme ? 0.18 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -24,
            child: _HeroGlowOrb(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
              size: 160,
            ),
          ),
          Positioned(
            left: -36,
            bottom: -40,
            child: _HeroGlowOrb(
              color: const Color(0xFF0066FF).withValues(alpha: 0.12),
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
                          AppLocalizations.of(context)?.get('courses') ??
                              'Courses',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: heroTextColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.get('choose_learning_path') ??
                              'Choose your learning path',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: heroMutedColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      _HeroBadge(
                        icon: Icons.star_rounded,
                        label: '$userXp XP',
                        color: const Color(0xFFF59E0B),
                        textColor: heroTextColor,
                        backgroundColor: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                      _HeroBadge(
                        icon: Icons.local_fire_department_rounded,
                        label: streakLabel,
                        color: const Color(0xFFEF4444),
                        textColor: heroTextColor,
                        backgroundColor: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricTile(
                    value: '${stats.totalCourses}',
                    label:
                        AppLocalizations.of(context)?.get('courses') ??
                        'Courses',
                    color: const Color(0xFF38BDF8),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.inProgressCourses}',
                    label: 'In progress',
                    color: const Color(0xFF34D399),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.completedCourses}',
                    label:
                        AppLocalizations.of(context)?.get('completed') ??
                        'Completed',
                    color: const Color(0xFFF59E0B),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  _MetricTile(
                    value: '${stats.completedLessons}/${stats.totalLessons}',
                    label:
                        AppLocalizations.of(context)?.get('lessons') ??
                        'Lessons',
                    color: const Color(0xFF8B5CF6),
                    textColor: heroTextColor,
                    backgroundColor: isDarkTheme
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: stats.completionRatio,
                  minHeight: 8,
                  backgroundColor: heroTextColor.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0066FF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progressText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: heroMutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${stats.completedLessons} lessons completed',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: heroMutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (featuredSnapshot != null)
                _NextActionCard(
                  snapshot: featuredSnapshot!,
                  textColor: heroTextColor,
                  mutedColor: heroMutedColor,
                  isDarkTheme: isDarkTheme,
                  onTap: onFeaturedTap ?? onBrowseTap,
                )
              else
                _BrowsePromptCard(
                  textColor: heroTextColor,
                  mutedColor: heroMutedColor,
                  isDarkTheme: isDarkTheme,
                  onTap: onBrowseTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final _CourseSnapshot snapshot;
  final Color textColor;
  final Color mutedColor;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _NextActionCard({
    required this.snapshot,
    required this.textColor,
    required this.mutedColor,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = snapshot.course;
    final actionLabel = snapshot.actionLabel(context);
    final statusColor = snapshot.statusColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: statusColor.withValues(alpha: isDarkTheme ? 0.28 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: course.color.withValues(alpha: 0.16),
                ),
                child: Center(
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.focusText(context),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.completedLessons}/${snapshot.totalLessons} '
                      '${AppLocalizations.of(context)?.get('lessons') ?? 'Lessons'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionPill(label: actionLabel, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowsePromptCard extends StatelessWidget {
  final Color textColor;
  final Color mutedColor;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _BrowsePromptCard({
    required this.textColor,
    required this.mutedColor,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.8),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start your first course',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open the course library and pick a path that fits your current goal.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionPill(label: 'Browse', color: const Color(0xFF0066FF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<_CourseFilterItem> filters;
  final _CourseFilter selectedFilter;
  final ValueChanged<_CourseFilter> onChanged;

  const _FilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters
          .map(
            (filter) => _FilterChip(
              item: filter,
              selected: filter.filter == selectedFilter,
              onTap: () => onChanged(filter.filter),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final _CourseFilterItem item;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                  )
                : null,
            color: selected
                ? null
                : theme.colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : onSurface.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: selected ? Colors.white : onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${item.count}',
                  style: TextStyle(
                    color: selected ? Colors.white : onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseSnapshot snapshot;
  final bool isDarkTheme;
  final VoidCallback onTap;

  const _CourseCard({
    required this.snapshot,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final course = snapshot.course;
    final statusColor = snapshot.statusColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: statusColor.withValues(alpha: isDarkTheme ? 0.24 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: isDarkTheme ? 0.14 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -18,
                child: _HeroGlowOrb(
                  color: course.color.withValues(alpha: 0.12),
                  size: 92,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: course.color.withValues(alpha: 0.16),
                        ),
                        child: Center(
                          child: Text(
                            course.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(
                        label: snapshot.statusLabel(context),
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _TagChip(
                        label: course.difficulty,
                        color: course.color,
                        isDarkTheme: isDarkTheme,
                      ),
                      ...course.tags
                          .take(2)
                          .map(
                            (tag) => _TagChip(
                              label: tag,
                              color: course.color,
                              isDarkTheme: isDarkTheme,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.focusText(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.play_circle_outline_rounded,
                        label:
                            '${snapshot.completedLessons}/${snapshot.totalLessons}',
                        color: course.color,
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: '${course.estimatedHours}h',
                        color: course.color,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: snapshot.completionRatio,
                      minHeight: 7,
                      backgroundColor: onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${snapshot.completedLessons}/${snapshot.totalLessons} '
                          '${AppLocalizations.of(context)?.get('lessons') ?? 'Lessons'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                      ),
                      _ActionPill(
                        label: snapshot.actionLabel(context),
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCoursesState extends StatelessWidget {
  final VoidCallback onShowAll;

  const _EmptyCoursesState({required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0066FF).withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF0066FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No courses match this filter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Switch back to all courses to keep exploring your learning paths.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.68),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onShowAll,
            child: const Text('Show all courses'),
          ),
        ],
      ),
    );
  }
}

class _CoursesErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _CoursesErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: onSurface.withValues(alpha: 0.7),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              '${AppLocalizations.of(context)?.get('error') ?? 'Error'}: $error',
              style: TextStyle(color: onSurface.withValues(alpha: 0.78)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final Color backgroundColor;

  const _MetricTile({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(
              color == const Color(0xFF38BDF8)
                  ? Icons.school_rounded
                  : color == const Color(0xFF34D399)
                  ? Icons.trending_up_rounded
                  : color == const Color(0xFFF59E0B)
                  ? Icons.emoji_events_rounded
                  : Icons.menu_book_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color backgroundColor;

  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDarkTheme;

  const _TagChip({
    required this.label,
    required this.color,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDarkTheme
        ? color.withValues(alpha: 0.12)
        : color.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroGlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _HeroGlowOrb({required this.color, required this.size});

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

class _CourseFilterItem {
  final _CourseFilter filter;
  final String label;
  final int count;

  const _CourseFilterItem({
    required this.filter,
    required this.label,
    required this.count,
  });
}

class _CourseStats {
  final int totalCourses;
  final int inProgressCourses;
  final int completedCourses;
  final int completedLessons;
  final int totalLessons;

  const _CourseStats({
    required this.totalCourses,
    required this.inProgressCourses,
    required this.completedCourses,
    required this.completedLessons,
    required this.totalLessons,
  });

  factory _CourseStats.fromSnapshots(List<_CourseSnapshot> snapshots) {
    final totalCourses = snapshots.length;
    final inProgressCourses = snapshots
        .where((snapshot) => snapshot.isInProgress)
        .length;
    final completedCourses = snapshots
        .where((snapshot) => snapshot.isCompleted)
        .length;
    final completedLessons = snapshots.fold<int>(
      0,
      (sum, snapshot) => sum + snapshot.completedLessons,
    );
    final totalLessons = snapshots.fold<int>(
      0,
      (sum, snapshot) => sum + snapshot.totalLessons,
    );

    return _CourseStats(
      totalCourses: totalCourses,
      inProgressCourses: inProgressCourses,
      completedCourses: completedCourses,
      completedLessons: completedLessons,
      totalLessons: totalLessons,
    );
  }

  double get completionRatio =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;

  int get completionPercent => (completionRatio * 100).round();
}

class _CourseSnapshot {
  final Course course;
  final CourseProgress? progress;
  final List<Lesson> lessons;
  final Lesson? nextLesson;

  const _CourseSnapshot({
    required this.course,
    required this.progress,
    required this.lessons,
    required this.nextLesson,
  });

  int get completedLessons => progress?.completedLessons.length ?? 0;
  int get totalLessons => lessons.length;
  bool get hasStarted => completedLessons > 0;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;
  bool get isInProgress => hasStarted && !isCompleted;
  bool get isNew => !hasStarted;
  double get completionRatio =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  int get completionPercent => (completionRatio * 100).round();

  Lesson? get previewLesson =>
      nextLesson ?? (lessons.isNotEmpty ? lessons.first : null);

  Color get statusColor {
    if (isCompleted) {
      return const Color(0xFF22C55E);
    }
    if (isInProgress) {
      return course.color;
    }
    return const Color(0xFF3B82F6);
  }

  String statusLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isCompleted) return l10n?.get('completed') ?? 'Done';
    if (isInProgress) return '$completionPercent%';
    return l10n?.get('filter_new') ?? 'New';
  }

  String actionLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isCompleted) return l10n?.get('action_review') ?? 'Review';
    if (isInProgress) return l10n?.get('action_resume') ?? 'Resume';
    return l10n?.get('action_start') ?? 'Start';
  }

  String focusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isCompleted) return l10n?.get('course_complete') ?? 'Course complete';
    final lesson = previewLesson;
    if (lesson != null) {
      return '${l10n?.get('next_prefix') ?? 'Next'}: ${lesson.title}';
    }
    return l10n?.get('start_with_first_lesson') ??
        'Start with the first lesson';
  }
}
