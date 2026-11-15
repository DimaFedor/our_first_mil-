import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../foundation/json.dart';
import '../../infrastructure/audio/feedback_service.dart';
import '../../infrastructure/notifications/reminder_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> update(BuildContext context, WidgetRef ref, JsonMap patch) =>
      runAction(
        context,
        () => ref
            .read(dataProvider.notifier)
            .perform(
              (repository, account) => repository.updatePreferences(patch),
            ),
      );
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.settings)),
    body: AsyncContent(
      value: ref.watch(dataProvider),
      builder: (data) {
        final l = context.l10n;
        final settings = data.preferences;
        return PageBody(
          maxWidth: 760,
          children: [
            GroupedSection(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate_rounded),
                  title: Text(l.uiLanguage),
                  trailing: DropdownButton<String>(
                    value: settings.uiLocale,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'uk', child: Text('Українська')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        update(context, ref, {'uiLocale': value});
                      }
                    },
                  ),
                ),
                AsyncContent(
                  value: ref.watch(languagesProvider),
                  builder: (languages) => ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(l.learningLanguage),
                    trailing: DropdownButton<String>(
                      value: settings.learningLocale,
                      underline: const SizedBox.shrink(),
                      items: languages
                          .map(
                            (language) => DropdownMenuItem(
                              value: language.code,
                              child: Text(language.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          update(context, ref, {'learningLocale': value});
                        }
                      },
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contrast_rounded),
                  title: Text(l.theme),
                  trailing: DropdownButton<String>(
                    value: settings.theme,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l.system)),
                      DropdownMenuItem(value: 'light', child: Text(l.light)),
                      DropdownMenuItem(value: 'dark', child: Text(l.dark)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        update(context, ref, {'theme': value});
                      }
                    },
                  ),
                ),
              ],
            ),
            GroupedSection(
              title: l.sound,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  value: settings.sound,
                  title: Text(l.sound),
                  onChanged: (value) => update(context, ref, {'sound': value}),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  value: settings.haptics,
                  title: Text(l.haptics),
                  onChanged: (value) =>
                      update(context, ref, {'haptics': value}),
                ),
                ListTile(
                  leading: const Icon(Icons.graphic_eq_rounded),
                  title: Text(l.volume),
                  subtitle: Slider(
                    value: settings.volume,
                    divisions: 10,
                    onChanged: (value) =>
                        update(context, ref, {'volume': value}),
                  ),
                  trailing: IconButton(
                    tooltip: l.previewSound,
                    onPressed: () => ref
                        .read(feedbackProvider)
                        .play(FeedbackCue.complete, settings),
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
                ),
              ],
            ),
            GroupedSection(
              title: l.reminders,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_none_rounded),
                  value: settings.reminders,
                  title: Text(l.reminders),
                  subtitle: Text(l.reminderBody),
                  onChanged: kIsWeb
                      ? null
                      : (enabled) => runAction(context, () async {
                          final allowed = await ReminderService().configure(
                            enabled,
                            l.appTitle,
                            l.continueLearning,
                          );
                          if (!allowed && enabled) {
                            throw const AppFailure('permissionDenied');
                          }
                          await ref
                              .read(dataProvider.notifier)
                              .perform(
                                (repository, account) => repository
                                    .updatePreferences({'reminders': enabled}),
                              );
                        }),
                ),
              ],
            ),
            GroupedSection(
              title: l.exportData,
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l.exportData),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => backupDialog(context, ref, false),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(l.importData),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => backupDialog(context, ref, true),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

Future<void> backupDialog(
  BuildContext context,
  WidgetRef ref,
  bool importing,
) async {
  final text = TextEditingController();
  if (!importing) {
    text.text = await ref
        .read(repositoryProvider)
        .exportData(ref.read(accountProvider));
  }
  if (!context.mounted) {
    text.dispose();
    return;
  }
  try {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          importing ? context.l10n.importData : context.l10n.exportData,
        ),
        content: SizedBox(
          width: 650,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                importing ? context.l10n.importHelp : context.l10n.exportHelp,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: text,
                readOnly: !importing,
                minLines: 6,
                maxLines: 14,
                decoration: const InputDecoration(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          if (importing)
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.importData),
            ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      await runAction(context, () async {
        final content = ref.read(contentProvider);
        final validLessons = <String, String>{};
        for (final course in await content.courses()) {
          for (final lesson in await content.lessons(course.id, 'en')) {
            validLessons[lesson.id] = course.id;
          }
        }
        await ref
            .read(repositoryProvider)
            .importData(ref.read(accountProvider), text.text, validLessons);
        await ref.read(dataProvider.notifier).reload();
      }, success: context.l10n.saved);
    }
  } finally {
    text.dispose();
  }
}
