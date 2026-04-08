import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/main_navigation.dart';
import '../auth/providers/auth_provider.dart';
import '../progress/providers/progress_provider.dart';
import '../progress/services/xp_system.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserUidProvider);
    final progressAsync = ref.watch(allUserProgressProvider);
    final userDataAsync = ref.watch(userDataProvider(userId ?? ''));
    final levelInfoAsync = ref.watch(levelInfoProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27), // Dark navy
              Color(0xFF1A1F3A), // Lighter navy
              Color(0xFF0D1B3A), // Blue tint
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile button
                _buildHeader(context, ref),
                const SizedBox(height: 24),
                
                // Welcome message with user stats
                _buildWelcomeSection(context, userDataAsync, levelInfoAsync),
                const SizedBox(height: 24),
                
                // Progress overview
                progressAsync.when(
                  data: (courseProgress) => _buildProgressOverview(context, ref, courseProgress),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                ),
                
                const SizedBox(height: 24),
                
                // CTA Button
                _buildCTAButton(context, ref),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.code, color: Colors.white, size: 24),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
              ).createShader(bounds),
              child: Text(
                AppLocalizations.of(context)?.get('app_name') ?? 'CodeLearn',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          ],
        ),
        // Profile button
        GestureDetector(
          onTap: () {
            // Switch to Profile tab (index 3)
            ref.read(currentTabProvider.notifier).state = 3;
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.person_outline, 
              color: Colors.white70,
              size: 24,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).scale(),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AsyncValue userData, AsyncValue levelInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userData.when(
          data: (data) => Text(
            'Welcome back! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        // Level and XP info
        levelInfo.when(
          data: (info) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0066FF).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Level badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    info.badge,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${info.level}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        info.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber.shade400, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${info.currentXP} / ${info.xpForNextLevel} XP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          loading: () => const SizedBox(height: 100),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildProgressOverview(BuildContext context, WidgetRef ref, List<dynamic> courseProgress) {
    CourseProgress? findProgress(String courseId) {
      try {
        return courseProgress.firstWhere(
          (cp) => cp.courseId == courseId,
        ) as CourseProgress?;
      } catch (_) {
        return null;
      }
    }
    
    final pythonProgress = findProgress('python-basics');
    final jsProgress = findProgress('javascript-basics');
    final htmlCssProgress = findProgress('html-css-basics');

    final courses = [
      {
        'name': 'Python',
        'icon': '🐍',
        'color': Colors.blue,
        'completed': pythonProgress?.completedLessons.length ?? 0,
        'total': 10,
        'courseId': 'python-basics',
      },
      {
        'name': 'JavaScript',
        'icon': '🌐',
        'color': Colors.yellow.shade700,
        'completed': jsProgress?.completedLessons.length ?? 0,
        'total': 10,
        'courseId': 'javascript-basics',
      },
      {
        'name': 'HTML/CSS',
        'icon': '🎨',
        'color': Colors.orange,
        'completed': htmlCssProgress?.completedLessons.length ?? 0,
        'total': 10,
        'courseId': 'html-css-basics',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.get('your_courses') ?? 'Your Courses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        ...courses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          return _buildCourseProgressCard(
            context,
            ref,
            course['name'] as String,
            course['icon'] as String,
            course['color'] as Color,
            course['completed'] as int,
            course['total'] as int,
            course['courseId'] as String,
            index,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCourseProgressCard(
    BuildContext context,
    WidgetRef ref,
    String name,
    String icon,
    Color color,
    int completed,
    int total,
    String courseId,
    int index,
  ) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to courses tab
          ref.read(currentTabProvider.notifier).state = 1;
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed/$total ${AppLocalizations.of(context)?.get('lessons_completed_suffix') ?? 'lessons completed'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 500 + (index * 100)))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildCTAButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Switch to Courses tab (index 1)
            ref.read(currentTabProvider.notifier).state = 1;
          },
          child: Center(
            child: Text(
              AppLocalizations.of(context)?.get('browse_all_courses') ?? 'Browse All Courses',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3)
        .shimmer(duration: 2000.ms, delay: 1500.ms);
  }
}
