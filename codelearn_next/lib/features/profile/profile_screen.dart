import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../foundation/json.dart';
import '../journey/presentation/journey_screen.dart';
import '../progress/domain/achievement.dart';
import '../rewards/domain/reward_policy.dart';

const avatarColors = [
  Color(0xFF0A84FF),
  Color(0xFF30D158),
  Color(0xFFFF9F0A),
  Color(0xFFBF5AF2),
  Color(0xFF40C8E0),
  Color(0xFFFF453A),
  Color(0xFF5E5CE6),
  Color(0xFF63E6BE),
  Color(0xFFFF375F),
  Color(0xFF8E8E93),
];

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) {
      final l = context.l10n;
      final theme = Theme.of(context);
      final isGuest = ref.watch(accountProvider) == 'guest';
      final name = data.name.isEmpty ? l.guest : data.name;
      return PageBody(
        maxWidth: 760,
        children: [
          Row(
            children: [
              ProfileAvatar(
                name: name,
                colorIndex: jsonInt(data.profile['avatar'], 1),
                size: 76,
                hasFrame: data.wallet.hasFrame,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      [
                        isGuest
                            ? l.guestMode
                            : ref.watch(authUserProvider).value?.email ?? '',
                        '${l.level} ${RewardPolicy.level(data.xp)}',
                      ].where((part) => part.isNotEmpty).join('  ·  '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (jsonString(data.profile['bio']).isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(jsonString(data.profile['bio'])),
          ],
          const SizedBox(height: 12),
          GroupedSection(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l.editProfile),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => editProfile(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text(l.settings),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
          GroupedSection(
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
          GroupedSection(
            title:
                '${l.achievements}  ·  ${data.achievements.length} / ${achievementDefinitions.length}',
            children: [
              for (final id in data.achievements)
                ListTile(
                  leading: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFF9F0A),
                  ),
                  title: Text(achievementLabel(context, id)),
                ),
              if (achievementDefinitions
                      .where((item) => !data.achievements.contains(item.id))
                      .firstOrNull
                  case final next?)
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: Text(achievementLabel(context, next.id)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.go('/journey'),
                ),
            ],
          ),
          GroupedSection(
            title: isGuest ? l.signIn : l.sync,
            children: [
              ListTile(
                leading: Icon(
                  isGuest
                      ? Icons.phone_iphone_rounded
                      : data.pending == 0
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                ),
                title: Text(
                  isGuest
                      ? l.localBody
                      : data.pending == 0
                      ? l.synced
                      : l.syncPending,
                ),
              ),
              if (!isGuest)
                ListTile(
                  leading: const Icon(Icons.sync_rounded),
                  title: Text(l.sync),
                  onTap: () => runAction(context, () async {
                    await ref
                        .read(syncProvider)
                        .synchronize(ref.read(accountProvider));
                    await ref.read(dataProvider.notifier).reload();
                  }, success: l.synced),
                ),
              if (!isGuest)
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l.signOut,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => runAction(
                    context,
                    () => ref.read(authServiceProvider).signOut(),
                  ),
                ),
            ],
          ),
          if (isGuest) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/auth'),
                child: Text(l.signIn),
              ),
            ),
          ],
        ],
      );
    },
  );
}

class ProfileAvatar extends StatelessWidget {
  final String name;
  final int colorIndex;
  final double size;
  final bool hasFrame;
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.size = 48,
    this.hasFrame = false,
  });
  @override
  Widget build(BuildContext context) {
    final color = avatarColors[(colorIndex - 1) % avatarColors.length];
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.characters.first.toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(hasFrame ? 3 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasFrame
            ? Border.all(color: const Color(0xFFFF9F0A), width: 2.5)
            : null,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * .36,
            fontWeight: FontWeight.w600,
            color: color.computeLuminance() > .5
                ? const Color(0xFF1A1A18)
                : Colors.white,
          ),
        ),
      ),
    );
  }
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
                      avatarColors.length,
                      (index) => InkResponse(
                        onTap: () => setState(() => avatar = index + 1),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: avatar == index + 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: ProfileAvatar(
                            name: name.text.isEmpty
                                ? context.l10n.guest
                                : name.text,
                            colorIndex: index + 1,
                            size: 40,
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
