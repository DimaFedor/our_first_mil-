import 'package:codelearn_next/app/providers.dart';
import 'package:codelearn_next/features/playground/playground_screen.dart';
import 'package:codelearn_next/features/progress/data/learning_repository.dart';
import 'package:codelearn_next/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  testWidgets('workspace restores both files and input after reopening', (
    tester,
  ) async {
    final database = await databaseFactoryMemory.openDatabase(
      'playground-test',
    );
    final repository = LearningRepository(database);
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repository)],
    );
    Widget app() => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: PlaygroundScreen()),
      ),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final editor = find.byKey(const ValueKey('code-editor'));
    await tester.enterText(editor, 'print("my draft")');
    await tester.tap(find.text('main.js'));
    await tester.pumpAndSettle();
    await tester.enterText(editor, 'console.log("another draft");');
    await tester.enterText(
      find.widgetWithText(TextField, 'Вхідні дані'),
      'Ada',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('console.log("another draft");'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    await tester.tap(find.text('main.py'));
    await tester.pumpAndSettle();
    expect(find.text('print("my draft")'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    container.dispose();
    await database.close();
  });
}
