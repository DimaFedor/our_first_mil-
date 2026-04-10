import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/lesson_localization_service.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/course_model.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lessonsAsync = ref.watch(localizedCourseLessonsProvider(course.id));
    final progressAsync = ref.watch(allUserProgressProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2E), Color(0xFF2D2D44)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            course.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: -0.3),

              // Course Stats
              lessonsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('${l10n?.get('error') ?? 'Error'}: $error'),
                ),
                data: (lessons) {
                  return progressAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('${l10n?.get('error') ?? 'Error'}: $error'),
                    ),
                    data: (courseProgressList) {
                      final courseProgress = courseProgressList
                          .where((cp) => cp.courseId == course.id)
                          .firstOrNull;

                      final completedLessons =
                          courseProgress?.completedLessons.length ?? 0;
                      final totalLessons = lessons.length;
                      final progress = totalLessons > 0
                          ? (completedLessons / totalLessons * 100).round()
                          : 0;

                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.play_circle_outline,
                              label: l10n?.get('lessons') ?? 'Lessons',
                              value: '$totalLessons',
                            ),
                            _StatItem(
                              icon: Icons.check_circle_outline,
                              label: l10n?.get('completed') ?? 'Completed',
                              value: '$completedLessons',
                            ),
                            _StatItem(
                              icon: Icons.trending_up,
                              label: l10n?.get('progress') ?? 'Progress',
                              value: '$progress%',
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
                    },
                  );
                },
              ),

              // Lessons List
              Expanded(
                child: lessonsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('${l10n?.get('error') ?? 'Error'}: $error'),
                  ),
                  data: (lessons) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];

                        return progressAsync.when(
                          loading: () => Card(
                            child: ListTile(
                              title: Text(l10n?.get('loading') ?? 'Loading...'),
                            ),
                          ),
                          error: (error, stack) => Card(
                            child: ListTile(
                              title: Text(
                                '${l10n?.get('error') ?? 'Error'}: $error',
                              ),
                            ),
                          ),
                          data: (courseProgressList) {
                            final courseProgress = courseProgressList
                                .where((cp) => cp.courseId == course.id)
                                .firstOrNull;

                            final isCompleted =
                                courseProgress?.completedLessons.contains(
                                  lesson.id,
                                ) ??
                                false;
                            final isUnlocked =
                                index == 0 ||
                                (courseProgress?.completedLessons.contains(
                                      lessons[index - 1].id,
                                    ) ??
                                    false);

                            return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.green.withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green
                                            : isUnlocked
                                            ? Colors.blue
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isCompleted
                                            ? Icons.check
                                            : isUnlocked
                                            ? Icons.play_arrow
                                            : Icons.lock,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      lesson.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lesson.description,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: isCompleted
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '+${lesson.xpReward} XP',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            '${lesson.xpReward} XP',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                    onTap: isUnlocked
                                        ? () {
                                            context.push(
                                              '/course/${course.id}/lesson/${lesson.id}',
                                              extra: {
                                                'course': course,
                                                'lesson': lesson,
                                              },
                                            );
                                          }
                                        : null,
                                  ),
                                )
                                .animate(
                                  delay: Duration(milliseconds: 100 * index),
                                )
                                .fadeIn(duration: 600.ms)
                                .slideX(begin: 0.3);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
