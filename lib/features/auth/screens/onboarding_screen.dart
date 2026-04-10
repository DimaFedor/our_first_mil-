import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Learn by Doing',
      description:
          'Master programming through interactive lessons, quizzes, and real coding challenges',
      icon: '💻',
      gradient: [Color(0xFF0066FF), Color(0xFF00CCFF)],
      titleKey: 'onboarding_title_1',
      descKey: 'onboarding_desc_1',
    ),
    const OnboardingPage(
      title: 'Track Your Progress',
      description:
          'Level up with XP, maintain streaks, and unlock achievements as you learn',
      icon: '🎯',
      gradient: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
      titleKey: 'onboarding_title_2',
      descKey: 'onboarding_desc_2',
    ),
    const OnboardingPage(
      title: 'Multiple Languages',
      description:
          'Choose from Python, JavaScript, HTML/CSS, React, SQL, and more',
      icon: '🚀',
      gradient: [Color(0xFF10B981), Color(0xFF06B6D4)],
      titleKey: 'onboarding_title_3',
      descKey: 'onboarding_desc_3',
    ),
    const OnboardingPage(
      title: 'Practice Makes Perfect',
      description:
          'Solve real coding problems and see your code run in real-time',
      icon: '⚡',
      gradient: [Color(0xFFEF4444), Color(0xFFF59E0B)],
      titleKey: 'onboarding_title_4',
      descKey: 'onboarding_desc_4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

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
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        AppLocalizations.of(context)?.get('skip') ?? 'Skip',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _pages[index];
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? (isDarkTheme
                                  ? Colors.white
                                  : const Color(0xFF2563EB))
                            : (isDarkTheme
                                  ? Colors.white30
                                  : const Color(0xFF93C5FD)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pages[_currentPage].gradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? (AppLocalizations.of(context)?.get('next') ??
                                    'Next')
                              : (AppLocalizations.of(
                                      context,
                                    )?.get('get_started') ??
                                    'Get Started'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Temporary Debug: Skip Auth Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authActionsProvider).signInAnonymously();
                        if (mounted) {
                          context.go("/");
                        }
                      } catch (e) {
                        context.go("/");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.get('skip_auth_debug') ??
                          'Skip Auth (Debug)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final List<Color> gradient;
  final String? titleKey;
  final String? descKey;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    this.titleKey,
    this.descKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            titleKey != null
                ? (AppLocalizations.of(context)?.get(titleKey!) ?? title)
                : title,
            style: TextStyle(
              color: onSurface,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            descKey != null
                ? (AppLocalizations.of(context)?.get(descKey!) ?? description)
                : description,
            style: TextStyle(
              color: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.8)
                  : onSurface.withValues(alpha: 0.75),
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
