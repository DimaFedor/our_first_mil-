import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/progress/screens/progress_screen.dart';

// Current tab provider
final currentTabProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.95),
              const Color(0xFF0A0E27).withOpacity(0.98),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                  label: AppLocalizations.of(context)?.get('courses') ?? 'Courses',
                  index: 1,
                  isSelected: currentTab == 1,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                ),
                _NavBarItem(
                  icon: Icons.trending_up_rounded,
                  label: AppLocalizations.of(context)?.get('progress') ?? 'Progress',
                  index: 2,
                  isSelected: currentTab == 2,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label: AppLocalizations.of(context)?.get('profile') ?? 'Profile',
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
                color: isSelected ? Colors.white : Colors.white60,
                size: 20,
              ),
              const SizedBox(height: 1),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
