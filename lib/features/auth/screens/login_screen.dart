import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_flow_exception.dart';
import '../models/auth_challenge.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _magicEmailController = TextEditingController();
  final _magicLinkController = TextEditingController();
  final _challengeAnswerController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  AuthChallenge? _activeChallenge;

  String _t(String key, String fallback) {
    return AppLocalizations.of(context)?.get(key) ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _magicEmailController.dispose();
    _magicLinkController.dispose();
    _challengeAnswerController.dispose();
    super.dispose();
  }

  Future<void> _runAuthAction(
    Future<void> Function() action, {
    String? successMessage,
    bool redirectToHome = false,
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

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage = _t('invalid_email', 'Please enter a valid email'),
      );
      return;
    }
    if (password.isEmpty) {
      setState(
        () => _errorMessage = _t('enter_password', 'Please enter a password'),
      );
      return;
    }

    await _runAuthAction(
      () => ref.read(authActionsProvider).signIn(email, password),
      redirectToHome: true,
    );
  }

  Future<void> _handleGoogleLogin() async {
    await _runAuthAction(
      () => ref.read(authActionsProvider).signInWithGoogle(),
      redirectToHome: true,
    );
  }

  Future<void> _handleSendMagicLink() async {
    final email = _magicEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage = _t('invalid_email', 'Please enter a valid email'),
      );
      return;
    }

    await _runAuthAction(
      () => ref.read(authActionsProvider).sendMagicLink(email),
      successMessage: _t(
        'magic_link_sent',
        'Magic link sent. Paste it in the field below.',
      ),
    );
  }

  Future<void> _handleMagicLinkSignIn() async {
    final magicLink = _magicLinkController.text.trim();
    if (magicLink.isEmpty) {
      setState(
        () => _errorMessage = _t(
          'magic_link_required',
          'Paste the magic link you received.',
        ),
      );
      return;
    }

    await _runAuthAction(
      () => ref
          .read(authActionsProvider)
          .signInWithMagicLink(
            emailLink: magicLink,
            email: _magicEmailController.text.trim(),
          ),
      redirectToHome: true,
    );
  }

  void _handleGenerateChallenge() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage = _t(
          'challenge_need_email_before_generate',
          'Enter a valid email before generating a challenge.',
        ),
      );
      return;
    }

    try {
      final challenge = ref
          .read(authActionsProvider)
          .createCodingChallenge(email);
      setState(() {
        _activeChallenge = challenge;
        _errorMessage = null;
        _successMessage = _t(
          'challenge_generated',
          'Challenge generated. Solve it and sign in.',
        );
      });
    } catch (error) {
      setState(() {
        _errorMessage = _getErrorMessage(error);
      });
    }
  }

  Future<void> _handleChallengeLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final answer = _challengeAnswerController.text.trim();

    if (_activeChallenge == null) {
      setState(
        () => _errorMessage = _t(
          'challenge_generate_first',
          'Generate a challenge first.',
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
    if (password.isEmpty) {
      setState(
        () => _errorMessage = _t('enter_password', 'Please enter a password'),
      );
      return;
    }
    if (answer.isEmpty) {
      setState(
        () => _errorMessage = _t(
          'challenge_enter_answer',
          'Enter an answer for the challenge.',
        ),
      );
      return;
    }

    await _runAuthAction(
      () => ref
          .read(authActionsProvider)
          .signInWithCodingChallenge(
            email: email,
            password: password,
            answer: answer,
          ),
      redirectToHome: true,
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(
        () => _errorMessage = _t(
          'reset_password_email_required',
          'Enter your email to reset the password.',
        ),
      );
      return;
    }

    await _runAuthAction(
      () => ref.read(authActionsProvider).resetPassword(email),
      successMessage: _t(
        'reset_password_sent',
        'Password reset email has been sent.',
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthFlowException) {
      switch (error.code) {
        case 'google-web-client-id-missing':
          return _t(
            'auth_google_web_not_configured',
            'Google Sign-In for web is not configured. Add a Web OAuth client ID.',
          );
        case 'google-sign-in-misconfigured':
          return _t(
            'auth_google_misconfigured',
            'Google Sign-In is not configured correctly.',
          );
        case 'google-sign-in-cancelled':
          return _t('auth_google_cancelled', 'Google sign-in was cancelled.');
        case 'google-sign-in-popup-blocked':
          return _t(
            'auth_google_popup_blocked',
            'Browser blocked Google sign-in popup. Allow popups and try again.',
          );
        default:
          break;
      }
      return error.message;
    }

    final message = error.toString().toLowerCase();
    if (message.contains('clientid not set') ||
        message.contains('google-signin-client_id')) {
      return _t(
        'auth_google_web_not_configured',
        'Google Sign-In for web is not configured. Add a Web OAuth client ID.',
      );
    }
    if (message.contains('popup_closed_by_user') ||
        message.contains('popup-closed-by-user') ||
        message.contains('cancelled') ||
        message.contains('canceled')) {
      return _t('auth_google_cancelled', 'Google sign-in was cancelled.');
    }
    if (message.contains('wrong-password') || message.contains('incorrect')) {
      return _t('auth_wrong_password', 'Incorrect password.');
    }
    if (message.contains('user-not-found') || message.contains('no user')) {
      return _t('auth_user_not_found', 'No user found with this email.');
    }
    if (message.contains('invalid-email')) {
      return _t('invalid_email', 'Please enter a valid email');
    }
    if (message.contains('challenge-expired')) {
      return _t(
        'auth_challenge_expired',
        'Challenge expired. Generate a new one.',
      );
    }
    if (message.contains('challenge-wrong-answer')) {
      return _t('auth_challenge_wrong_answer', 'Incorrect challenge answer.');
    }
    if (message.contains('too-many-requests') ||
        message.contains('rate-limited')) {
      return _t(
        'auth_too_many_requests',
        'Too many attempts. Try again later.',
      );
    }
    if (message.contains('network')) {
      return _t(
        'auth_network_problem',
        'Network error. Check your internet connection.',
      );
    }
    final fallback = _t(
      'auth_sign_in_failed',
      'Unable to sign in. Please try again.',
    );
    if (kDebugMode) {
      return '$fallback ($error)';
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
                const SizedBox(height: 16),
                _buildHeader(context, onSurface, l10n),
                const SizedBox(height: 24),
                if (_errorMessage != null || _successMessage != null)
                  _buildFeedbackCard(),
                _buildMethodTabs(isDarkTheme, onSurface, l10n),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_tabController.index),
                    child: _buildActiveMethodPanel(
                      context,
                      isDarkTheme,
                      onSurface,
                      l10n,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFooter(context, onSurface, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveMethodPanel(
    BuildContext context,
    bool isDarkTheme,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    switch (_tabController.index) {
      case 0:
        return _buildEmailTab(context, isDarkTheme, onSurface, l10n);
      case 1:
        return _buildMagicLinkTab(context, isDarkTheme, onSurface, l10n);
      case 2:
      default:
        return _buildChallengeTab(context, isDarkTheme, onSurface, l10n);
    }
  }

  Widget _buildHeader(
    BuildContext context,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 44,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            l10n?.get('welcome_back') ?? 'Welcome back',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            l10n?.get('login_subtitle') ??
                'Choose your preferred sign-in method and keep learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    final isError = _errorMessage != null;
    final color = isError ? Colors.red : Colors.green;
    final message = isError ? _errorMessage! : _successMessage!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildMethodTabs(
    bool isDarkTheme,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: onSurface.withValues(alpha: 0.7),
        tabs: [
          Tab(text: l10n?.get('sign_in') ?? 'Sign In'),
          Tab(text: l10n?.get('tab_magic_link') ?? 'Magic Link'),
          Tab(text: l10n?.get('tab_code_challenge') ?? 'Code Challenge'),
        ],
      ),
    );
  }

  Widget _buildEmailTab(
    BuildContext context,
    bool isDarkTheme,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return _buildCardShell(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: Text(l10n?.get('forgot_password') ?? 'Forgot Password?'),
            ),
          ),
          const SizedBox(height: 8),
          _buildPrimaryButton(
            title: l10n?.get('sign_in') ?? 'Sign in',
            onPressed: _isLoading ? null : _handleEmailLogin,
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            title: l10n?.get('continue_with_google') ?? 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: _isLoading ? null : _handleGoogleLogin,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildMagicLinkTab(
    BuildContext context,
    bool isDarkTheme,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return _buildCardShell(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.get('magic_link_title') ?? 'Passwordless sign in',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.get('magic_link_subtitle') ??
                'Get a magic link by email and sign in without a password.',
            style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _magicEmailController,
            label:
                l10n?.get('magic_link_email_label') ?? 'Email for magic link',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
          const SizedBox(height: 10),
          _buildPrimaryButton(
            title: l10n?.get('send_magic_link') ?? 'Send magic link',
            onPressed: _isLoading ? null : _handleSendMagicLink,
          ),
          const SizedBox(height: 18),
          _buildInputField(
            controller: _magicLinkController,
            label: l10n?.get('magic_link_input_label') ?? 'Paste magic link',
            icon: Icons.link_rounded,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
          const SizedBox(height: 10),
          _buildSecondaryButton(
            title:
                l10n?.get('sign_in_with_magic_link') ??
                'Sign in with magic link',
            icon: Icons.login_rounded,
            onPressed: _isLoading ? null : _handleMagicLinkSignIn,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTab(
    BuildContext context,
    bool isDarkTheme,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return _buildCardShell(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.get('challenge_login_title') ?? 'Login with challenge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.get('challenge_login_subtitle') ??
                'Solve a short challenge to confirm it is you.',
            style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _emailController,
            label: l10n?.get('email') ?? 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: _passwordController,
            label: l10n?.get('password') ?? 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
            suffix: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSecondaryButton(
            title: l10n?.get('generate_challenge') ?? 'Generate challenge',
            icon: Icons.bolt_rounded,
            onPressed: _isLoading ? null : _handleGenerateChallenge,
            isDarkTheme: isDarkTheme,
            onSurface: onSurface,
          ),
          if (_activeChallenge != null) ...[
            const SizedBox(height: 12),
            _buildChallengeCard(onSurface, isDarkTheme, _activeChallenge!),
            const SizedBox(height: 10),
            _buildInputField(
              controller: _challengeAnswerController,
              label: l10n?.get('your_answer') ?? 'Your answer',
              icon: Icons.terminal_rounded,
              isDarkTheme: isDarkTheme,
              onSurface: onSurface,
            ),
            const SizedBox(height: 10),
            _buildPrimaryButton(
              title: l10n?.get('solve_and_login') ?? 'Solve & login',
              onPressed: _isLoading ? null : _handleChallengeLogin,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    Color onSurface,
    bool isDarkTheme,
    AuthChallenge challenge,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF101933) : const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${challenge.language} · ${challenge.title}',
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${_t('attempts', 'Attempts')}: ${challenge.attemptsLeft}',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF0A1229) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8FF),
              ),
            ),
            child: Text(
              challenge.snippet,
              style: TextStyle(
                fontFamily: 'monospace',
                color: onSurface,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.question,
            style: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${_t('hint', 'Hint')}: ${challenge.hint}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    await _runAuthAction(
                      () => ref.read(authActionsProvider).signInAnonymously(),
                      redirectToHome: true,
                    );
                  },
            child: Text(l10n?.get('continue_as_guest') ?? 'Continue as guest'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n?.get('dont_have_account') ?? "Don't have an account?",
              style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
            ),
            TextButton(
              onPressed: _isLoading ? null : () => context.go('/register'),
              child: Text(l10n?.get('register') ?? 'Register'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardShell({required bool isDarkTheme, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
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
      height: 50,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                ? Colors.white.withValues(alpha: 0.14)
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
