import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_flow_exception.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _selectedSkillLevel = 'beginner';
  String _selectedLanguage = 'python';

  static const _skillLevels = <String, String>{
    'beginner': 'difficulty_beginner',
    'intermediate': 'difficulty_intermediate',
    'advanced': 'tag_advanced',
  };

  static const _languages = <String, String>{
    'python': 'python',
    'javascript': 'javascript',
    'cplusplus': 'cplusplus',
    'sql': 'sql',
    'dart': 'dart',
  };

  String _t(String key, String fallback) {
    final localized = AppLocalizations.of(context)?.get(key);
    if (localized == null || localized == key) {
      return fallback;
    }
    return localized;
  }

  String _skillLabel(String level) {
    final key = _skillLevels[level];
    switch (level) {
      case 'beginner':
        return _t(key ?? 'difficulty_beginner', 'Beginner');
      case 'intermediate':
        return _t(key ?? 'difficulty_intermediate', 'Intermediate');
      case 'advanced':
        return _t(key ?? 'tag_advanced', 'Advanced');
      default:
        return level;
    }
  }

  String _languageLabel(String languageCode) {
    final key = _languages[languageCode];
    switch (languageCode) {
      case 'python':
        return _t(key ?? 'python', 'Python');
      case 'javascript':
        return _t(key ?? 'javascript', 'JavaScript');
      case 'cplusplus':
        return _t(key ?? 'cplusplus', 'C++');
      case 'sql':
        return _t(key ?? 'sql', 'SQL');
      case 'dart':
        return _t(key ?? 'dart', 'Dart');
      default:
        return languageCode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _runRegisterAction(
    Future<void> Function() action, {
    bool redirectToHome = false,
    String? successMessage,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await action();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _successMessage = successMessage;
      });

      if (redirectToHome) {
        context.go('/');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(error);
      });
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.length < 2) {
      setState(
        () => _errorMessage = _t(
          'name_too_short',
          'Name must be at least 2 characters',
        ),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage = _t('invalid_email', 'Please enter a valid email'),
      );
      return;
    }
    if (password.length < 6) {
      setState(
        () => _errorMessage = _t(
          'password_too_short',
          'Password must be at least 6 characters',
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      setState(
        () =>
            _errorMessage = _t('passwords_not_match', 'Passwords do not match'),
      );
      return;
    }

    await _runRegisterAction(
      () => ref
          .read(authActionsProvider)
          .signUp(
            email,
            password,
            name,
            skillLevel: _selectedSkillLevel,
            preferredLanguage: _selectedLanguage,
          ),
      redirectToHome: true,
    );
  }

  Future<void> _handleGoogleSignUp() async {
    await _runRegisterAction(
      () => ref
          .read(authActionsProvider)
          .signInWithGoogle(
            skillLevel: _selectedSkillLevel,
            preferredLanguage: _selectedLanguage,
          ),
      redirectToHome: true,
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthFlowException) {
      return error.message;
    }

    final message = error.toString().toLowerCase();
    if (message.contains('email-already-in-use') ||
        message.contains('already exists')) {
      return _t(
        'auth_account_exists',
        'An account with this email already exists.',
      );
    }
    if (message.contains('weak-password')) {
      return _t(
        'auth_weak_password',
        'Weak password. Use at least 6 characters.',
      );
    }
    if (message.contains('invalid-email')) {
      return _t('invalid_email', 'Please enter a valid email');
    }
    if (message.contains('network')) {
      return _t(
        'auth_network_problem',
        'Network error. Check your internet connection.',
      );
    }
    return _t(
      'auth_register_failed',
      'Unable to create account. Please try again.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final l10n = AppLocalizations.of(context);

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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: onSurface),
                  onPressed: () => context.go('/login'),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.get('create_account') ?? 'Create account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  l10n?.get('register_subtitle') ??
                      'Set up your account and start your coding quest.',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null || _successMessage != null)
                  _buildFeedbackCard(),
                _buildCardShell(
                  isDarkTheme: isDarkTheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        controller: _nameController,
                        label: l10n?.get('full_name') ?? 'Full name',
                        icon: Icons.person_outline_rounded,
                        isDarkTheme: isDarkTheme,
                        onSurface: onSurface,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _emailController,
                        label: l10n?.get('email') ?? 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDarkTheme: isDarkTheme,
                        onSurface: onSurface,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _passwordController,
                        label: l10n?.get('password') ?? 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        isDarkTheme: isDarkTheme,
                        onSurface: onSurface,
                        suffix: IconButton(
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _confirmPasswordController,
                        label:
                            l10n?.get('confirm_password') ?? 'Confirm password',
                        icon: Icons.lock_reset_rounded,
                        obscureText: _obscureConfirmPassword,
                        isDarkTheme: isDarkTheme,
                        onSurface: onSurface,
                        suffix: IconButton(
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCardShell(
                  isDarkTheme: isDarkTheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.get('register_skill_level_title') ??
                            '1) Skill level',
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skillLevels.entries.map((entry) {
                          final isSelected = _selectedSkillLevel == entry.key;
                          return _buildChoiceChip(
                            label: _skillLabel(entry.key),
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedSkillLevel = entry.key);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n?.get('register_focus_language_title') ??
                            '2) First focus language',
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _languages.entries.map((entry) {
                          final isSelected = _selectedLanguage == entry.key;
                          return _buildChoiceChip(
                            label: _languageLabel(entry.key),
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedLanguage = entry.key);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildStarterQuestCard(),
                const SizedBox(height: 16),
                _buildPrimaryButton(
                  title: l10n?.get('create_account') ?? 'Create account',
                  onPressed: _isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 10),
                _buildSecondaryButton(
                  title:
                      l10n?.get('sign_up_with_google') ?? 'Sign up with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n?.get('already_have_account') ??
                          'Already have an account?',
                      style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/login'),
                      child: Text(l10n?.get('sign_in') ?? 'Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    final isError = _errorMessage != null;
    final color = isError ? Colors.red : Colors.green;
    final message = isError ? _errorMessage! : _successMessage!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterQuestCard() {
    final level = _skillLabel(_selectedSkillLevel);
    final language = _languageLabel(_selectedLanguage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('starter_quest_title', 'Starter Quest'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_t('starter_quest_start', 'Your start')}: $level · $language',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _t(
              'starter_quest_message',
              'After sign up, you will get a personalized welcome and recommendations.',
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCardShell({required bool isDarkTheme, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: child,
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFFB7C8FF).withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF35548A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkTheme,
    required Color onSurface,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: onSurface.withValues(alpha: 0.7)),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDarkTheme
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.09)
                : const Color(0xFFD6E2FF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String title,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String title,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFC7D7FF),
          ),
          foregroundColor: onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
