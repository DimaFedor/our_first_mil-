import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  Locale get locale => localeFromLanguageTag(code);

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] as String?)?.trim();
    final name = (json['name'] as String?)?.trim();
    final nativeName = (json['nativeName'] as String?)?.trim();
    final flag = (json['flag'] as String?)?.trim();

    if (code == null || code.isEmpty) {
      throw const FormatException('Language code is missing in languages.json');
    }
    if (name == null || name.isEmpty) {
      throw FormatException('Language name is missing for "$code"');
    }
    if (nativeName == null || nativeName.isEmpty) {
      throw FormatException('Language nativeName is missing for "$code"');
    }
    if (flag == null || flag.isEmpty) {
      throw FormatException('Language flag is missing for "$code"');
    }

    return LanguageOption(
      code: code,
      name: name,
      nativeName: nativeName,
      flag: flag,
    );
  }
}

class LanguageCatalog {
  const LanguageCatalog();

  static const String _assetPath = 'assets/l10n/languages.json';

  static const List<LanguageOption> fallbackLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    LanguageOption(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', flag: '🇺🇦'),
    LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    LanguageOption(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    LanguageOption(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    LanguageOption(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    LanguageOption(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    LanguageOption(code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    LanguageOption(code: 'ro', name: 'Romanian', nativeName: 'Română', flag: '🇷🇴'),
    LanguageOption(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    LanguageOption(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    LanguageOption(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    LanguageOption(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    LanguageOption(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
  ];

  static final List<Locale> fallbackSupportedLocales =
      List<Locale>.unmodifiable(
    fallbackLanguages.map((language) => language.locale),
  );

  Future<List<LanguageOption>> loadLanguages() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        debugPrint('languages.json must be a JSON array.');
        return fallbackLanguages;
      }

      final languages = <LanguageOption>[];
      final seenCodes = <String>{};

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        try {
          final language = LanguageOption.fromJson(item);
          final codeKey = language.code.toLowerCase();
          if (seenCodes.add(codeKey)) {
            languages.add(language);
          }
        } on FormatException catch (error) {
          debugPrint('Skipping invalid language entry: $error');
        }
      }

      if (languages.isEmpty) {
        debugPrint('languages.json did not contain any valid language entries.');
        return fallbackLanguages;
      }

      return List<LanguageOption>.unmodifiable(languages);
    } on FlutterError catch (error) {
      debugPrint('Failed to load language registry asset: $error');
      return fallbackLanguages;
    } on FormatException catch (error) {
      debugPrint('Invalid language registry format: $error');
      return fallbackLanguages;
    }
  }
}

Locale localeFromLanguageTag(String languageTag) {
  final parts = languageTag
      .trim()
      .replaceAll('_', '-')
      .split('-')
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return const Locale('en');
  }

  final languageCode = parts.first.toLowerCase();
  String? scriptCode;
  String? countryCode;

  if (parts.length >= 2) {
    final secondPart = parts[1];
    if (secondPart.length == 4) {
      scriptCode = _normalizeScriptCode(secondPart);
    } else {
      countryCode = secondPart.toUpperCase();
    }
  }

  if (parts.length >= 3) {
    countryCode = parts[2].toUpperCase();
  }

  return Locale.fromSubtags(
    languageCode: languageCode,
    scriptCode: scriptCode,
    countryCode: countryCode,
  );
}

String localeToLanguageTag(Locale locale) {
  final segments = <String>[locale.languageCode.toLowerCase()];

  if (locale.scriptCode case final scriptCode?) {
    segments.add(_normalizeScriptCode(scriptCode));
  }

  if (locale.countryCode case final countryCode?) {
    segments.add(countryCode.toUpperCase());
  }

  return segments.join('-');
}

bool localeMatches(Locale first, Locale second) {
  return localeToLanguageTag(first).toLowerCase() ==
      localeToLanguageTag(second).toLowerCase();
}

Locale resolveSupportedLocale(
  Locale selectedLocale,
  List<Locale> supportedLocales,
) {
  if (supportedLocales.isEmpty) {
    return selectedLocale;
  }

  final selectedTag = localeToLanguageTag(selectedLocale).toLowerCase();
  for (final locale in supportedLocales) {
    if (localeToLanguageTag(locale).toLowerCase() == selectedTag) {
      return locale;
    }
  }

  for (final locale in supportedLocales) {
    if (locale.languageCode.toLowerCase() ==
        selectedLocale.languageCode.toLowerCase()) {
      return locale;
    }
  }

  return supportedLocales.first;
}

String _normalizeScriptCode(String scriptCode) {
  if (scriptCode.isEmpty) {
    return scriptCode;
  }

  return scriptCode[0].toUpperCase() + scriptCode.substring(1).toLowerCase();
}
