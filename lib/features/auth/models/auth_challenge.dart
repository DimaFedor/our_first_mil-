class AuthChallenge {
  final String challengeId;
  final String title;
  final String language;
  final String snippet;
  final String question;
  final String hint;
  final DateTime expiresAt;
  final int maxAttempts;
  final int attemptsUsed;

  const AuthChallenge({
    required this.challengeId,
    required this.title,
    required this.language,
    required this.snippet,
    required this.question,
    required this.hint,
    required this.expiresAt,
    required this.maxAttempts,
    this.attemptsUsed = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get attemptsLeft => maxAttempts - attemptsUsed;

  AuthChallenge copyWith({
    String? challengeId,
    String? title,
    String? language,
    String? snippet,
    String? question,
    String? hint,
    DateTime? expiresAt,
    int? maxAttempts,
    int? attemptsUsed,
  }) {
    return AuthChallenge(
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      language: language ?? this.language,
      snippet: snippet ?? this.snippet,
      question: question ?? this.question,
      hint: hint ?? this.hint,
      expiresAt: expiresAt ?? this.expiresAt,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
    );
  }
}
