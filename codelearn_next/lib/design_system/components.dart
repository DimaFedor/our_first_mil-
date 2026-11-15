import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../foundation/json.dart';
import '../l10n/generated/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  const PageBody({super.key, required this.children, this.maxWidth = 1120});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeading(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    ),
  );
}

class GroupedSection extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  const GroupedSection({
    super.key,
    this.title,
    this.trailing,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 28, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              ?trailing,
            ],
          ),
        )
      else
        const SizedBox(height: 16),
      Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTileTheme.merge(
          shape: const RoundedRectangleBorder(),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const Divider(indent: 66),
                children[index],
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}

class AsyncContent<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? retry;
  const AsyncContent({
    super.key,
    required this.value,
    required this.builder,
    this.retry,
  });
  @override
  Widget build(BuildContext context) => value.when(
    data: builder,
    loading: () => const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    ),
    error: (error, stack) => EmptyState(
      icon: Icons.cloud_off_rounded,
      title: context.l10n.errorTitle,
      body: context.l10n.syncError,
      action: retry == null
          ? null
          : FilledButton(onPressed: retry, child: Text(context.l10n.retry)),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

class StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const StatPill(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

String failureMessage(BuildContext context, Object error) {
  if (error is AppFailure) {
    return switch (error.code) {
      'insufficientCredits' => context.l10n.insufficientCredits,
      'hintEmpty' => context.l10n.hintEmpty,
      'owned' => context.l10n.owned,
      'requiredField' => context.l10n.requiredField,
      'authUnavailable' => context.l10n.authUnavailable,
      'importFailed' => context.l10n.importFailed,
      'quizRequired' => context.l10n.quizRequired,
      _ => context.l10n.errorTitle,
    };
  }
  return context.l10n.errorTitle;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

Future<void> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) showMessage(context, success);
  } on Exception catch (error) {
    if (context.mounted) showMessage(context, failureMessage(context, error));
  }
}
