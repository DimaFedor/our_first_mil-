import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../foundation/json.dart';
import '../journey/presentation/journey_screen.dart';
import '../rewards/domain/reward_policy.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) {
      final l = context.l10n;
      final avatar = jsonInt(
        data.profile['avatar'],
        1,
      ).clamp(1, 10).toString().padLeft(2, '0');
      return PageBody(
        maxWidth: 900,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.wallet.hasFrame
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: AssetImage(
                    'assets/avatars/avatar_$avatar.png',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name.isEmpty ? l.guest : data.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      ref.watch(accountProvider) == 'guest'
                          ? l.guestMode
                          : ref.watch(authUserProvider).value?.email ?? '',
                    ),
                    Text('${l.level} ${RewardPolicy.level(data.xp)}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (jsonString(data.profile['bio']).isNotEmpty)
            Text(jsonString(data.profile['bio'])),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => editProfile(context, ref),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l.editProfile),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.tune_rounded),
                label: Text(l.settings),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.route_outlined),
                  title: Text(l.journey),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.go('/journey'),
                ),
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: Text(l.portfolio),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/portfolio'),
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: Text(l.support),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/support'),
                ),
              ],
            ),
          ),
          SectionHeading(l.achievements),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data.achievements
                .map(
                  (id) => Chip(
                    avatar: const Icon(Icons.workspace_premium_rounded),
                    label: Text(achievementLabel(context, id)),
                  ),
                )
                .toList(),
          ),
          SectionHeading(
            ref.watch(accountProvider) == 'guest' ? l.signIn : l.sync,
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watch(accountProvider) == 'guest'
                      ? l.localBody
                      : data.pending == 0
                      ? l.synced
                      : l.syncPending,
                ),
                const SizedBox(height: 16),
                if (ref.watch(accountProvider) == 'guest')
                  FilledButton(
                    onPressed: () => context.push('/auth'),
                    child: Text(l.signIn),
                  )
                else
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () => runAction(context, () async {
                          await ref
                              .read(syncProvider)
                              .synchronize(ref.read(accountProvider));
                          await ref.read(dataProvider.notifier).reload();
                        }, success: l.synced),
                        child: Text(l.sync),
                      ),
                      TextButton(
                        onPressed: () => runAction(
                          context,
                          () => ref.read(authServiceProvider).signOut(),
                        ),
                        child: Text(l.signOut),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Future<void> editProfile(BuildContext context, WidgetRef ref) async {
  final data = ref.read(dataProvider).value;
  if (data == null) return;
  final name = TextEditingController(text: data.name);
  final bio = TextEditingController(text: jsonString(data.profile['bio']));
  var avatar = jsonInt(data.profile['avatar'], 1);
  var focus = jsonString(data.profile['focus'], 'python');
  var dailyMinutes = jsonInt(
    data.profile['dailyMinutes'],
    20,
  ).clamp(5, 60).toDouble();
  try {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.editProfile),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      10,
                      (index) => InkResponse(
                        onTap: () => setState(() => avatar = index + 1),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 3,
                              color: avatar == index + 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/avatars/avatar_${(index + 1).toString().padLeft(2, '0')}.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: name,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: context.l10n.displayName,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bio,
                    maxLength: 250,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: context.l10n.bio),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: focus,
                    decoration: InputDecoration(
                      labelText: context.l10n.learningFocus,
                    ),
                    items:
                        [
                              'python',
                              'javascript',
                              'cplusplus',
                              'htmlcss',
                              'react',
                              'sql',
                              'git',
                              'cli-basics',
                            ]
                            .map(
                              (id) =>
                                  DropdownMenuItem(value: id, child: Text(id)),
                            )
                            .toList(),
                    onChanged: (value) => focus = value ?? focus,
                  ),
                  const SizedBox(height: 20),
                  Text('${context.l10n.dailyMinutes}: ${dailyMinutes.round()}'),
                  Slider(
                    value: dailyMinutes,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (value) => setState(() => dailyMinutes = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && context.mounted) {
      await runAction(
        context,
        () => ref
            .read(dataProvider.notifier)
            .perform(
              (repository, account) => repository.updateProfile(account, {
                'name': name.text.trim(),
                'bio': bio.text.trim(),
                'avatar': avatar,
                'focus': focus,
                'dailyMinutes': dailyMinutes.round(),
              }),
            ),
        success: context.l10n.saved,
      );
    }
  } finally {
    name.dispose();
    bio.dispose();
  }
}
