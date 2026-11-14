import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../../infrastructure/audio/feedback_service.dart';
import '../domain/reward_policy.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => RewardsScreenState();
}

class RewardsScreenState extends ConsumerState<RewardsScreen> {
  bool busy = false;
  Future<void> transact(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    await runAction(context, action);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) {
      final l = context.l10n;
      final wallet = data.wallet;
      final labels = {
        'booster': (l.booster, l.boosterBody, Icons.bolt_rounded),
        'shield': (l.shield, l.shieldBody, Icons.shield_outlined),
        'hints': (l.hints, l.hintsBody, Icons.lightbulb_outline_rounded),
        'frame': (l.frame, l.frameBody, Icons.auto_awesome_rounded),
      };
      return PageBody(
        children: [
          Text(l.rewards, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.wallet),
                const SizedBox(height: 10),
                Text(
                  '${wallet.credits}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    StatPill(
                      Icons.bolt_rounded,
                      '${l.booster}: ${wallet.boosts}',
                    ),
                    StatPill(
                      Icons.shield_outlined,
                      '${l.shield}: ${wallet.shields}',
                    ),
                    StatPill(
                      Icons.lightbulb_outline_rounded,
                      '${l.hints}: ${wallet.hints}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard_rounded, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.dailyReward),
                          const Text('+15 XP · +20'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed:
                      busy ||
                          wallet.dailyClaim ==
                              RewardPolicy.dayKey(DateTime.now())
                      ? null
                      : () => transact(() async {
                          var applied = false;
                          await ref.read(dataProvider.notifier).perform((
                            repository,
                            account,
                          ) async {
                            applied = await repository.claimDaily(account);
                          });
                          if (applied) {
                            await ref
                                .read(feedbackProvider)
                                .play(FeedbackCue.reward, data.preferences);
                          }
                        }),
                  child: Text(
                    wallet.dailyClaim == RewardPolicy.dayKey(DateTime.now())
                        ? l.claimed
                        : l.claim,
                  ),
                ),
              ],
            ),
          ),
          SectionHeading(l.shop),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: shopItems.map((item) {
                final label = labels[item.id]!;
                return SizedBox(
                  width: constraints.maxWidth > 700
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth,
                  child: Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          label.$3,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          label.$1,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(label.$2),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              '${item.cost} ◈',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            FilledButton.tonal(
                              onPressed:
                                  busy || item.id == 'frame' && wallet.hasFrame
                                  ? null
                                  : () => transact(() async {
                                      await ref
                                          .read(dataProvider.notifier)
                                          .perform(
                                            (repository, account) => repository
                                                .purchase(account, item.id),
                                          );
                                      await ref
                                          .read(feedbackProvider)
                                          .play(
                                            FeedbackCue.reward,
                                            data.preferences,
                                          );
                                    }),
                              child: Text(
                                item.id == 'frame' && wallet.hasFrame
                                    ? l.owned
                                    : l.buy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SectionHeading(l.transactions),
          if (data.ledger.isEmpty) Text(l.noTransactions),
          for (final entry in data.ledger)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              leading: Icon(
                entry['type'] == 'daily'
                    ? Icons.card_giftcard_rounded
                    : entry['type'] == 'lesson'
                    ? Icons.school_outlined
                    : Icons.shopping_bag_outlined,
              ),
              title: Text(
                entry['type'] == 'daily'
                    ? l.dailyReward
                    : entry['type'] == 'lesson'
                    ? l.lessons
                    : labels[entry['type']]?.$1 ?? l.rewards,
              ),
              trailing: Text('${entry['credits']} ◈  ·  ${entry['xp']} XP'),
            ),
        ],
      );
    },
  );
}
