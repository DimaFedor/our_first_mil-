import 'package:flutter/foundation.dart';
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

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.9),
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
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n?.get('app_name') ?? 'CodeLearn',
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n?.get('skip') ?? 'Skip',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 30 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: _currentPage == index
                            ? const LinearGradient(
                                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                              )
                            : null,
                        color: _currentPage == index
                            ? null
                            : (isDarkTheme
                                  ? Colors.white30
                                  : const Color(0xFF93C5FD)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _goNext,
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
                                  ? (l10n?.get('next') ?? 'Next')
                                  : (l10n?.get('get_started') ?? 'Get Started'),
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context.go('/register'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDarkTheme
                                ? Colors.white.withValues(alpha: 0.18)
                                : const Color(0xFFC7D7FF),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n?.get('create_account') ?? 'Create account',
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n?.get('sign_in') ?? 'Sign in',
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (kDebugMode)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(authActionsProvider)
                                  .signInAnonymously();
                              if (!context.mounted) return;
                              context.go('/');
                            } catch (_) {
                              if (!context.mounted) return;
                              context.go('/');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.withValues(
                              alpha: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n?.get('skip_auth_debug') ?? 'Skip Auth (Debug)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 420;
          final contentPadding = isCompact ? 18.0 : 24.0;
          final minScrollableHeight = constraints.maxHeight > contentPadding * 2
              ? constraints.maxHeight - (contentPadding * 2)
              : 0.0;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(contentPadding),
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFD6E2FF),
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minScrollableHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isCompact ? 88 : 120,
                      height: isCompact ? 88 : 120,
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
                        child: Text(
                          icon,
                          style: TextStyle(fontSize: isCompact ? 36 : 48),
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 18 : 28),
                    Text(
                      titleKey != null
                          ? (AppLocalizations.of(context)?.get(titleKey!) ??
                                title)
                          : title,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: isCompact ? 24 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 10 : 14),
                    Text(
                      descKey != null
                          ? (AppLocalizations.of(context)?.get(descKey!) ??
                                description)
                          : description,
                      style: TextStyle(
                        color: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.82)
                            : onSurface.withValues(alpha: 0.76),
                        fontSize: isCompact ? 15 : 17,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
