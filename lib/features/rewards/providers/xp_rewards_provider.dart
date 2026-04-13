import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/xp_rewards_models.dart';
import '../services/xp_rewards_service.dart';

final xpRewardsServiceProvider = Provider<XPRewardsService>((ref) {
  return XPRewardsService();
});

final xpRewardsWalletProvider = FutureProvider<RewardWallet>((ref) async {
  final userId = ref.watch(currentUserUidProvider);
  if (userId == null) return const RewardWallet.initial();

  final useLocalMode = ref.watch(useLocalAuthProvider);
  final service = ref.watch(xpRewardsServiceProvider);
  return service.getWallet(userId: userId, useLocalMode: useLocalMode);
});

final xpRewardsTransactionsProvider = FutureProvider<List<RewardTransaction>>((
  ref,
) async {
  final userId = ref.watch(currentUserUidProvider);
  if (userId == null) return const <RewardTransaction>[];
  final service = ref.watch(xpRewardsServiceProvider);
  return service.getTransactions(userId: userId);
});
