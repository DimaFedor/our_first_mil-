import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../practice/presentation/practice_views.dart';
import '../../progress/domain/learning_data.dart';

final portfolioEntriesProvider =
    FutureProvider.family<List<PortfolioEntry>, int>((ref, limit) {
      ref.watch(dataProvider);
      return ref
          .watch(repositoryProvider)
          .portfolioPage(ref.watch(accountProvider), limit);
    });

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});
  @override
  ConsumerState<PortfolioScreen> createState() => PortfolioScreenState();
}

class PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  int limit = 50;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.portfolio),
      actions: [
        IconButton(
          onPressed: () => editSnippet(context, ref),
          tooltip: context.l10n.addSnippet,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
    body: AsyncContent(
      value: ref.watch(portfolioEntriesProvider(limit)),
      builder: (entries) => PageBody(
        maxWidth: 900,
        children: [
          if (entries.isEmpty)
            EmptyState(
              icon: Icons.code_rounded,
              title: context.l10n.portfolioEmpty,
              body: context.l10n.portfolioEmptyBody,
              action: FilledButton.icon(
                onPressed: () => editSnippet(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.addSnippet),
              ),
            ),
          for (final entry in entries) ...[
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            editSnippet(context, ref, entry: entry),
                        tooltip: context.l10n.editProfile,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () => deleteSnippet(context, ref, entry.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                  Text(
                    '${entry.language} · ${DateFormat.yMMMd(ref.watch(dataProvider).value?.preferences.uiLocale ?? 'uk').format(entry.at.toLocal())}',
                  ),
                  const SizedBox(height: 16),
                  CodePanel(code: entry.code, language: entry.language),
                  if (entry.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(entry.notes),
                    ),
                  if (entry.errorTags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: entry.errorTags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (entries.length == limit)
            Center(
              child: OutlinedButton(
                onPressed: () => setState(() => limit += 50),
                child: Text(context.l10n.loadMore),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<void> deleteSnippet(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final approved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.deleteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );
  if (approved == true && context.mounted) {
    await runAction(
      context,
      () => ref
          .read(dataProvider.notifier)
          .perform(
            (repository, account) => repository.deletePortfolio(account, id),
          ),
    );
  }
}

Future<void> editSnippet(
  BuildContext context,
  WidgetRef ref, {
  PortfolioEntry? entry,
}) async {
  final title = TextEditingController(text: entry?.title);
  final code = TextEditingController(text: entry?.code);
  final notes = TextEditingController(text: entry?.notes);
  final language = TextEditingController(text: entry?.language ?? 'python');
  final tags = TextEditingController(text: entry?.errorTags.join(', '));
  final form = GlobalKey<FormState>();
  try {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.addSnippet),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    decoration: InputDecoration(labelText: context.l10n.title),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: language,
                    decoration: InputDecoration(
                      labelText: context.l10n.learningFocus,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: code,
                      minLines: 6,
                      maxLines: 12,
                      style: const TextStyle(fontFamily: 'monospace'),
                      decoration: InputDecoration(labelText: context.l10n.code),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.requiredField
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: notes,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: context.l10n.notes),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: tags,
                    decoration: InputDecoration(
                      labelText: context.l10n.practiceAgain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      final value = PortfolioEntry.fromJson({
        'id': entry?.id ?? 'snippet:${DateTime.now().microsecondsSinceEpoch}',
        'title': title.text.trim(),
        'language': language.text.trim(),
        'code': code.text,
        'notes': notes.text.trim(),
        'errorTags': tags.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'at': (entry?.at ?? DateTime.now()).toUtc().toIso8601String(),
      });
      await runAction(
        context,
        () => ref
            .read(dataProvider.notifier)
            .perform(
              (repository, account) => repository.savePortfolio(account, value),
            ),
        success: context.l10n.saved,
      );
    }
  } finally {
    title.dispose();
    code.dispose();
    notes.dispose();
    language.dispose();
    tags.dispose();
  }
}
