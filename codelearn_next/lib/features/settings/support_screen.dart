import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});
  @override
  ConsumerState<SupportScreen> createState() => SupportScreenState();
}

class SupportScreenState extends ConsumerState<SupportScreen> {
  final message = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.support)),
    body: PageBody(
      maxWidth: 700,
      children: [
        Text(
          context.l10n.supportBody,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: message,
          maxLength: 4000,
          minLines: 8,
          maxLines: 16,
          decoration: InputDecoration(labelText: context.l10n.message),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  await runAction(
                    context,
                    () => ref
                        .read(dataProvider.notifier)
                        .perform(
                          (repository, account) =>
                              repository.submitSupport(account, message.text),
                        ),
                    success: context.l10n.queued,
                  );
                  if (mounted) setState(() => busy = false);
                },
          child: Text(context.l10n.send),
        ),
      ],
    ),
  );
}
