import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/components.dart';
import '../design_system/theme.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/home/home_screen.dart';
import '../features/journey/presentation/journey_screen.dart';
import '../features/learning/presentation/lesson_screen.dart';
import '../features/portfolio/presentation/portfolio_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/playground/playground_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/support_screen.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final onboarded = ref.watch(
    dataProvider.select((value) => value.value?.preferences.onboarded),
  );
  final router = GoRouter(
    redirect: (context, state) {
      if (onboarded == false && state.uri.path != '/welcome') return '/welcome';
      if (onboarded == true && state.uri.path == '/welcome') return '/';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: context.l10n.notFound,
        body: '',
        action: FilledButton(
          onPressed: () => context.go('/'),
          child: Text(context.l10n.home),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(location: state.uri.path, child: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journey',
                builder: (context, state) => const JourneyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/code',
                builder: (context, state) => const PlaygroundScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) =>
            CourseScreen(courseId: state.pathParameters['courseId'] ?? ''),
        routes: [
          GoRoute(
            path: 'lesson/:lessonId',
            builder: (context, state) => LessonScreen(
              courseId: state.pathParameters['courseId'] ?? '',
              lessonId: state.pathParameters['lessonId'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class AppShell extends ConsumerWidget {
  final String location;
  final Widget child;
  const AppShell({super.key, required this.location, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final routes = [
      '/',
      '/courses',
      '/journey',
      '/rewards',
      '/code',
      '/profile',
    ];
    final labels = [
      l.home,
      l.courses,
      l.journey,
      l.rewards,
      l.codeWorkspace,
      l.profile,
    ];
    final icons = [
      Icons.space_dashboard_outlined,
      Icons.explore_outlined,
      Icons.route_outlined,
      Icons.auto_awesome_outlined,
      Icons.code_rounded,
      Icons.person_outline_rounded,
    ];
    final index = routes.indexOf(location).clamp(0, routes.length - 1);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: Text(
                l.appTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: [
                IconButton(
                  onPressed: () => context.push('/settings'),
                  tooltip: l.settings,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Container(
                width: 240,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: BorderDirectional(
                    end: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 20, 30),
                      child: Row(
                        children: [
                          const Icon(Icons.code_rounded, color: brandMint),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              l.appTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var item = 0; item < routes.length; item++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          selected: index == item,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          leading: Icon(icons[item]),
                          title: Text(labels[item]),
                          onTap: () => context.go(routes[item]),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListTile(
                        leading: const Icon(Icons.tune_rounded),
                        title: Text(l.settings),
                        onTap: () => context.push('/settings'),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => context.go(routes[value]),
              destinations: List.generate(
                labels.length,
                (value) => NavigationDestination(
                  icon: Icon(icons[value]),
                  label: labels[value],
                ),
              ),
            ),
    );
  }
}
