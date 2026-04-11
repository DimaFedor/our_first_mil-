import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/features/profile/models/learning_journey_models.dart';
import 'package:untitled/features/profile/services/learning_journey_portfolio_service.dart';

void main() {
  group('LearningJourneyPortfolioService', () {
    const userId = 'user-1';

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns empty entries when nothing saved', () async {
      final service = LearningJourneyPortfolioService();

      final entries = await service.loadEntries(userId);

      expect(entries, isEmpty);
    });

    test('adds and removes portfolio entries', () async {
      final service = LearningJourneyPortfolioService();
      final first = PortfolioEntry(
        id: '1',
        title: 'Loops practice',
        language: 'python',
        snippet: 'for i in range(3): print(i)',
        notes: 'Used range',
        hadErrors: false,
        errorTags: const [],
        createdAt: DateTime(2026, 1, 10),
      );
      final second = PortfolioEntry(
        id: '2',
        title: 'Array map',
        language: 'javascript',
        snippet: '[1,2,3].map(x => x * 2)',
        notes: 'Forgot return at first',
        hadErrors: true,
        errorTags: const ['map', 'syntax'],
        createdAt: DateTime(2026, 1, 11),
      );

      await service.addEntry(userId: userId, entry: first);
      await service.addEntry(userId: userId, entry: second);

      final afterAdd = await service.loadEntries(userId);
      expect(afterAdd.length, 2);
      expect(afterAdd.first.id, '2');

      await service.removeEntry(userId: userId, entryId: '2');

      final afterRemove = await service.loadEntries(userId);
      expect(afterRemove.length, 1);
      expect(afterRemove.first.id, '1');
    });

    test('persists onboarding completion flag', () async {
      final service = LearningJourneyPortfolioService();

      final before = await service.isOnboardingCompleted(userId);
      expect(before, isFalse);

      await service.setOnboardingCompleted(userId);

      final after = await service.isOnboardingCompleted(userId);
      expect(after, isTrue);
    });
  });
}
