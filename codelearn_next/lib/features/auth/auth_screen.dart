import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../foundation/json.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final link = TextEditingController();
  final answer = TextEditingController();
  final form = GlobalKey<FormState>();
  bool register = false;
  bool busy = false;
  bool showLink = false;
  bool showChallenge = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    link.dispose();
    answer.dispose();
    super.dispose();
  }

  Future<void> authenticate(Future<String?> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final account = await action();
      if (account != null) {
        await ref.read(repositoryProvider).mergeGuest(account);
        await ref.read(dataProvider.notifier).reload();
        if (mounted) context.go('/');
      } else if (mounted) {
        showMessage(context, context.l10n.emailSent);
      }
    } on Exception catch (failure) {
      if (mounted) {
        setState(
          () => error = failure is AppFailure
              ? failureMessage(context, failure)
              : context.l10n.authError,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final service = ref.watch(authServiceProvider);
    return Scaffold(
      appBar: AppBar(),
      body: PageBody(
        maxWidth: 520,
        children: [
          Text(
            register ? l.signUp : l.signIn,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(l.accountMerge),
          const SizedBox(height: 24),
          if (!service.available) Panel(child: Text(l.authUnavailable)),
          const SizedBox(height: 20),
          Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: l.email),
                  validator: (value) =>
                      value != null &&
                          RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(value.trim())
                      ? null
                      : l.invalidEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(labelText: l.password),
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : l.requiredField,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton(
            onPressed: busy || !service.available
                ? null
                : () {
                    if (!(form.currentState?.validate() ?? false)) return;
                    authenticate(
                      () async => (await service.signIn(
                        email.text,
                        password.text,
                        register: register,
                      )).user?.uid,
                    );
                  },
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(register ? l.signUp : l.signIn),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy || !service.available
                ? null
                : () => authenticate(
                    () async => (await service.google()).user?.uid,
                  ),
            icon: const Icon(Icons.account_circle_outlined),
            label: Text(l.google),
          ),
          TextButton(
            onPressed: () => setState(() => register = !register),
            child: Text(register ? l.signIn : l.signUp),
          ),
          TextButton(
            onPressed: busy || !service.available
                ? null
                : () => authenticate(() async {
                    await service.reset(email.text);
                    return null;
                  }),
            child: Text(l.resetPassword),
          ),
          ExpansionTile(
            title: Text(l.magicLink),
            children: [
              TextButton(
                onPressed: busy || !service.available
                    ? null
                    : () => authenticate(() async {
                        await service.sendLink(email.text);
                        return null;
                      }),
                child: Text(l.send),
              ),
              TextField(
                controller: link,
                decoration: InputDecoration(labelText: l.magicLink),
              ),
              FilledButton(
                onPressed: busy || !service.available
                    ? null
                    : () => authenticate(
                        () async => (await service.finishLink(
                          email.text,
                          link.text,
                        )).user?.uid,
                      ),
                child: Text(l.signIn),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(l.codeChallenge),
            children: [
              Text(l.challengePrompt),
              TextField(
                controller: answer,
                decoration: InputDecoration(labelText: l.challengeAnswer),
              ),
              TextButton(
                onPressed: () {
                  showMessage(
                    context,
                    answer.text.trim() == '7'
                        ? l.challengeSuccess
                        : l.incorrect,
                  );
                },
                child: Text(l.checkAnswer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
