import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/language_catalog.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/services/auth_flow_exception.dart';
import '../../../core/theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final availableLanguages =
        ref.watch(availableLanguagesProvider).valueOrNull ??
        LanguageCatalog.fallbackLanguages;
    final currentLanguage = _resolveCurrentLanguage(
      availableLanguages,
      currentLocale,
    );

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
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child:
                    Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('settings'),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 16),

                    // Account Section
                    _buildSectionTitle(context, context.tr('account')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.person_outline,
                      title: context.tr('edit_profile'),
                      subtitle: 'Change your name and email',
                      onTap: () => context.push('/edit-profile'),
                      index: 0,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.lock_outline,
                      title: context.tr('change_password'),
                      subtitle: context.tr('change_password_subtitle'),
                      onTap: () async {
                        final changed = await showDialog<bool>(
                          context: context,
                          builder: (_) => const _ChangePasswordDialog(),
                        );
                        if (!context.mounted || changed != true) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.tr('password_changed_success'),
                            ),
                          ),
                        );
                      },
                      index: 1,
                    ),

                    const SizedBox(height: 24),

                    // Preferences Section
                    _buildSectionTitle(context, context.tr('preferences')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: context.tr('theme'),
                      subtitle: _themeModeLabel(context, themeMode),
                      onTap: () => _showThemeDialog(context),
                      index: 2,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: context.tr('notifications'),
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Push notifications coming in v1.1!'),
                          ),
                        );
                      },
                      index: 3,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.language_outlined,
                      title: context.tr('language'),
                      subtitle:
                          '${currentLanguage.flag} ${currentLanguage.nativeName}',
                      onTap: () => _showLanguageDialog(context),
                      index: 4,
                    ),

                    const SizedBox(height: 24),

                    // Data Section
                    _buildSectionTitle(context, context.tr('data_privacy')),
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
                            backgroundColor: Theme.of(ctx).colorScheme.surface,
                            title: Text(
                              '${context.tr('clear_cache')}?',
                              style: TextStyle(
                                color: Theme.of(ctx).colorScheme.onSurface,
                              ),
                            ),
                            content: Text(
                              context.tr('clear_cache_confirm'),
                              style: TextStyle(
                                color: Theme.of(
                                  ctx,
                                ).colorScheme.onSurface.withValues(alpha: 0.75),
                              ),
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
                                    const SnackBar(
                                      content: Text('Cache cleared!'),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('delete'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      index: 6,
                    ),

                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionTitle(context, context.tr('about')),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: context.tr('version'),
                      subtitle: context.tr('version_subtitle'),
                      onTap: () {},
                      index: 7,
                      showArrow: false,
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.description_outlined,
                      title: context.tr('terms_of_service'),
                      subtitle: context.tr('terms_subtitle'),
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
                      subtitle: context.tr('privacy_subtitle'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('coming_soon'))),
                        );
                      },
                      index: 9,
                    ),

                    const SizedBox(height: 24),

                    // Danger Zone
                    _buildSectionTitle(
                      context,
                      context.tr('danger_zone'),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingItem(
                      context,
                      icon: Icons.logout,
                      title: context.tr('logout'),
                      subtitle: context.tr('sign_out_subtitle'),
                      color: Colors.red,
                      onTap: () => _confirmAndLogout(context, ref),
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
                            backgroundColor: Theme.of(ctx).colorScheme.surface,
                            title: Text(
                              '${context.tr('delete_account')}?',
                              style: TextStyle(
                                color: Theme.of(ctx).colorScheme.onSurface,
                              ),
                            ),
                            content: Text(
                              context.tr('delete_account_warning'),
                              style: TextStyle(
                                color: Theme.of(
                                  ctx,
                                ).colorScheme.onSurface.withValues(alpha: 0.75),
                              ),
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
                                    SnackBar(
                                      content: Text(context.tr('coming_soon')),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('delete'),
                                  style: const TextStyle(color: Colors.red),
                                ),
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

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ThemePickerSheet(),
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return context.tr('light_mode');
      case ThemeMode.dark:
        return context.tr('dark_mode');
      case ThemeMode.system:
        return context.tr('system_theme');
    }
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text(
          '${context.tr('logout')}?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          context.tr('logout_confirm'),
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.tr('logout'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('logout_success'))));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('logout_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    Color? color,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color:
            color ??
            (isDarkTheme
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6)),
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
    Widget? trailing,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isDarkTheme ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF4B5563);

    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkTheme
                    ? const Color(0xFF1A1F3A).withValues(alpha: 0.5)
                    : const Color(0xFFFFFFFF),
                isDarkTheme
                    ? const Color(0xFF0D1B3A).withValues(alpha: 0.3)
                    : const Color(0xFFF1F5FF),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFD6E2FF),
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
                        color: (color ?? Colors.blue).withValues(alpha: 0.15),
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
                              color: color ?? baseTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing
                    else if (showArrow)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDarkTheme
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.4),
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

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      setState(() => _errorMessage = context.tr('enter_current_password'));
      return;
    }
    if (newPassword.isEmpty) {
      setState(() => _errorMessage = context.tr('enter_new_password'));
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errorMessage = context.tr('password_too_short'));
      return;
    }
    if (newPassword == currentPassword) {
      setState(() => _errorMessage = context.tr('new_password_must_differ'));
      return;
    }
    if (confirmPassword != newPassword) {
      setState(() => _errorMessage = context.tr('passwords_not_match'));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authActionsProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  String _resolveError(dynamic error) {
    if (error is AuthFlowException) {
      switch (error.code) {
        case 'password-provider-not-linked':
          return context.tr('password_change_password_provider_unavailable');
        case 'invalid-current-password':
          return context.tr('enter_current_password');
        case 'invalid-new-password':
          return context.tr('password_too_short');
        case 'same-password':
          return context.tr('new_password_must_differ');
        case 'requires-recent-login':
          return context.tr('password_change_requires_recent_login');
        default:
          return error.message;
      }
    }

    final message = error.toString().toLowerCase();
    if (message.contains('wrong-password') ||
        message.contains('wrong password') ||
        message.contains('invalid-credential') ||
        message.contains('incorrect')) {
      return context.tr('auth_wrong_password');
    }
    if (message.contains('requires-recent-login')) {
      return context.tr('password_change_requires_recent_login');
    }
    if (message.contains('password-provider-not-linked') ||
        message.contains('guest accounts')) {
      return context.tr('password_change_password_provider_unavailable');
    }
    if (message.contains('at least 6')) {
      return context.tr('password_too_short');
    }
    if (message.contains('different from')) {
      return context.tr('new_password_must_differ');
    }
    if (message.contains('network')) {
      return context.tr('auth_network_problem');
    }
    return context.tr('password_change_failed');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        context.tr('change_password'),
        style: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                label: context.tr('current_password'),
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: _newPasswordController,
                label: context.tr('new_password'),
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: context.tr('confirm_password'),
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkTheme
                ? Colors.blue.shade400
                : Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Text(context.tr('change_password')),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.75,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.45,
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: colorScheme.onSurface.withValues(
                alpha: isDarkTheme ? 0.14 : 0.08,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(
                    alpha: isDarkTheme ? 0.35 : 0.22,
                  ),
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
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('choose_language_subtitle'),
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.68,
                              ),
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
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: context.tr('search_language'),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: isDarkTheme ? 0.35 : 0.7,
                    ),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
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
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = _columnsForWidth(constraints.maxWidth);

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

    return languages
        .where((language) {
          return language.code.toLowerCase().contains(normalizedQuery) ||
              language.name.toLowerCase().contains(normalizedQuery) ||
              language.nativeName.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
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

  void _onLanguageSelected(BuildContext context, LanguageOption language) {
    ref.read(localeProvider.notifier).setLanguageCode(language.code);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${language.flag} ${context.tr('language_changed')}'),
      ),
    );
  }
}

