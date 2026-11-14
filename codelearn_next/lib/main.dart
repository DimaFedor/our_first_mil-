import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/codelearn_app.dart';
import 'app/providers.dart';
import 'features/auth/auth_service.dart';
import 'features/progress/data/learning_repository.dart';
import 'infrastructure/storage/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final database = await openLearningDatabase();
    final auth = const GuestAuthService();
    runApp(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(LearningRepository(database)),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: const CodeLearnApp(),
      ),
    );
  } on Exception catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: main,
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
