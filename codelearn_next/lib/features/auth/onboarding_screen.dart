import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../design_system/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0;

  Future<void> finish() => runAction(
    context,
    () => ref
        .read(dataProvider.notifier)
        .perform(
          (repository, account) =>
              repository.updatePreferences({'onboarded': true}),
        ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.onboardingStep1, l.onboardingStep2, l.onboardingStep3];
    final bodies = [l.onboardingBody1, l.onboardingBody2, l.onboardingBody3];
    final icons = [
      Icons.auto_stories_rounded,
      Icons.terminal_rounded,
      Icons.local_fire_department_rounded,
    ];
    return Scaffold(
      body: SafeArea(
        child: PageBody(
          maxWidth: 780,
          children: [
            Row(
              children: [
                const Icon(Icons.code_rounded, color: brandMint),
                const SizedBox(width: 10),
                Text(l.appTitle, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: finish, child: Text(l.skip)),
              ],
            ),
            const SizedBox(height: 50),
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      brandBlue.withValues(alpha: .35),
                      brandMint.withValues(alpha: .12),
                    ],
                  ),
                ),
                child: Icon(
                  icons[step],
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 42),
            Text(
              titles[step],
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(bodies[step], style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Row(
              children: [
                for (var index = 0; index < 3; index++)
                  Container(
                    width: index == step ? 30 : 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.only(end: 7),
                    decoration: BoxDecoration(
                      color: index == step
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (step < 2) {
                    setState(() => step++);
                  } else {
                    finish();
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(step == 2 ? l.welcomeAction : l.next),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'uk', label: Text('Українська')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {
                  ref.watch(dataProvider).value?.preferences.uiLocale ?? 'uk',
                },
                onSelectionChanged: (selection) => runAction(
                  context,
                  () => ref
                      .read(dataProvider.notifier)
                      .perform(
                        (repository, account) => repository.updatePreferences({
                          'uiLocale': selection.first,
                          'learningLocale': selection.first,
                        }),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
