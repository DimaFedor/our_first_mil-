import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/course_localization_service.dart';
import '../models/course_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/enhanced_course_card.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final currentUser = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(allUserProgressProvider);
    final coursesAsync = ref.watch(localizedCoursesProvider);
    final userDataAsync = ref.watch(userDataProvider(currentUser?.uid ?? ''));

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with XP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                          AppLocalizations.of(context)?.get('courses') ??
                              'Courses',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    // XP Badge
                    userDataAsync.when(
                      data: (userData) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${userData?.totalXP ?? 0} XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(),
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.get('choose_learning_path') ??
                      'Choose your learning path',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onSurface.withValues(alpha: 0.65),
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 32),

                // Courses Grid
                Expanded(
                  child: coursesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text(
                        '${AppLocalizations.of(context)?.get('error') ?? 'Error'}: $error',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (courses) => progressAsync.when(
                      data: (allProgress) => _buildCoursesGrid(
                        context: context,
                        courses: courses,
                        allProgress: allProgress,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => _buildCoursesGrid(
                        context: context,
                        courses: courses,
                        allProgress: const <CourseProgress>[],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesGrid({
    required BuildContext context,
    required List<Course> courses,
    required List<CourseProgress> allProgress,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseProgress = allProgress
            .where((cp) => cp.courseId == course.id)
            .firstOrNull;
        final completedLessons = courseProgress?.completedLessons.length ?? 0;

        return EnhancedCourseCard(
              course: course,
              completedLessons: completedLessons,
              onTap: () => _navigateToCourse(context, course),
            )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  void _navigateToCourse(BuildContext context, Course course) {
    context.push('/course/${course.id}', extra: course);
  }
}
