class SupportTicket {
  final String id;
  final String category;
  final String subject;
  final String message;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final String uiLanguageCode;
  final String? preferredLearningLanguage;
  final DateTime createdAt;
  final String status;
  final bool queuedLocally;
  final String? lastError;

  const SupportTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.message,
    required this.uiLanguageCode,
    required this.createdAt,
    this.userId,
    this.userEmail,
    this.userName,
    this.preferredLearningLanguage,
    this.status = 'open',
    this.queuedLocally = false,
    this.lastError,
  });

  SupportTicket copyWith({
    String? id,
    String? category,
    String? subject,
    String? message,
    String? userId,
    String? userEmail,
    String? userName,
    String? uiLanguageCode,
    String? preferredLearningLanguage,
    DateTime? createdAt,
    String? status,
    bool? queuedLocally,
    String? lastError,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      uiLanguageCode: uiLanguageCode ?? this.uiLanguageCode,
      preferredLearningLanguage:
          preferredLearningLanguage ?? this.preferredLearningLanguage,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      queuedLocally: queuedLocally ?? this.queuedLocally,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'subject': subject,
      'message': message,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'uiLanguageCode': uiLanguageCode,
      'preferredLearningLanguage': preferredLearningLanguage,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'queuedLocally': queuedLocally,
      'lastError': lastError,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      category: json['category'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      uiLanguageCode: json['uiLanguageCode'] as String? ?? 'en',
      preferredLearningLanguage: json['preferredLearningLanguage'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'open',
      queuedLocally: json['queuedLocally'] as bool? ?? false,
      lastError: json['lastError'] as String?,
    );
  }
}

class SupportTicketSubmissionResult {
  final String ticketId;
  final bool queuedLocally;
  final String message;

  const SupportTicketSubmissionResult({
    required this.ticketId,
    required this.queuedLocally,
    required this.message,
  });
}
