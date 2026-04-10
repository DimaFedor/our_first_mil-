import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RuntimeTranslationService {
  RuntimeTranslationService._();

  static const String _fallbackLanguageCode = 'en';
  static const int _maxChunkLength = 1800;

  static final Map<String, String> _textCache = <String, String>{};
  static final Map<String, Future<String>> _pendingTranslations =
      <String, Future<String>>{};
  static Future<void> _translationQueue = Future<void>.value();

  static Future<String> translateText({
    required String text,
    required String targetLanguageCode,
  }) async {
    final normalizedLanguageCode = _normalizeLanguageCode(targetLanguageCode);
    final trimmedText = text.trim();

    if (trimmedText.isEmpty ||
        normalizedLanguageCode == _fallbackLanguageCode) {
      return text;
    }

    final translatorCode = _toTranslatorLanguageCode(normalizedLanguageCode);
    if (translatorCode == null) {
      debugPrint(
        'Runtime translation is not configured for "$normalizedLanguageCode".',
      );
      return text;
    }

    final cacheKey = '$translatorCode|$text';
    final cached = _textCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final pending = _pendingTranslations[cacheKey];
    if (pending != null) {
      return pending;
    }

    final translationFuture = _enqueueTranslation(
      () => _translateInternal(
        sourceText: text,
        translatorLanguageCode: translatorCode,
        cacheKey: cacheKey,
      ),
    );

    _pendingTranslations[cacheKey] = translationFuture;
    try {
      return await translationFuture;
    } finally {
      _pendingTranslations.remove(cacheKey);
    }
  }

  static Future<String> _translateInternal({
    required String sourceText,
    required String translatorLanguageCode,
    required String cacheKey,
  }) async {
    final chunks = _splitTextForTranslation(sourceText);
    if (chunks.isEmpty) {
      _textCache[cacheKey] = sourceText;
      return sourceText;
    }

    final translatedChunks = <String>[];

    try {
      for (final chunk in chunks) {
        final translatedChunk = await _translateChunkWithGoogle(
          chunk: chunk,
          targetLanguageCode: translatorLanguageCode,
        );
        translatedChunks.add(translatedChunk);
      }

      final resolvedText = translatedChunks.join().trim().isEmpty
          ? sourceText
          : translatedChunks.join();
      _textCache[cacheKey] = resolvedText;
      return resolvedText;
    } catch (error) {
      debugPrint(
        'Runtime translation failed for "$translatorLanguageCode": $error',
      );
      return sourceText;
    }
  }

  static Future<String> _translateChunkWithGoogle({
    required String chunk,
    required String targetLanguageCode,
  }) async {
    final uri = Uri.https(
      'translate.googleapis.com',
      '/translate_a/single',
      <String, String>{
        'client': 'gtx',
        'sl': 'auto',
        'tl': targetLanguageCode,
        'dt': 't',
        'q': chunk,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw StateError(
        'Google translation API returned ${response.statusCode} for "$targetLanguageCode".',
      );
    }

    final decodedBody = jsonDecode(response.body);
    final translatedChunk = _extractTranslatedChunk(decodedBody);
    if (translatedChunk == null || translatedChunk.trim().isEmpty) {
      return chunk;
    }

    return translatedChunk;
  }

  static String? _extractTranslatedChunk(dynamic decodedBody) {
    if (decodedBody is! List || decodedBody.isEmpty) {
      return null;
    }

    final sentenceBlocks = decodedBody.first;
    if (sentenceBlocks is! List) {
      return null;
    }

    final translatedParts = <String>[];
    for (final sentence in sentenceBlocks) {
      if (sentence is List && sentence.isNotEmpty && sentence.first is String) {
        translatedParts.add(sentence.first as String);
      }
    }

    if (translatedParts.isEmpty) {
      return null;
    }
    return translatedParts.join();
  }

  static List<String> _splitTextForTranslation(String sourceText) {
    if (sourceText.length <= _maxChunkLength) {
      return <String>[sourceText];
    }

    final parts = <String>[];
    final paragraphs = sourceText.split('\n');
    var current = StringBuffer();

    for (final paragraph in paragraphs) {
      final candidate = current.isEmpty ? paragraph : '$current\n$paragraph';
      if (candidate.length <= _maxChunkLength) {
        current
          ..clear()
          ..write(candidate);
        continue;
      }

      if (current.isNotEmpty) {
        parts.add(current.toString());
        current.clear();
      }

      if (paragraph.length <= _maxChunkLength) {
        current.write(paragraph);
        continue;
      }

      var start = 0;
      while (start < paragraph.length) {
        final end = math.min(start + _maxChunkLength, paragraph.length);
        parts.add(paragraph.substring(start, end));
        start = end;
      }
    }

    if (current.isNotEmpty) {
      parts.add(current.toString());
    }

    return parts;
  }

  static Future<String> _enqueueTranslation(
    Future<String> Function() translationTask,
  ) {
    final completer = Completer<String>();

    _translationQueue = _translationQueue.then((_) async {
      try {
        completer.complete(await translationTask());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  static String _normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase().replaceAll('_', '-');
    if (normalized.isEmpty) {
      return _fallbackLanguageCode;
    }
    return normalized.split('-').first;
  }

  static String? _toTranslatorLanguageCode(String normalizedLanguageCode) {
    switch (normalizedLanguageCode) {
      case 'en':
      case 'uk':
      case 'es':
      case 'de':
      case 'fr':
      case 'pl':
      case 'it':
      case 'pt':
      case 'nl':
      case 'cs':
      case 'ro':
      case 'tr':
      case 'sv':
      case 'ja':
      case 'ko':
      case 'hi':
      case 'ar':
        return normalizedLanguageCode;
      case 'zh':
        return 'zh-cn';
      default:
        return null;
    }
  }
}
