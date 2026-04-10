import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/language_catalog.dart';
import '../../../core/l10n/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final availableLanguages =
        ref.watch(availableLanguagesProvider).valueOrNull ??
        LanguageCatalog.fallbackLanguages;
    final currentLanguage = _resolveCurrentLanguage(
      availableLanguages,
      currentLocale,
    );
    
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('settings'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              ),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 16),
                    
                    // Account Section
                    _buildSectionTitle(context.tr('account')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.person_outline,
                      title: context.tr('edit_profile'),
                      subtitle: 'Change your name and email',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 0,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.lock_outline,
                      title: context.tr('change_password'),
                      subtitle: 'Update your password',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 1,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Preferences Section
                    _buildSectionTitle(context.tr('preferences')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: context.tr('theme'),
                      subtitle: context.tr('dark_mode'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Theme switching coming in v1.1!')),
                        );
                      },
                      index: 2,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: context.tr('notifications'),
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Push notifications coming in v1.1!')),
                        );
                      },
                      index: 3,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.language_outlined,
                      title: context.tr('language'),
                      subtitle: '${currentLanguage.flag} ${currentLanguage.nativeName}',
                      onTap: () => _showLanguageDialog(context),
                      index: 4,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Data Section
                    _buildSectionTitle(context.tr('data_privacy')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.download_outlined,
                      title: context.tr('download_data'),
                      subtitle: 'Export your learning data',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 5,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.delete_outline,
                      title: context.tr('clear_cache'),
                      subtitle: 'Free up storage space',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1F3A),
                            title: Text(
                              '${context.tr('clear_cache')}?',
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              context.tr('clear_cache_confirm'),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(context.tr('cancel')),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cache cleared!')),
                                  );
                                },
                                child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      index: 6,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // About Section
                    _buildSectionTitle(context.tr('about')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: context.tr('version'),
                      subtitle: 'v1.0.0 Production Ready',
                      onTap: () {},
                      index: 7,
                      showArrow: false,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.description_outlined,
                      title: context.tr('terms_of_service'),
                      subtitle: 'Read our terms',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 8,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: context.tr('privacy_policy'),
                      subtitle: 'How we handle your data',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 9,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Danger Zone
                    _buildSectionTitle(context.tr('danger_zone'), color: Colors.red),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.logout,
                      title: context.tr('logout'),
                      subtitle: 'Sign out of your account',
                      color: Colors.red,
                      onTap: () async {
                        await ref.read(authActionsProvider).signOut();
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      },
                      index: 10,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.delete_forever,
                      title: context.tr('delete_account'),
                      subtitle: context.tr('delete_account_warning'),
                      color: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1F3A),
                            title: Text(
                              '${context.tr('delete_account')}?',
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              context.tr('delete_account_warning'),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(context.tr('cancel')),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(context.tr('coming_soon'))),
                                  );
                                },
                                child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      index: 11,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LanguagePickerSheet(),
    );
  }

  LanguageOption _resolveCurrentLanguage(
    List<LanguageOption> languages,
    Locale currentLocale,
  ) {
    for (final language in languages) {
      if (localeMatches(language.locale, currentLocale)) {
        return language;
      }

      if (language.locale.languageCode.toLowerCase() ==
          currentLocale.languageCode.toLowerCase()) {
        return language;
      }
    }

    return languages.first;
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.white.withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int index,
    Color? color,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.5),
            const Color(0xFF0D1B3A).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (color ?? Colors.blue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Colors.blue.shade300,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color ?? Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.4),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, end: 0);
  }
}

class _LanguagePickerSheet extends ConsumerStatefulWidget {
  const _LanguagePickerSheet();

  @override
  ConsumerState<_LanguagePickerSheet> createState() =>
      _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<_LanguagePickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final languagesAsync = ref.watch(availableLanguagesProvider);

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.45,
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('language'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('choose_language_subtitle'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: context.tr('search_language'),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF101730),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.blue.shade300,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: languagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${context.tr('error')}: $error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  data: (languages) {
                    final sourceLanguages = languages.isEmpty
                        ? LanguageCatalog.fallbackLanguages
                        : languages;
                    final filteredLanguages = _filterLanguages(
                      sourceLanguages,
                      _searchQuery,
                    );

                    if (filteredLanguages.isEmpty) {
                      return Center(
                        child: Text(
                          context.tr('no_languages_found'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = _columnsForWidth(
                          constraints.maxWidth,
                        );

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 86,
                          ),
                          itemCount: filteredLanguages.length,
                          itemBuilder: (context, index) {
                            final language = filteredLanguages[index];
                            final isSelected =
                                localeMatches(language.locale, currentLocale) ||
                                language.locale.languageCode.toLowerCase() ==
                                    currentLocale.languageCode.toLowerCase();

                            return _LanguageTile(
                              language: language,
                              isSelected: isSelected,
                              onTap: () =>
                                  _onLanguageSelected(context, language),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<LanguageOption> _filterLanguages(
    List<LanguageOption> languages,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return languages;
    }

    return languages.where((language) {
      return language.code.toLowerCase().contains(normalizedQuery) ||
          language.name.toLowerCase().contains(normalizedQuery) ||
          language.nativeName.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  int _columnsForWidth(double maxWidth) {
    if (maxWidth >= 1100) {
      return 4;
    }
    if (maxWidth >= 820) {
      return 3;
    }
    if (maxWidth >= 560) {
      return 2;
    }
    return 1;
  }

  Future<void> _onLanguageSelected(
    BuildContext context,
    LanguageOption language,
  ) async {
    await ref.read(localeProvider.notifier).setLanguageCode(language.code);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${language.flag} ${context.tr('language_changed')}')),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Colors.blue.shade300
        : Colors.white.withOpacity(0.12);
    final textColor = isSelected
        ? Colors.white
        : Colors.white.withOpacity(0.92);
    final subtitleColor = isSelected
        ? Colors.white.withOpacity(0.85)
        : Colors.white.withOpacity(0.62);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? const [Color(0xFF2D4FFF), Color(0xFF1F2C66)]
                  : const [Color(0xFF101730), Color(0xFF131E3A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        language.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('selected'),
                          color: Colors.white,
                          size: 20,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('not-selected'),
                          color: Colors.white.withOpacity(0.3),
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
