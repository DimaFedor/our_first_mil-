import '../../../foundation/json.dart';
import '../../learning/domain/learning_session.dart';
import '../../rewards/domain/reward_policy.dart';

class Preferences {
  final String uiLocale;
  final String learningLocale;
  final String theme;
  final bool sound;
  final double volume;
  final bool haptics;
  final bool reminders;
  final bool onboarded;
  const Preferences({
    this.uiLocale = 'uk',
    this.learningLocale = 'uk',
    this.theme = 'dark',
    this.sound = true,
    this.volume = .35,
    this.haptics = true,
    this.reminders = false,
    this.onboarded = false,
  });
  factory Preferences.fromJson(JsonMap value) => Preferences(
    uiLocale: jsonString(value['uiLocale'], 'uk'),
    learningLocale: jsonString(value['learningLocale'], 'uk'),
    theme: jsonString(value['theme'], 'dark'),
    sound: value['sound'] != false,
    volume: (value['volume'] is num ? (value['volume'] as num).toDouble() : .35)
        .clamp(0, 1),
    haptics: value['haptics'] != false,
    reminders: jsonBool(value['reminders']),
    onboarded: jsonBool(value['onboarded']),
  );
  JsonMap toJson() => {
    'uiLocale': uiLocale,
    'learningLocale': learningLocale,
    'theme': theme,
    'sound': sound,
    'volume': volume,
    'haptics': haptics,
    'reminders': reminders,
    'onboarded': onboarded,
  };
}

class Completion {
  final String lessonId;
  final String courseId;
  final int xp;
  final DateTime at;
  Completion.fromJson(JsonMap value)
    : lessonId = jsonString(value['lessonId']),
      courseId = jsonString(value['courseId']),
      xp = jsonInt(value['xp']),
      at = jsonDate(value['at']) ?? DateTime.utc(1970);
}

class PortfolioEntry {
  final String id;
  final String title;
  final String language;
  final String code;
  final String notes;
  final List<String> errorTags;
  final DateTime at;
  PortfolioEntry.fromJson(JsonMap value)
    : id = jsonString(value['id']),
      title = jsonString(value['title']),
      language = jsonString(value['language']),
      code = jsonString(value['code']),
      notes = jsonString(value['notes']),
      errorTags = List.unmodifiable(
        jsonList(value['errorTags']).map((item) => jsonString(item)),
      ),
      at = jsonDate(value['at']) ?? DateTime.utc(1970);
  JsonMap toJson() => {
    'id': id,
    'title': title,
    'language': language,
    'code': code,
    'notes': notes,
    'errorTags': errorTags,
    'at': at.toIso8601String(),
  };
}

class LearningData {
  final JsonMap profile;
  final Preferences preferences;
  final Wallet wallet;
  final Map<String, Completion> completions;
  final Map<String, LearningSession> sessions;
  final List<PortfolioEntry> portfolio;
  final List<JsonMap> ledger;
  final List<JsonMap> attempts;
  final Set<String> achievements;
  final int pending;
  LearningData({
    required JsonMap profile,
    required this.preferences,
    required this.wallet,
    required Map<String, Completion> completions,
    required Map<String, LearningSession> sessions,
    required List<PortfolioEntry> portfolio,
    required List<JsonMap> ledger,
    required List<JsonMap> attempts,
    required Set<String> achievements,
    required this.pending,
  }) : profile = Map.unmodifiable(profile),
       completions = Map.unmodifiable(completions),
       sessions = Map.unmodifiable(sessions),
       portfolio = List.unmodifiable(portfolio),
       ledger = List.unmodifiable(
         ledger.map(Map<String, Object?>.unmodifiable),
       ),
       attempts = List.unmodifiable(
         attempts.map(Map<String, Object?>.unmodifiable),
       ),
       achievements = Set.unmodifiable(achievements);
  int get xp => jsonInt(profile['xp']);
  int get streak => jsonInt(profile['streak']);
  String get name => jsonString(profile['name']);
  int completedIn(String courseId) =>
      completions.values.where((item) => item.courseId == courseId).length;
}

class CompletionResult {
  final bool applied;
  final int xp;
  final int credits;
  final List<String> achievements;
  const CompletionResult({
    required this.applied,
    this.xp = 0,
    this.credits = 0,
    this.achievements = const [],
  });
}
