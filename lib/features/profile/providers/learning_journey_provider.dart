import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_journey_models.dart';
import '../services/learning_journey_portfolio_service.dart';

final learningJourneyPortfolioServiceProvider =
    Provider<LearningJourneyPortfolioService>((ref) {
      return LearningJourneyPortfolioService();
    });

final portfolioEntriesProvider =
    FutureProvider.family<List<PortfolioEntry>, String>((ref, userId) {
      final service = ref.watch(learningJourneyPortfolioServiceProvider);
      return service.loadEntries(userId);
    });

final learningJourneyOnboardingProvider = FutureProvider.family<bool, String>((
  ref,
  userId,
) {
  final service = ref.watch(learningJourneyPortfolioServiceProvider);
  return service.isOnboardingCompleted(userId);
});

final learningJourneyActionsProvider = Provider<LearningJourneyActions>((ref) {
  return LearningJourneyActions(
    ref,
    ref.watch(learningJourneyPortfolioServiceProvider),
  );
});

class LearningJourneyActions {
  final Ref _ref;
  final LearningJourneyPortfolioService _service;

  LearningJourneyActions(this._ref, this._service);

  Future<void> addPortfolioEntry({
    required String userId,
    required PortfolioEntry entry,
  }) async {
    await _service.addEntry(userId: userId, entry: entry);
    _ref.invalidate(portfolioEntriesProvider(userId));
  }

  Future<void> removePortfolioEntry({
    required String userId,
    required String entryId,
  }) async {
    await _service.removeEntry(userId: userId, entryId: entryId);
    _ref.invalidate(portfolioEntriesProvider(userId));
  }

  Future<void> completeOnboarding(String userId) async {
    await _service.setOnboardingCompleted(userId);
    _ref.invalidate(learningJourneyOnboardingProvider(userId));
  }
}
