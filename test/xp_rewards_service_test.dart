import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/features/rewards/services/xp_rewards_service.dart';

void main() {
  group('XPRewardsService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('daily check-in is awarded once per day', () async {
      final service = XPRewardsService();

      final first = await service.claimDailyCheckIn(
        userId: 'user-1',
        useLocalMode: true,
        currentStreak: 3,
      );
      final second = await service.claimDailyCheckIn(
        userId: 'user-1',
        useLocalMode: true,
        currentStreak: 3,
      );
      final wallet = await service.getWallet(
        userId: 'user-1',
        useLocalMode: true,
      );

      expect(first.applied, isTrue);
      expect(first.creditsEarned, greaterThanOrEqualTo(20));
      expect(first.xpEarned, 15);
      expect(second.applied, isFalse);
      expect(wallet.creditsBalance, first.creditsEarned);
    });

    test('xp booster purchase is applied to next lesson completions', () async {
      final service = XPRewardsService();
      const userId = 'user-2';

      await service.claimDailyCheckIn(
        userId: userId,
        useLocalMode: true,
        currentStreak: 1,
      );
      await service.processLessonCompletion(
        userId: userId,
        useLocalMode: true,
        courseId: 'python',
        currentStreak: 1,
        baseLessonXp: 20,
        courseCompletedNow: false,
      );
      await service.processLessonCompletion(
        userId: userId,
        useLocalMode: true,
        courseId: 'python',
        currentStreak: 2,
        baseLessonXp: 20,
        courseCompletedNow: true,
      );

      final purchase = await service.purchaseItem(
        userId: userId,
        useLocalMode: true,
        itemId: 'xp_booster_pack',
      );
      final afterPurchase = await service.getWallet(
        userId: userId,
        useLocalMode: true,
      );

      final reward = await service.processLessonCompletion(
        userId: userId,
        useLocalMode: true,
        courseId: 'python',
        currentStreak: 3,
        baseLessonXp: 40,
        courseCompletedNow: false,
      );
      final afterBoostUse = await service.getWallet(
        userId: userId,
        useLocalMode: true,
      );

      expect(purchase.success, isTrue);
      expect(afterPurchase.xpBoostLessonsRemaining, 3);
      expect(reward.xpEarned, greaterThanOrEqualTo(10));
      expect(afterBoostUse.xpBoostLessonsRemaining, 2);
    });

    test('purchase fails when user has insufficient credits', () async {
      final service = XPRewardsService();

      final result = await service.purchaseItem(
        userId: 'user-3',
        useLocalMode: true,
        itemId: 'neon_profile_frame',
      );

      expect(result.success, isFalse);
      expect(result.message, 'Not enough credits.');
      expect(result.wallet.creditsBalance, 0);
    });
  });
}