class _ThemePickerSheet extends ConsumerStatefulWidget {
  const _ThemePickerSheet();

  @override
  ConsumerState<_ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<_ThemePickerSheet> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.dark_mode_rounded,
                    color: Colors.blueAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('theme'),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('system_theme'),
                          style: TextStyle(
                            color: isDarkTheme
                                ? Colors.white.withValues(alpha: 0.65)
                                : Colors.black.withValues(alpha: 0.55),
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
            _themeOptionTile(
              context: context,
              theme: theme,
              isDarkTheme: isDarkTheme,
              title: context.tr('system_theme'),
              icon: Icons.brightness_auto_rounded,
              isSelected: currentThemeMode == ThemeMode.system,
              onTap: () => _selectThemeMode(context, ThemeMode.system),
            ),
            _themeOptionTile(
              context: context,
              theme: theme,
              isDarkTheme: isDarkTheme,
              title: context.tr('light_mode'),
              icon: Icons.light_mode_rounded,
              isSelected: currentThemeMode == ThemeMode.light,
              onTap: () => _selectThemeMode(context, ThemeMode.light),
            ),
            _themeOptionTile(
              context: context,
              theme: theme,
              isDarkTheme: isDarkTheme,
              title: context.tr('dark_mode'),
              icon: Icons.dark_mode_rounded,
              isSelected: currentThemeMode == ThemeMode.dark,
              onTap: () => _selectThemeMode(context, ThemeMode.dark),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _themeOptionTile({
    required BuildContext context,
    required ThemeData theme,
    required bool isDarkTheme,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? Colors.blue.shade300
        : (isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E2FF));
    final tileColor = isSelected
        ? null
        : (isDarkTheme ? const Color(0xFF101730) : const Color(0xFFF7FAFF));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF2D4FFF), Color(0xFF1F2C66)],
                    )
                  : null,
              color: tileColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.blueAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectThemeMode(BuildContext context, ThemeMode mode) {
    ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
    Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.72)
        : colorScheme.outline.withValues(alpha: isDarkTheme ? 0.35 : 0.28);
    final textColor = isSelected ? Colors.white : colorScheme.onSurface;
    final subtitleColor = isSelected
        ? Colors.white.withValues(alpha: 0.85)
        : colorScheme.onSurface.withValues(alpha: 0.68);

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
                  : [
                      colorScheme.surfaceContainerHighest.withValues(
                        alpha: isDarkTheme ? 0.35 : 0.95,
                      ),
                      colorScheme.surface.withValues(
                        alpha: isDarkTheme ? 0.72 : 1,
                      ),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.24),
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
                        style: TextStyle(color: subtitleColor, fontSize: 12),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
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
