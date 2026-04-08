import 'package:flutter/foundation.dart';

/// Simple logger that only prints in debug mode
class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('📘 [DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('📗 [INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('📙 [WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('📕 [ERROR] $message');
      if (error != null) {
        debugPrint('   └─ $error');
      }
      if (stackTrace != null) {
        debugPrint('   └─ $stackTrace');
      }
    }
    // In production, could send to crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }
}
