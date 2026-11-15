import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../../foundation/json.dart';
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
      final theme = Theme.of(context);
      final wallet = data.wallet;
      final isClaimed =
          wallet.dailyClaim == RewardPolicy.dayKey(DateTime.now());
      final labels = {
        'booster': (l.booster, l.boosterBody, Icons.bolt_rounded),
        'shield': (l.shield, l.shieldBody, Icons.shield_outlined),
        'hints': (l.hints, l.hintsBody, Icons.lightbulb_outline_rounded),
        'frame': (l.frame, l.frameBody, Icons.auto_awesome_rounded),
      };
      return PageBody(
        maxWidth: 760,
        children: [
          Text(l.wallet, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${wallet.credits}',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 48),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.toll_rounded,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              '${l.booster} ${wallet.boosts}',
              '${l.shield} ${wallet.shields}',
              '${l.hints} ${wallet.hints}',
            ].join('  ·  '),
            style: theme.textTheme.bodySmall,
          ),
          GroupedSection(
            title: l.dailyReward,
            children: [
              ListTile(
                leading: const Icon(Icons.card_giftcard_rounded),
                title: const Text('+15 XP'),
                subtitle: CreditAmount(20, prefix: '+'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy || isClaimed
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
              child: Text(isClaimed ? l.claimed : l.claim),
            ),
          ),
          GroupedSection(
            title: l.shop,
            children: [
              for (final item in shopItems)
                ListTile(
                  leading: Icon(labels[item.id]!.$3),
                  title: Text(labels[item.id]!.$1),
                  subtitle: Text(labels[item.id]!.$2),
                  trailing: FilledButton.tonal(
                    onPressed: busy || item.id == 'frame' && wallet.hasFrame
                        ? null
                        : () => transact(() async {
                            await ref
                                .read(dataProvider.notifier)
                                .perform(
                                  (repository, account) =>
                                      repository.purchase(account, item.id),
                                );
                            await ref
                                .read(feedbackProvider)
                                .play(FeedbackCue.purchase, data.preferences);
                          }),
                    child: item.id == 'frame' && wallet.hasFrame
                        ? Text(l.owned)
                        : CreditAmount(item.cost),
                  ),
                ),
            ],
          ),
          GroupedSection(
            title: l.transactions,
            children: [
              if (data.ledger.isEmpty) ListTile(title: Text(l.noTransactions)),
              for (final entry in data.ledger)
                ListTile(
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
                  subtitle: Text('${entry['xp']} XP'),
                  trailing: CreditAmount(
                    jsonInt(entry['credits']),
                    prefix: jsonInt(entry['credits']) > 0 ? '+' : '',
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}

class CreditAmount extends StatelessWidget {
  final int amount;
  final String prefix;
  const CreditAmount(this.amount, {super.key, this.prefix = ''});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$prefix$amount'),
      const SizedBox(width: 4),
      const Icon(Icons.toll_rounded, size: 16),
    ],
  );
}
