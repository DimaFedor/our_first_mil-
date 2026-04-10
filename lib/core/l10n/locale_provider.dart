import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_catalog.dart';

/// Language/Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final languageCatalogProvider = Provider<LanguageCatalog>((ref) {
  return const LanguageCatalog();
});

final availableLanguagesProvider = FutureProvider<List<LanguageOption>>((ref) async {
  final catalog = ref.watch(languageCatalogProvider);
  return catalog.loadLanguages();
});

final supportedLocalesProvider = FutureProvider<List<Locale>>((ref) async {
  final languages = await ref.watch(availableLanguagesProvider.future);
  return List<Locale>.unmodifiable(
    languages.map((language) => language.locale),
  );
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _localeKey = 'app_locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      state = localeFromLanguageTag(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeToLanguageTag(locale));
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(localeFromLanguageTag(languageCode));
  }
}
