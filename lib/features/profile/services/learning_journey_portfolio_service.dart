import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_journey_models.dart';

class LearningJourneyPortfolioService {
  static const _portfolioKeyPrefix = 'learning_journey_portfolio';
  static const _onboardingKeyPrefix = 'learning_journey_onboarding';

  Future<List<PortfolioEntry>> loadEntries(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_portfolioKey(userId));
    if (raw == null || raw.trim().isEmpty) {
      return const <PortfolioEntry>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <PortfolioEntry>[];
      }
      final entries = decoded
          .whereType<Map<String, dynamic>>()
          .map(PortfolioEntry.fromJson)
          .toList(growable: false);
      final sorted = [...entries]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted;
    } on FormatException {
      return const <PortfolioEntry>[];
    }
  }

  Future<void> addEntry({
    required String userId,
    required PortfolioEntry entry,
  }) async {
    final current = await loadEntries(userId);
    final updated = [entry, ...current];
    await saveEntries(userId, updated);
  }

  Future<void> removeEntry({
    required String userId,
    required String entryId,
  }) async {
    final current = await loadEntries(userId);
    final updated = current.where((entry) => entry.id != entryId).toList();
    await saveEntries(userId, updated);
  }

  Future<void> saveEntries(String userId, List<PortfolioEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(_portfolioKey(userId), raw);
  }

  Future<bool> isOnboardingCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey(userId)) ?? false;
  }

  Future<void> setOnboardingCompleted(
    String userId, {
    bool completed = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey(userId), completed);
  }

  String _portfolioKey(String userId) => '$_portfolioKeyPrefix:$userId';
  String _onboardingKey(String userId) => '$_onboardingKeyPrefix:$userId';
}
