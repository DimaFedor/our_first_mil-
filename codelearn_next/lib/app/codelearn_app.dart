import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/components.dart';
import '../design_system/theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class CodeLearnApp extends ConsumerStatefulWidget {
  const CodeLearnApp({super.key});
  @override
  ConsumerState<CodeLearnApp> createState() => CodeLearnAppState();
}

class CodeLearnAppState extends ConsumerState<CodeLearnApp>
    with WidgetsBindingObserver {
  Timer? syncTimer;
  bool active = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    syncTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => synchronize(),
    );
    ref.listenManual(accountProvider, (previous, next) {
      if (next != 'guest') synchronize();
    });
  }

  Future<void> synchronize() async {
    if (!active || ref.read(accountProvider) == 'guest') return;
    try {
      await ref.read(syncProvider).synchronize(ref.read(accountProvider));
      if (mounted) await ref.read(dataProvider.notifier).reload();
    } on Exception catch (error) {
      debugPrint('Synchronization deferred: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    active = state == AppLifecycleState.resumed;
    if (active) {
      synchronize();
    } else {
      ref.read(feedbackProvider).stop();
    }
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final preferences = data.value?.preferences;
    return MaterialApp.router(
      title: 'CodeLearn',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (preferences?.theme) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      locale: Locale(preferences?.uiLocale ?? 'uk'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => data.hasError
          ? Scaffold(
              body: EmptyState(
                icon: Icons.storage_outlined,
                title: context.l10n.errorTitle,
                body: context.l10n.syncError,
                action: FilledButton(
                  onPressed: () => ref.invalidate(dataProvider),
                  child: Text(context.l10n.retry),
                ),
              ),
            )
          : data.isLoading && data.value == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : child!,
    );
  }
}
