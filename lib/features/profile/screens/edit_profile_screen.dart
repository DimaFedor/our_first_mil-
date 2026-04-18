import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_flow_exception.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../constants/avatar_presets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isSaving = false;
  bool _isHydrated = false;
  String? _errorMessage;
  String _skillLevel = 'beginner';
  String _preferredLanguage = 'python';
  double _dailyGoalMinutes = 20;
  String? _photoUrl;

  static const _skillLevelLabels = <String, String>{
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  static const _languageLabels = <String, String>{
    'python': 'Python',
    'javascript': 'JavaScript',
    'cplusplus': 'C++',
    'sql': 'SQL',
    'dart': 'Dart',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _hydrateForm(UserModel? userData, dynamic currentUser) {
    if (_isHydrated) return;
    _nameController.text =
        userData?.displayName ?? currentUser?.displayName?.toString() ?? 'User';
    _emailController.text =
        userData?.email ?? currentUser?.email?.toString() ?? '';
    _bioController.text = userData?.bio ?? '';
    _skillLevel = userData?.skillLevel ?? 'beginner';
    _preferredLanguage = userData?.preferredLanguage ?? 'python';
    _dailyGoalMinutes = (userData?.dailyGoalMinutes ?? 20).toDouble();
    _photoUrl = userData?.photoURL ?? currentUser?.photoURL?.toString();
    _isHydrated = true;
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authActionsProvider)
          .updateProfile(
            displayName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            skillLevel: _skillLevel,
            preferredLanguage: _preferredLanguage,
            photoURL: (_photoUrl?.trim().isEmpty ?? true)
                ? null
                : _photoUrl!.trim(),
            bio: _bioController.text.trim(),
            dailyGoalMinutes: _dailyGoalMinutes.round(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  String _resolveErrorMessage(dynamic error) {
    if (error is AuthFlowException) {
      return error.message;
    }
    final raw = error.toString().toLowerCase();
    if (raw.contains('requires-recent-login')) {
      return 'Для зміни email потрібно повторно увійти в акаунт.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'Цей email вже використовується.';
    }
    if (raw.contains('invalid-email')) {
      return 'Невалідний email.';
    }
    return 'Не вдалося зберегти профіль. Спробуйте ще раз.';
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 82,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty || !mounted) return;
      const maxAvatarBytes = 350 * 1024;
      if (bytes.length > maxAvatarBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Фото завелике. Оберіть зображення до 350KB або менший розмір.',
            ),
          ),
        );
        return;
      }

      final mimeType = _inferMimeType(picked.name);
      setState(() {
        _photoUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не вдалося вибрати фото. Спробуйте ще раз.'),
        ),
      );
    }
  }

  String _inferMimeType(String fileName) {
    final normalized = fileName.trim().toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserUidProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userDataAsync = uid == null
        ? const AsyncValue<UserModel?>.data(null)
        : ref.watch(userDataProvider(uid));
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
          child: userDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text(
                'Не вдалося завантажити профіль',
                style: TextStyle(color: onSurface),
              ),
            ),
            data: (userData) {
              _hydrateForm(userData, currentUser);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(Icons.arrow_back, color: onSurface),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.get('edit_profile') ?? 'Edit profile',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildPreviewCard(),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        isDarkTheme: isDarkTheme,
                        child: _buildAvatarPicker(
                          isDarkTheme: isDarkTheme,
                          onSurface: onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildSectionCard(
                        isDarkTheme: isDarkTheme,
                        child: Column(
                          children: [
                            _buildInput(
                              controller: _nameController,
                              label: 'Display name',
                              icon: Icons.person_outline,
                              onSurface: onSurface,
                              isDarkTheme: isDarkTheme,
                              validator: (value) {
                                if (value == null || value.trim().length < 2) {
                                  return 'Вкажіть імʼя (мінімум 2 символи).';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildInput(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              onSurface: onSurface,
                              isDarkTheme: isDarkTheme,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Вкажіть валідний email.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildInput(
                              controller: _bioController,
                              label: 'Bio',
                              icon: Icons.auto_awesome_outlined,
                              maxLines: 3,
                              onSurface: onSurface,
                              isDarkTheme: isDarkTheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        isDarkTheme: isDarkTheme,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skill level',
                              style: TextStyle(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _skillLevelLabels.entries.map((entry) {
                                return _buildChoiceChip(
                                  label: entry.value,
                                  selected: _skillLevel == entry.key,
                                  onTap: () {
                                    setState(() => _skillLevel = entry.key);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Preferred language',
                              style: TextStyle(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _languageLabels.entries.map((entry) {
                                return _buildChoiceChip(
                                  label: entry.value,
                                  selected: _preferredLanguage == entry.key,
                                  onTap: () {
                                    setState(
                                      () => _preferredLanguage = entry.key,
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Daily goal: ${_dailyGoalMinutes.round()} min',
                              style: TextStyle(
                                color: onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Slider(
                              value: _dailyGoalMinutes,
                              min: 10,
                              max: 120,
                              divisions: 22,
                              label: '${_dailyGoalMinutes.round()} min',
                              onChanged: (value) {
                                setState(() => _dailyGoalMinutes = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
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
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Save changes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker({
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    final selectedPhoto = _photoUrl?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avatar',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Оберіть готовий аватар або завантажте власне фото.',
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickPhotoFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Завантажити фото'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presetAvatarPaths.map((avatarPath) {
            final isSelected = selectedPhoto == avatarPath;
            return GestureDetector(
              onTap: () => setState(() => _photoUrl = avatarPath),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0066FF)
                        : (isDarkTheme
                              ? Colors.white.withValues(alpha: 0.25)
                              : const Color(0xFFD6E2FF)),
                    width: isSelected ? 2.5 : 1.2,
                  ),
                ),
                child: UserAvatar(
                  photoUrl: avatarPath,
                  fallbackText: 'A',
                  size: 54,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final name = _nameController.text.trim().isEmpty
        ? 'User'
        : _nameController.text.trim();
    final email = _emailController.text.trim();
    final level = _skillLevelLabels[_skillLevel] ?? 'Beginner';
    final language = _languageLabels[_preferredLanguage] ?? 'Python';
    final initial = name.substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: UserAvatar(
              photoUrl: _photoUrl,
              fallbackText: initial,
              size: 56,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$level · $language · ${_dailyGoalMinutes.round()} min/day',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required bool isDarkTheme, required Widget child}) {
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

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkTheme,
    required Color onSurface,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: onSurface.withValues(alpha: 0.7)),
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
                ? Colors.white.withValues(alpha: 0.1)
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

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF8B5CF6)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFFB7C8FF).withValues(alpha: 0.75),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF35548A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
