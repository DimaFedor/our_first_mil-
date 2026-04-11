class PortfolioEntry {
  final String id;
  final String title;
  final String language;
  final String snippet;
  final String notes;
  final bool hadErrors;
  final List<String> errorTags;
  final DateTime createdAt;

  const PortfolioEntry({
    required this.id,
    required this.title,
    required this.language,
    required this.snippet,
    required this.notes,
    required this.hadErrors,
    required this.errorTags,
    required this.createdAt,
  });

  factory PortfolioEntry.fromJson(Map<String, dynamic> json) {
    return PortfolioEntry(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      language: json['language']?.toString() ?? 'python',
      snippet: json['snippet']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      hadErrors: json['hadErrors'] == true,
      errorTags: (json['errorTags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .where((tag) => tag.trim().isNotEmpty)
          .toList(growable: false),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'language': language,
      'snippet': snippet,
      'notes': notes,
      'hadErrors': hadErrors,
      'errorTags': errorTags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class JourneyNodeSnapshot {
  final String courseId;
  final String title;
  final String icon;
  final int completedLessons;
  final int totalLessons;
  final int order;

  const JourneyNodeSnapshot({
    required this.courseId,
    required this.title,
    required this.icon,
    required this.completedLessons,
    required this.totalLessons,
    required this.order,
  });

  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  bool get isStarted => completedLessons > 0;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;
  bool get isWeakSpot => isStarted && !isCompleted && progress < 0.45;
}

class JourneyMission {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final bool isCompleted;

  const JourneyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.isCompleted,
  });
}

class JourneyInsight {
  final String title;
  final String description;

  const JourneyInsight({required this.title, required this.description});
}
