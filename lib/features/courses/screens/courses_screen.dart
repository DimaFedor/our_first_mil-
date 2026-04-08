import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../models/course_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/enhanced_course_card.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(allUserProgressProvider);
    final userDataAsync = ref.watch(userDataProvider(currentUser?.uid ?? ''));
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF0D1B3A),
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
                      AppLocalizations.of(context)?.get('courses') ?? 'Courses',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    // XP Badge
                    userDataAsync.when(
                      data: (userData) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
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
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.get('choose_learning_path') ?? 'Choose your learning path',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white60,
                      ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 32),

                // Courses Grid
                Expanded(
                  child: progressAsync.when(
                    data: (allProgress) {
                      final courses = _getCourses(context);
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
                          // Find progress for this course
                          final courseProgress = allProgress
                              .where((cp) => cp.courseId == course.id)
                              .firstOrNull;
                          final completedLessons = courseProgress?.completedLessons.length ?? 0;
                          
                          return EnhancedCourseCard(
                            course: course,
                            completedLessons: completedLessons,
                            onTap: () => _navigateToCourse(context, course),
                          ).animate(delay: Duration(milliseconds: 100 * index))
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.3, end: 0);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                      children: _getCourses(context)
                          .map((course) => EnhancedCourseCard(
                                course: course,
                                completedLessons: 0,
                                onTap: () => _navigateToCourse(context, course),
                              ))
                          .toList(),
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

  List<Course> _getCourses(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      Course(
        id: 'python',
        title: l10n?.get('python') ?? 'Python',
        description: l10n?.get('python_desc') ?? 'Learn the fundamentals of Python programming',
        icon: '🐍',
        color: const Color(0xFF3776AB),
        difficulty: 'Beginner',
        totalLessons: 15,
        estimatedHours: 20,
        tags: ['Programming', 'Beginner-friendly', 'Popular'],
      ),
      Course(
        id: 'javascript',
        title: l10n?.get('javascript') ?? 'JavaScript',
        description: l10n?.get('javascript_desc') ?? 'Master modern JavaScript and ES6+',
        icon: '⚡',
        color: const Color(0xFFF7DF1E),
        difficulty: 'Beginner',
        totalLessons: 12,
        estimatedHours: 16,
        tags: ['Web Development', 'Frontend', 'Popular'],
      ),
      Course(
        id: 'htmlcss',
        title: l10n?.get('html_css') ?? 'HTML/CSS',
        description: l10n?.get('html_css_desc') ?? 'Build beautiful websites with HTML and CSS',
        icon: '🎨',
        color: const Color(0xFFE34F26),
        difficulty: 'Beginner',
        totalLessons: 10,
        estimatedHours: 12,
        tags: ['Web Design', 'Frontend', 'Visual'],
      ),
      Course(
        id: 'react',
        title: l10n?.get('react') ?? 'React',
        description: l10n?.get('react_desc') ?? 'Create interactive UIs with React',
        icon: '⚛️',
        color: const Color(0xFF61DAFB),
        difficulty: 'Intermediate',
        totalLessons: 8,
        estimatedHours: 15,
        tags: ['Frontend', 'Framework', 'Modern'],
      ),
      Course(
        id: 'sql',
        title: l10n?.get('sql') ?? 'SQL',
        description: l10n?.get('sql_desc') ?? 'Master database queries with SQL',
        icon: '🗄️',
        color: const Color(0xFF4479A1),
        difficulty: 'Beginner',
        totalLessons: 10,
        estimatedHours: 14,
        tags: ['Database', 'Backend', 'Data'],
      ),
      // Intermediate courses
      Course(
        id: 'python-intermediate',
        title: 'Python Intermediate',
        description: 'OOP, decorators, generators and advanced patterns',
        icon: '🐍',
        color: const Color(0xFF306998),
        difficulty: 'Intermediate',
        totalLessons: 5,
        estimatedHours: 12,
        tags: ['Programming', 'OOP', 'Advanced'],
      ),
      Course(
        id: 'htmlcss-intermediate',
        title: 'HTML/CSS Intermediate',
        description: 'Flexbox, Grid, animations and responsive design',
        icon: '🎨',
        color: const Color(0xFFCC6699),
        difficulty: 'Intermediate',
        totalLessons: 5,
        estimatedHours: 10,
        tags: ['Web Design', 'Layout', 'Responsive'],
      ),
      Course(
        id: 'javascript-intermediate',
        title: 'JavaScript Intermediate',
        description: 'ES6+, async/await, and functional programming',
        icon: '🟨',
        color: const Color(0xFFD4A017),
        difficulty: 'Intermediate',
        totalLessons: 5,
        estimatedHours: 12,
        tags: ['Programming', 'ES6', 'Async'],
      ),
      Course(
        id: 'sql-intermediate',
        title: 'SQL Intermediate',
        description: 'JOINs, subqueries, and window functions',
        icon: '🗄️',
        color: const Color(0xFF336791),
        difficulty: 'Intermediate',
        totalLessons: 5,
        estimatedHours: 12,
        tags: ['Database', 'Analytics', 'Advanced'],
      ),
      Course(
        id: 'react-intermediate',
        title: 'React Intermediate',
        description: 'Hooks, Context, and performance optimization',
        icon: '⚛️',
        color: const Color(0xFF00D8FF),
        difficulty: 'Intermediate',
        totalLessons: 5,
        estimatedHours: 14,
        tags: ['Frontend', 'Hooks', 'State'],
      ),
    ];
  }

  void _navigateToCourse(BuildContext context, Course course) {
    context.push('/course/${course.id}', extra: course);
  }
}
