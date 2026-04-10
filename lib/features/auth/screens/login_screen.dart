import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authActionsProvider)
          .signIn(_emailController.text.trim(), _passwordController.text);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('user-not-found') || msg.contains('no user')) {
      return 'No account found with this email';
    }
    if (msg.contains('wrong-password') || msg.contains('incorrect')) {
      return 'Incorrect password';
    }
    if (msg.contains('invalid-email')) {
      return 'Invalid email address';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Network error. Please check your connection';
    }
    return 'Login failed. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final fieldTextColor = isDarkTheme ? Colors.white : onSurface;
    final fieldHintColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.7)
        : onSurface.withValues(alpha: 0.7);
    final fieldFillColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.9);
    final fieldBorderColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFD6E2FF);

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child:
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.code,
                            color: Colors.white,
                            size: 48,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child:
                        ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                              ).createShader(bounds),
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.get('welcome_back') ??
                                    'Welcome Back!',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .animate(delay: 200.ms)
                            .fadeIn()
                            .slideY(begin: 0.3, end: 0),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.get('sign_in_to_continue') ??
                          'Sign in to continue learning',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ).animate(delay: 300.ms).fadeIn(),
                  ),

                  const SizedBox(height: 48),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: fieldTextColor),
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.get('email') ?? 'Email',
                      labelStyle: TextStyle(color: fieldHintColor),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: fieldHintColor,
                      ),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: fieldBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF0066FF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                              context,
                            )?.get('enter_email') ??
                            'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return AppLocalizations.of(
                              context,
                            )?.get('invalid_email') ??
                            'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: fieldTextColor),
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.get('password') ??
                          'Password',
                      labelStyle: TextStyle(color: fieldHintColor),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: fieldHintColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: fieldHintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: fieldBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF0066FF)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                              context,
                            )?.get('enter_password') ??
                            'Please enter a password';
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(
                              context,
                            )?.get('password_too_short') ??
                            'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        AppLocalizations.of(context)?.get('forgot_password') ??
                            'Forgot Password?',
                        style: const TextStyle(color: Color(0xFF0066FF)),
                      ),
                    ),
                  ).animate(delay: 600.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.get('sign_in') ??
                                      'Sign In',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // Temporary Debug: Skip Auth Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Skip auth for debug - create anonymous user
                        try {
                          await ref
                              .read(authActionsProvider)
                              .signInAnonymously();
                          if (mounted) {
                            context.go('/');
                          }
                        } catch (e) {
                          print('Error with skip auth: $e');
                          // Fallback - just navigate
                          context.go('/');
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
                  ).animate(delay: 750.ms).fadeIn(),

                  const SizedBox(height: 32),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)?.get('dont_have_account') ?? "Don't have an account?"} ",
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            AppLocalizations.of(context)?.get('sign_up') ??
                                'Sign Up',
                            style: const TextStyle(
                              color: Color(0xFF0066FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 800.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
