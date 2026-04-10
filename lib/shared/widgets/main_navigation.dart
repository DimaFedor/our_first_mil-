import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/engagement_notification_service.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/progress/providers/progress_provider.dart';
import '../../features/progress/screens/progress_screen.dart';

// Current tab provider
final currentTabProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  String _lastNotificationSyncSignature = '';

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserUidProvider);
    final userDataAsync = userId == null
        ? const AsyncValue<UserModel?>.data(null)
        : ref.watch(userDataProvider(userId));
    final allProgressAsync = ref.watch(allUserProgressProvider);

    _syncEngagementNotifications(
      userId: userId,
      userData: userDataAsync.valueOrNull,
      allProgress: allProgressAsync.valueOrNull,
    );

    final currentTab = ref.watch(currentTabProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: MainNavigationScreen._screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkTheme
                ? [
                    const Color(0xFF1A1F3A).withValues(alpha: 0.95),
                    const Color(0xFF0A0E27).withValues(alpha: 0.98),
                  ]
                : const [Color(0xFFFFFFFF), Color(0xFFF2F6FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: AppLocalizations.of(context)?.get('home') ?? 'Home',
                  index: 0,
                  isSelected: currentTab == 0,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 0,
                ),
                _NavBarItem(
                  icon: Icons.school_rounded,
                  label:
                      AppLocalizations.of(context)?.get('courses') ?? 'Courses',
                  index: 1,
                  isSelected: currentTab == 1,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                ),
                _NavBarItem(
                  icon: Icons.trending_up_rounded,
                  label:
                      AppLocalizations.of(context)?.get('progress') ??
                      'Progress',
                  index: 2,
                  isSelected: currentTab == 2,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label:
                      AppLocalizations.of(context)?.get('profile') ?? 'Profile',
                  index: 3,
                  isSelected: currentTab == 3,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncEngagementNotifications({
    required String? userId,
    required UserModel? userData,
    required List<CourseProgress>? allProgress,
  }) {
    if (userId == null || userData == null || allProgress == null) return;

    final totalLessons = allProgress.fold<int>(
      0,
      (sum, course) => sum + course.completedLessons.length,
    );
    final lastActiveMillis = userData.lastActive?.millisecondsSinceEpoch ?? 0;
    final signature =
        '$userId|${userData.currentStreak}|${userData.totalXP}|$totalLessons|$lastActiveMillis';
    if (signature == _lastNotificationSyncSignature) return;
    _lastNotificationSyncSignature = signature;

    EngagementNotificationService.instance.refreshForUser(
      userId: userId,
      currentStreak: userData.currentStreak,
      totalLessons: totalLessons,
      totalXP: userData.totalXP,
      lastActive: userData.lastActive,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final unselectedColor = onSurface.withValues(alpha: 0.65);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : unselectedColor,
                size: 20,
              ),
              const SizedBox(height: 1),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : unselectedColor,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
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
