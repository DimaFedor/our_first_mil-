import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/local_auth_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/support_ticket.dart';
import '../providers/support_provider.dart';

class SupportScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialSubject;
  final String? initialMessage;

  const SupportScreen({
    super.key,
    this.initialCategory,
    this.initialSubject,
    this.initialMessage,
  });

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  static const Set<String> _supportedCategories = <String>{
    'technical',
    'account',
    'content',
    'feedback',
  };

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'technical';
  bool _isSubmitting = false;
  int _queuedTicketsCount = 0;
  String? _errorMessage;
  String? _successMessage;
  String? _infoMessage;

  bool get _isUkr => Localizations.localeOf(context).languageCode == 'uk';

  @override
  void initState() {
    super.initState();

    final initialCategory = widget.initialCategory?.trim().toLowerCase();
    if (initialCategory != null &&
        _supportedCategories.contains(initialCategory)) {
      _selectedCategory = initialCategory;
    }

    final initialSubject = widget.initialSubject?.trim();
    if (initialSubject != null && initialSubject.isNotEmpty) {
      _subjectController.text = initialSubject;
    }

    final initialMessage = widget.initialMessage?.trim();
    if (initialMessage != null && initialMessage.isNotEmpty) {
      _messageController.text = initialMessage;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshQueuedCount();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _refreshQueuedCount() async {
    final service = ref.read(supportTicketServiceProvider);
    final queued = await service.getQueuedTickets();
    if (!mounted) return;
    setState(() {
      _queuedTicketsCount = queued.length;
    });
  }

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final supportService = ref.read(supportTicketServiceProvider);
    final currentUser = ref.read(currentUserProvider);
    final currentUserUid = ref.read(currentUserUidProvider);
    final useLocalMode = ref.read(useLocalAuthProvider);
    final userData = currentUserUid == null
        ? null
        : ref.read(userDataProvider(currentUserUid)).valueOrNull;

    String? email;
    String? name;
    if (currentUser is User) {
      email = currentUser.email;
      name = currentUser.displayName;
    } else if (currentUser is LocalUser) {
      email = currentUser.email;
      name = currentUser.displayName;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
      _infoMessage = null;
    });

    final ticket = SupportTicket(
      id: supportService.createTicketId(),
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      userId: currentUserUid,
      userEmail: email,
      userName: name,
      uiLanguageCode: Localizations.localeOf(context).languageCode,
      preferredLearningLanguage: userData?.preferredLanguage,
      createdAt: DateTime.now(),
    );

    try {
      final result = await supportService.submitTicket(
        ticket: ticket,
        useLocalMode: useLocalMode,
      );
      await _refreshQueuedCount();
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        if (result.queuedLocally) {
          _infoMessage = _tr(
            en: 'Your request was saved locally and will remain available in queue.',
            uk: 'Запит збережено локально та залишиться в черзі до відправки.',
          );
        } else {
          _successMessage = _tr(
            en: 'Support request sent. We usually respond within 24 hours.',
            uk: 'Запит надіслано. Зазвичай відповідаємо протягом 24 годин.',
          );
        }
      });

      _subjectController.clear();
      _messageController.clear();
      _formKey.currentState?.reset();
      setState(() {
        _selectedCategory = 'technical';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  String _resolveErrorMessage(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('permission-denied')) {
      return _tr(
        en: 'Permission denied. Please re-login and try again.',
        uk: 'Немає доступу. Повторно увійди в акаунт і спробуй ще раз.',
      );
    }
    if (raw.contains('network')) {
      return _tr(
        en: 'Network problem. Check connection and retry.',
        uk: 'Проблема з мережею. Перевір підключення та спробуй ще раз.',
      );
    }
    return _tr(
      en: 'Unable to send request right now. Try again shortly.',
      uk: 'Наразі не вдалося відправити запит. Спробуй трохи пізніше.',
    );
  }

  String _tr({required String en, required String uk}) => _isUkr ? uk : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: onSurface),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tr(en: 'Support Service', uk: 'Служба підтримки'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _tr(
                    en: 'Need help with lessons, progress, or account access? We are here for you.',
                    uk: 'Потрібна допомога з уроками, прогресом або входом? Ми поруч.',
                  ),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.72),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeroCard(isDarkTheme: isDarkTheme, onSurface: onSurface),
                const SizedBox(height: 14),
                if (_queuedTicketsCount > 0) ...[
                  _buildInfoBanner(
                    icon: Icons.schedule_send_outlined,
                    color: Colors.amber,
                    text: _tr(
                      en: 'Queued support requests on this device: $_queuedTicketsCount',
                      uk: 'Запитів у локальній черзі на цьому пристрої: $_queuedTicketsCount',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_errorMessage != null) ...[
                  _buildInfoBanner(
                    icon: Icons.error_outline,
                    color: Colors.red,
                    text: _errorMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_infoMessage != null) ...[
                  _buildInfoBanner(
                    icon: Icons.cloud_off_outlined,
                    color: Colors.orange,
                    text: _infoMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_successMessage != null) ...[
                  _buildInfoBanner(
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    text: _successMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildSectionCard(
                  isDarkTheme: isDarkTheme,
                  child: _buildFaqSection(onSurface),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  isDarkTheme: isDarkTheme,
                  child: _buildContactForm(
                    onSurface: onSurface,
                    isDarkTheme: isDarkTheme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({required bool isDarkTheme, required Color onSurface}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.support_agent, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(en: 'Fast human support', uk: 'Швидка людська підтримка'),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.98),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tr(
                    en: 'Technical issues, lesson quality feedback, account recovery, and learning guidance.',
                    uk: 'Технічні проблеми, фідбек по уроках, відновлення акаунта та навчальні рекомендації.',
                  ),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.86),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(Color onSurface) {
    final entries = <_FaqEntry>[
      _FaqEntry(
        question: _tr(
          en: 'Why is my lesson progress not updating?',
          uk: 'Чому не оновлюється прогрес уроків?',
        ),
        answer: _tr(
          en: 'Check internet connection and reopen the lesson once. If issue persists, submit a ticket with course and lesson names.',
          uk: 'Перевір інтернет і повторно відкрий урок. Якщо проблема лишається — надішли звернення з назвою курсу та уроку.',
        ),
      ),
      _FaqEntry(
        question: _tr(
          en: 'Code challenge says output is wrong. What should I do?',
          uk: 'Челендж каже, що output неправильний. Що робити?',
        ),
        answer: _tr(
          en: 'Compare exact output formatting (spaces/new lines). Then verify expected result in challenge hint.',
          uk: 'Перевір точне форматування виводу (пробіли/нові рядки). Потім звір expected result у підказці челенджу.',
        ),
      ),
      _FaqEntry(
        question: _tr(
          en: 'Can I recover account access?',
          uk: 'Чи можна відновити доступ до акаунта?',
        ),
        answer: _tr(
          en: 'Yes. Choose category "Account" and include your login email plus issue details.',
          uk: 'Так. Обери категорію "Акаунт" та вкажи email входу і деталі проблеми.',
        ),
      ),
      _FaqEntry(
        question: _tr(
          en: 'How can I suggest lesson improvements?',
          uk: 'Як запропонувати покращення уроків?',
        ),
        answer: _tr(
          en: 'Choose category "Content quality" and describe what felt unclear. Add concrete lesson examples.',
          uk: 'Обери категорію "Якість контенту" та опиши, що саме було незрозуміло. Додай конкретні приклади уроків.',
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr(en: 'FAQ', uk: 'Часті запитання'),
          style: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            iconColor: const Color(0xFF2563EB),
            collapsedIconColor: onSurface.withValues(alpha: 0.7),
            title: Text(
              entry.question,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  entry.answer,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm({
    required Color onSurface,
    required bool isDarkTheme,
  }) {
    final categories = <String, String>{
      'technical': _tr(en: 'Technical issue', uk: 'Технічна проблема'),
      'account': _tr(en: 'Account', uk: 'Акаунт'),
      'content': _tr(en: 'Content quality', uk: 'Якість контенту'),
      'feedback': _tr(en: 'Product feedback', uk: 'Фідбек по продукту'),
    };

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(en: 'Contact support', uk: 'Звернення до підтримки'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedCategory),
            initialValue: _selectedCategory,
            items: categories.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
            decoration: _inputDecoration(
              isDarkTheme: isDarkTheme,
              label: _tr(en: 'Category', uk: 'Категорія'),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _subjectController,
            maxLength: 80,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.length < 4) {
                return _tr(
                  en: 'Subject must contain at least 4 characters.',
                  uk: 'Тема має містити щонайменше 4 символи.',
                );
              }
              return null;
            },
            decoration: _inputDecoration(
              isDarkTheme: isDarkTheme,
              label: _tr(en: 'Subject', uk: 'Тема'),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _messageController,
            maxLines: 6,
            minLines: 5,
            maxLength: 1200,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.length < 15) {
                return _tr(
                  en: 'Describe the issue in at least 15 characters so we can help faster.',
                  uk: 'Опиши проблему щонайменше 15 символами, щоб ми швидше допомогли.',
                );
              }
              return null;
            },
            decoration: _inputDecoration(
              isDarkTheme: isDarkTheme,
              label: _tr(en: 'Message', uk: 'Повідомлення'),
              hint: _tr(
                en: 'What happened, where, and what result did you expect? Add course/lesson name if relevant.',
                uk: 'Що сталося, де саме, і який результат очікувався? За потреби додай назву курсу/уроку.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSubmitting
                    ? _tr(en: 'Sending...', uk: 'Надсилаємо...')
                    : _tr(en: 'Send request', uk: 'Надіслати запит'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
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
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E2FF),
        ),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({
    required bool isDarkTheme,
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFC7D7FF),
        ),
      ),
      filled: true,
      fillColor: isDarkTheme
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.92),
    );
  }
}

class _FaqEntry {
  final String question;
  final String answer;

  const _FaqEntry({required this.question, required this.answer});
}
