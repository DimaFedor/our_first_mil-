import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseConfig.initialize();
  } catch (e) {
    // Firebase initialization will fail without proper config
    // This is fine for development - app will work without Firebase features
    debugPrint('Firebase initialization skipped: $e');
  }
  
  runApp(const ProviderScope(child: CodeBattleApp()));
}

class CodeBattleApp extends ConsumerWidget {
  const CodeBattleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'CodeLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
      
      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
