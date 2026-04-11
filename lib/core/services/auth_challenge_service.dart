import 'dart:math';

import '../../features/auth/models/auth_challenge.dart';
import 'auth_flow_exception.dart';

class AuthChallengeService {
  static const Duration _challengeTtl = Duration(minutes: 2);
  static const Duration _rateLimitWindow = Duration(minutes: 10);
  static const int _maxAttemptsPerChallenge = 3;
  static const int _maxChallengesPerWindow = 5;

  final Random _random = Random();
  final Map<String, _ChallengeSession> _activeChallengesByEmail = {};
  final Map<String, List<DateTime>> _issuedChallengesByEmail = {};

  AuthChallenge issueChallenge({required String email}) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AuthFlowException(
        code: 'invalid-email',
        message: 'Вкажіть валідний email для challenge-входу.',
      );
    }

    _cleanupRateLimitWindow(normalizedEmail);

    final active = _activeChallengesByEmail[normalizedEmail];
    if (active != null && !active.challenge.isExpired) {
      return active.challenge;
    }

    final issued = _issuedChallengesByEmail.putIfAbsent(
      normalizedEmail,
      () => <DateTime>[],
    );
    if (issued.length >= _maxChallengesPerWindow) {
      throw const AuthFlowException(
        code: 'challenge-rate-limited',
        message: 'Занадто багато challenge-спроб. Спробуйте трохи пізніше.',
      );
    }

    final template = _templates[_random.nextInt(_templates.length)];
    final challenge = AuthChallenge(
      challengeId:
          '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}',
      title: template.title,
      language: template.language,
      snippet: template.snippet,
      question: template.question,
      hint: template.hint,
      expiresAt: DateTime.now().add(_challengeTtl),
      maxAttempts: _maxAttemptsPerChallenge,
    );

    _activeChallengesByEmail[normalizedEmail] = _ChallengeSession(
      expectedAnswer: template.expectedAnswer,
      challenge: challenge,
    );
    issued.add(DateTime.now());

    return challenge;
  }

  AuthChallenge verifyAnswer({required String email, required String answer}) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedAnswer = answer.trim().toLowerCase();
    final session = _activeChallengesByEmail[normalizedEmail];

    if (session == null) {
      throw const AuthFlowException(
        code: 'challenge-not-found',
        message: 'Challenge не знайдено. Згенеруйте новий.',
      );
    }

    if (session.challenge.isExpired) {
      _activeChallengesByEmail.remove(normalizedEmail);
      throw const AuthFlowException(
        code: 'challenge-expired',
        message: 'Challenge застарів. Згенеруйте новий.',
      );
    }

    final attemptsUsed = session.challenge.attemptsUsed + 1;
    final updatedChallenge = session.challenge.copyWith(
      attemptsUsed: attemptsUsed,
    );
    _activeChallengesByEmail[normalizedEmail] = session.copyWith(
      challenge: updatedChallenge,
    );

    if (normalizedAnswer != session.expectedAnswer.trim().toLowerCase()) {
      if (updatedChallenge.attemptsLeft <= 0) {
        _activeChallengesByEmail.remove(normalizedEmail);
        throw const AuthFlowException(
          code: 'challenge-attempts-exceeded',
          message:
              'Ліміт спроб challenge вичерпано. Згенеруйте новий challenge.',
        );
      }

      throw AuthFlowException(
        code: 'challenge-wrong-answer',
        message:
            'Неправильна відповідь. Залишилось спроб: ${updatedChallenge.attemptsLeft}.',
      );
    }

    _activeChallengesByEmail.remove(normalizedEmail);
    return updatedChallenge;
  }

  void clearChallenge(String email) {
    _activeChallengesByEmail.remove(email.trim().toLowerCase());
  }

  void _cleanupRateLimitWindow(String normalizedEmail) {
    final cutoff = DateTime.now().subtract(_rateLimitWindow);
    final issued = _issuedChallengesByEmail[normalizedEmail];
    if (issued == null) return;

    issued.removeWhere((timestamp) => timestamp.isBefore(cutoff));
    if (issued.isEmpty) {
      _issuedChallengesByEmail.remove(normalizedEmail);
    }
  }
}

class _ChallengeSession {
  final String expectedAnswer;
  final AuthChallenge challenge;

  const _ChallengeSession({
    required this.expectedAnswer,
    required this.challenge,
  });

  _ChallengeSession copyWith({
    String? expectedAnswer,
    AuthChallenge? challenge,
  }) {
    return _ChallengeSession(
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      challenge: challenge ?? this.challenge,
    );
  }
}

class _ChallengeTemplate {
  final String title;
  final String language;
  final String snippet;
  final String question;
  final String hint;
  final String expectedAnswer;

  const _ChallengeTemplate({
    required this.title,
    required this.language,
    required this.snippet,
    required this.question,
    required this.hint,
    required this.expectedAnswer,
  });
}

const List<_ChallengeTemplate> _templates = [
  _ChallengeTemplate(
    title: 'Quick Python Check',
    language: 'Python',
    snippet: 'x = 3\nprint(x * 2 + 1)',
    question: 'Який результат виведе цей код?',
    hint: 'Спочатку множення, потім додавання.',
    expectedAnswer: '7',
  ),
  _ChallengeTemplate(
    title: 'JavaScript Warmup',
    language: 'JavaScript',
    snippet: 'const arr = [1, 2, 3];\nconsole.log(arr.length);',
    question: 'Що буде виведено в консоль?',
    hint: 'Зверни увагу на властивість масиву.',
    expectedAnswer: '3',
  ),
  _ChallengeTemplate(
    title: 'SQL Logic Sprint',
    language: 'SQL',
    snippet:
        'SELECT COUNT(*)\nFROM users\nWHERE email IS NOT NULL;\n-- rows: [A@email, NULL, B@email]',
    question: 'Яке число поверне запит?',
    hint: 'COUNT(*) рахує рядки після фільтра WHERE.',
    expectedAnswer: '2',
  ),
];
