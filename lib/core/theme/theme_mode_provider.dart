import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
      return ThemeModeNotifier();
    });

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _themeModeExplicitKey = 'app_theme_mode_explicit';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final hasExplicitTheme = prefs.getBool(_themeModeExplicitKey) ?? false;
    if (!hasExplicitTheme) {
      state = ThemeMode.system;
      return;
    }

    final savedMode = prefs.getString(_themeModeKey);
    state = _themeModeFromStorage(savedMode);
  }

  Future<void> toggleThemeMode() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToStorage(mode));
    await prefs.setBool(_themeModeExplicitKey, true);
  }

  ThemeMode _themeModeFromStorage(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> clearThemePreference() async {
    state = ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
    await prefs.remove(_themeModeExplicitKey);
  }
}
