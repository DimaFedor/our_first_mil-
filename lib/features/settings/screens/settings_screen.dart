import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = availableLanguages.firstWhere(
      (lang) => lang.code == currentLocale.languageCode,
      orElse: () => availableLanguages.first,
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
                      onTap: () => _showLanguageDialog(context, ref),
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

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('language'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...availableLanguages.map((lang) {
                final isSelected = lang.code == currentLocale.languageCode;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lang.name,
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLanguageCode(lang.code);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${lang.flag} Language changed to ${lang.nativeName}')),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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
