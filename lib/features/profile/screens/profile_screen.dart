import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/services/xp_system.dart';
import '../../../shared/widgets/level_progress_widget.dart';
import '../../../shared/widgets/streak_widgets.dart';
import '../../../shared/widgets/language_stats_card.dart';
import '../../../shared/widgets/quick_access_card.dart';
import '../../../core/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Safe helper to get initial letter
  String _getInitial(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.substring(0, 1).toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  // Safe helper to get display name
  String _getDisplayName(String? displayName) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return 'User';
  }

  String _formatPreferredLanguage(String languageCode) {
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

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text(
          '${l10n?.get('logout') ?? 'Logout'}?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          l10n?.get('logout_confirm') ?? 'Are you sure you want to logout?',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.get('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.get('logout') ?? 'Logout',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authActionsProvider).signOut();
      if (!context.mounted) return;
      context.go('/onboarding');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.get('logout_success') ?? 'Logged out')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.get('logout_failed') ?? 'Logout failed. Please try again',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );
    final progressAsync = ref.watch(allUserProgressProvider);
    final levelInfoAsync = ref.watch(levelInfoProvider);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                          AppLocalizations.of(context)?.get('profile') ??
                              'Profile',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: onSurface.withValues(alpha: 0.7),
                          ),
                          onPressed: () => context.push('/edit-profile'),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: onSurface.withValues(alpha: 0.7),
                          ),
                          onPressed: () {
                            context.push('/settings');
                          },
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn(),
                  ],
                ),
                const SizedBox(height: 32),

                // Profile Card
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isDarkTheme
                                ? const Color(0xFF1A1F3A).withValues(alpha: 0.8)
                                : const Color(0xFFFFFFFF),
                            isDarkTheme
                                ? const Color(0xFF242B4A).withValues(alpha: 0.6)
                                : const Color(0xFFF1F5FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkTheme
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFD6E2FF),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0066FF),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0066FF,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitial(
                                      currentUser?.displayName,
                                      currentUser?.email,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                              .animate(delay: 300.ms)
                              .scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 20),

                          // Name
                          Text(
                            _getDisplayName(currentUser?.displayName),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ).animate(delay: 400.ms).fadeIn(),

                          // Email
                          const SizedBox(height: 8),
                          Text(
                            currentUser?.email?.isNotEmpty == true
                                ? currentUser!.email!
                                : 'user@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: onSurface.withValues(alpha: 0.65),
                            ),
                          ).animate(delay: 500.ms).fadeIn(),

                          const SizedBox(height: 12),
                          userDataAsync.when(
                            data: (userData) {
                              if (userData == null) return const SizedBox();
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _ProfileMetaChip(
                                    icon: Icons.auto_awesome,
                                    label:
                                        '${userData.skillLevel[0].toUpperCase()}${userData.skillLevel.substring(1)}',
                                  ),
                                  _ProfileMetaChip(
                                    icon: Icons.code_rounded,
                                    label: _formatPreferredLanguage(
                                      userData.preferredLanguage,
                                    ),
                                  ),
                                  _ProfileMetaChip(
                                    icon: Icons.timer_outlined,
                                    label:
                                        '${userData.dailyGoalMinutes} min/day',
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (_, _) => const SizedBox(),
                          ),

                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/edit-profile'),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.get('edit_profile') ??
                                  'Edit Profile',
                            ),
                          ),

                          // Level Badge
                          const SizedBox(height: 16),
                          levelInfoAsync.when(
                            data: (levelInfo) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDarkTheme
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    levelInfo.badge,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Level ${levelInfo.level} - ${levelInfo.title}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(delay: 550.ms).fadeIn().scale(),
                            loading: () => const SizedBox(height: 36),
                            error: (_, _) => const SizedBox(),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Level Progress Widget
                levelInfoAsync.when(
                  data: (levelInfo) => LevelProgressWidget(
                    levelInfo: levelInfo,
                  ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  loading: () => const SizedBox(height: 100),
                  error: (_, _) => const SizedBox(),
                ),

                const SizedBox(height: 24),

                // Stats - use userDataAsync for XP and streak, progressAsync for completed lessons count
                userDataAsync
                    .when(
                      data: (userData) {
                        return progressAsync.when(
                          data: (courseProgressList) {
                            // Count total completed lessons from all courses
                            final totalCompleted = courseProgressList.fold<int>(
                              0,
                              (sum, cp) => sum + cp.completedLessons.length,
                            );

                            return Row(
                              children: [
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.star,
                                    label:
                                        AppLocalizations.of(
                                          context,
                                        )?.get('total_xp') ??
                                        'Total XP',
                                    value: '${userData?.totalXP ?? 0}',
                                    gradient: const [
                                      Color(0xFFF59E0B),
                                      Color(0xFFFBBF24),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.local_fire_department,
                                    label:
                                        AppLocalizations.of(
                                          context,
                                        )?.get('current_streak') ??
                                        'Streak',
                                    value: '${userData?.currentStreak ?? 0}',
                                    gradient: const [
                                      Color(0xFFEF4444),
                                      Color(0xFFF97316),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.check_circle,
                                    label:
                                        AppLocalizations.of(
                                          context,
                                        )?.get('completed') ??
                                        'Completed',
                                    value: '$totalCompleted',
                                    gradient: const [
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, _) => const SizedBox(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SizedBox(),
                    )
                    .animate(delay: 600.ms)
                    .fadeIn()
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Streak Calendar (compact)
                userDataAsync.when(
                  data: (userData) => StreakIndicator(
                    days: userData?.currentStreak ?? 0,
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                const SizedBox(height: 16),

                // Language Stats
                progressAsync.when(
                  data: (courseProgressList) {
                    // Count lessons per language
                    int pythonLessons = 0;
                    int jsLessons = 0;
                    int htmlCssLessons = 0;
                    int reactLessons = 0;
                    int sqlLessons = 0;

                    for (var cp in courseProgressList) {
                      if (cp.courseId == 'python' ||
                          cp.courseId == 'python-basics') {
                        pythonLessons = cp.completedLessons.length;
                      } else if (cp.courseId == 'javascript' ||
                          cp.courseId == 'javascript-basics') {
                        jsLessons = cp.completedLessons.length;
                      } else if (cp.courseId == 'htmlcss' ||
                          cp.courseId == 'html-css-basics') {
                        htmlCssLessons = cp.completedLessons.length;
                      } else if (cp.courseId == 'react') {
                        reactLessons = cp.completedLessons.length;
                      } else if (cp.courseId == 'sql') {
                        sqlLessons = cp.completedLessons.length;
                      }
                    }

                    final totalCompleted =
                        pythonLessons +
                        jsLessons +
                        htmlCssLessons +
                        reactLessons +
                        sqlLessons;

                    return LanguageStatsCard(
                      pythonLessons: pythonLessons,
                      jsLessons: jsLessons,
                      htmlCssLessons: htmlCssLessons,
                      reactLessons: reactLessons,
                      sqlLessons: sqlLessons,
                      totalLessons: totalCompleted,
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                const SizedBox(height: 24),

                // Quick Access to Courses
                progressAsync.when(
                  data: (courseProgressList) {
                    final courses = [
                      {
                        'id': 'python-basics',
                        'title': 'Python',
                        'emoji': '🐍',
                        'color': Colors.blue,
                        'completed': courseProgressList
                            .firstWhere(
                              (cp) => cp.courseId == 'python-basics',
                              orElse: () => CourseProgress(
                                courseId: 'python-basics',
                                completedLessons: [],
                                totalXP: 0,
                              ),
                            )
                            .completedLessons
                            .length,
                        'total': 10,
                      },
                      {
                        'id': 'javascript-basics',
                        'title': 'JavaScript',
                        'emoji': '🌐',
                        'color': Colors.yellow.shade700,
                        'completed': courseProgressList
                            .firstWhere(
                              (cp) => cp.courseId == 'javascript-basics',
                              orElse: () => CourseProgress(
                                courseId: 'javascript-basics',
                                completedLessons: [],
                                totalXP: 0,
                              ),
                            )
                            .completedLessons
                            .length,
                        'total': 10,
                      },
                      {
                        'id': 'html-css-basics',
                        'title': 'HTML/CSS',
                        'emoji': '🎨',
                        'color': Colors.orange,
                        'completed': courseProgressList
                            .firstWhere(
                              (cp) => cp.courseId == 'html-css-basics',
                              orElse: () => CourseProgress(
                                courseId: 'html-css-basics',
                                completedLessons: [],
                                totalXP: 0,
                              ),
                            )
                            .completedLessons
                            .length,
                        'total': 10,
                      },
                    ];

                    // Filter to show only in-progress courses
                    final inProgressCourses = courses
                        .where(
                          (c) =>
                              c['completed'] as int > 0 &&
                              c['completed'] != c['total'],
                        )
                        .toList();

                    if (inProgressCourses.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return QuickAccessSection(
                          courses: inProgressCourses,
                          onCourseTap: (courseId) =>
                              context.push('/courses/$courseId'),
                        )
                        .animate(delay: 800.ms)
                        .fadeIn()
                        .slideY(begin: 0.2, end: 0);
                  },
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                ),

                const SizedBox(height: 24),

                // Menu Items
                _MenuItem(
                  icon: Icons.emoji_events,
                  title:
                      AppLocalizations.of(context)?.get('achievements') ??
                      'Achievements',
                  onTap: () => context.push('/achievements'),
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title:
                      AppLocalizations.of(context)?.get('settings') ??
                      'Settings',
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.history,
                  title:
                      AppLocalizations.of(context)?.get('learning_history') ??
                      'Learning History',
                  onTap: () => context.push('/learning-journey'),
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.help_outline,
                  title:
                      AppLocalizations.of(context)?.get('help_support') ??
                      'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)?.get('coming_soon') ??
                              'Coming soon!',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.logout,
                  title:
                      AppLocalizations.of(context)?.get('logout') ?? 'Logout',
                  color: Colors.red,
                  onTap: () => _confirmAndLogout(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final itemColor =
        color ??
        (isDarkTheme ? Colors.white : Theme.of(context).colorScheme.onSurface);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkTheme
                ? const Color(0xFF1A1F3A).withValues(alpha: 0.6)
                : const Color(0xFFFFFFFF),
            isDarkTheme
                ? const Color(0xFF242B4A).withValues(alpha: 0.4)
                : const Color(0xFFF1F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: itemColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: itemColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: itemColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.2, end: 0);
  }
}
