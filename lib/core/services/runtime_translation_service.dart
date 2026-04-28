import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RuntimeTranslationService {
  RuntimeTranslationService._();

  static const String _fallbackLanguageCode = 'en';
  static const int _maxChunkLength = 1800;
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxTranslationAttempts = 7;
  static const Duration _minRetryDelay = Duration(milliseconds: 800);
  static const Duration _betweenSuccessfulRequestsDelay = Duration(
    milliseconds: 120,
  );
  static const String _batchSeparator = '<<<COPILOT_TRANSLATION_SPLIT>>>';
  static const List<String> _protectedProgrammingTerms = <String>[
    'console.log',
    '__init__',
    'print',
    'input',
    'self',
    'init',
    'len',
    'append',
    'dict',
    'tuple',
    'int',
    'float',
    'str',
    'bool',
    'None',
    'True',
    'False',
    'null',
    'undefined',
    'printf',
    'scanf',
    'cout',
    'cin',
    'println',
  ];
  static final RegExp _fencedCodePattern = RegExp(
    r'```[\s\S]*?```',
    multiLine: true,
  );
  static final RegExp _inlineCodePattern = RegExp(r'`[^`\n]+`');
  static final RegExp _functionCallPattern = RegExp(
    r'(?<![A-Za-z0-9_])[A-Za-z_][A-Za-z0-9_]*\(\)',
  );

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
    ).timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint(
          'Translation timed out for "$normalizedLanguageCode". Using source text.',
        );
        return text;
      },
    );

    _pendingTranslations[cacheKey] = translationFuture;
    try {
      return await translationFuture;
    } catch (e) {
      debugPrint('Translation error for "$normalizedLanguageCode": $e');
      return text;
    } finally {
      _pendingTranslations.remove(cacheKey);
    }
  }

  static Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLanguageCode,
  }) async {
    if (texts.isEmpty) {
      return const <String>[];
    }

    final normalizedLanguageCode = _normalizeLanguageCode(targetLanguageCode);
    if (normalizedLanguageCode == _fallbackLanguageCode) {
      return List<String>.unmodifiable(texts);
    }

    final translatorCode = _toTranslatorLanguageCode(normalizedLanguageCode);
    if (translatorCode == null) {
      return List<String>.unmodifiable(texts);
    }

    final translated = List<String>.from(texts);
    final missingIndexes = <int>[];
    final missingTexts = <String>[];

    for (var index = 0; index < texts.length; index++) {
      final sourceText = texts[index];
      if (sourceText.trim().isEmpty) {
        continue;
      }

      final cacheKey = '$translatorCode|$sourceText';
      final cached = _textCache[cacheKey];
      if (cached != null) {
        translated[index] = cached;
        continue;
      }

      missingIndexes.add(index);
      missingTexts.add(sourceText);
    }

    if (missingTexts.isNotEmpty) {
      try {
        final translatedMissing = await _enqueueTranslation(
          () => _translateBatchInternal(
            sourceTexts: missingTexts,
            translatorLanguageCode: translatorCode,
          ),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint(
              'Batch translation timed out for "$targetLanguageCode". Using source texts.',
            );
            return missingTexts;
          },
        );

        for (var index = 0; index < missingIndexes.length; index++) {
          final sourceIndex = missingIndexes[index];
          final translatedText = translatedMissing[index];
          translated[sourceIndex] = translatedText;
          _textCache['$translatorCode|${texts[sourceIndex]}'] = translatedText;
        }
      } catch (e) {
        debugPrint(
          'Batch translation failed for "$targetLanguageCode": $e. Using source texts.',
        );
      }
    }

    return List<String>.unmodifiable(translated);
  }

  static Future<List<String>> _translateBatchInternal({
    required List<String> sourceTexts,
    required String translatorLanguageCode,
  }) async {
    if (sourceTexts.isEmpty) {
      return const <String>[];
    }

    final protectedTexts = sourceTexts
        .map(_protectText)
        .toList(growable: false);
    final joinedSource = protectedTexts
        .map((entry) => entry.text)
        .join(_batchSeparator);

    try {
      final translatedJoined = await _translateChunkWithGoogle(
        chunk: joinedSource,
        targetLanguageCode: translatorLanguageCode,
      );
      final translatedParts = translatedJoined.split(_batchSeparator);
      if (translatedParts.length == sourceTexts.length) {
        return List<String>.generate(sourceTexts.length, (index) {
          final restored = _restoreProtectedTokens(
            text: translatedParts[index],
            placeholders: protectedTexts[index].placeholders,
          );
          return restored.trim().isEmpty ? sourceTexts[index] : restored;
        }, growable: false);
      }
    } catch (_) {
      // Fall back to single-string translation path below.
    }

    final fallbackResults = <String>[];
    for (final sourceText in sourceTexts) {
      fallbackResults.add(
        await _translateInternal(
          sourceText: sourceText,
          translatorLanguageCode: translatorLanguageCode,
          cacheKey: '$translatorLanguageCode|$sourceText',
        ),
      );
    }
    return List<String>.unmodifiable(fallbackResults);
  }

  static Future<String> _translateInternal({
    required String sourceText,
    required String translatorLanguageCode,
    required String cacheKey,
  }) async {
    final protectedSource = _protectText(sourceText);
    final chunks = _splitTextForTranslation(protectedSource.text);
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

      final translatedText = translatedChunks.join();
      final resolvedText = translatedText.trim().isEmpty
          ? sourceText
          : _restoreProtectedTokens(
              text: translatedText,
              placeholders: protectedSource.placeholders,
            );
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
      },
    );

    for (var attempt = 0; attempt < _maxTranslationAttempts; attempt++) {
      try {
        final response = await http
            .post(
              uri,
              headers: const <String, String>{
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: <String, String>{'q': chunk},
            )
            .timeout(_requestTimeout);

        if (response.statusCode == 429) {
          await Future<void>.delayed(_retryDelayForAttempt(attempt));
          continue;
        }

        if (response.statusCode != 200) {
          throw StateError(
            'Google translation API returned ${response.statusCode} for "$targetLanguageCode".',
          );
        }

        final decodedBody = jsonDecode(response.body);
        final translatedChunk = _extractTranslatedChunk(decodedBody);
        await Future<void>.delayed(_betweenSuccessfulRequestsDelay);
        if (translatedChunk == null || translatedChunk.trim().isEmpty) {
          return chunk;
        }

        return translatedChunk;
      } on TimeoutException {
        if (attempt == _maxTranslationAttempts - 1) {
          rethrow;
        }
        await Future<void>.delayed(_retryDelayForAttempt(attempt));
      } on http.ClientException {
        if (attempt == _maxTranslationAttempts - 1) {
          rethrow;
        }
        await Future<void>.delayed(_retryDelayForAttempt(attempt));
      }
    }

    throw StateError(
      'Google translation API rate limit persisted for "$targetLanguageCode".',
    );
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

  static Future<T> _enqueueTranslation<T>(
    Future<T> Function() translationTask,
  ) {
    final completer = Completer<T>();

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

  static Duration _retryDelayForAttempt(int attempt) {
    final cappedExponent = math.min(attempt, 6);
    final baseSeconds = math.pow(2, cappedExponent).toInt();
    final jitterMilliseconds = (math.Random().nextDouble() * 1000).round();
    final duration = Duration(
      seconds: baseSeconds,
      milliseconds: jitterMilliseconds,
    );
    if (duration < _minRetryDelay) {
      return _minRetryDelay;
    }
    return duration;
  }

  static _ProtectedText _protectText(String sourceText) {
    if (sourceText.trim().isEmpty) {
      return const _ProtectedText(text: '', placeholders: <String, String>{});
    }

    var protectedText = sourceText;
    final placeholders = <String, String>{};
    var placeholderIndex = 0;

    String reservePlaceholder(String value) {
      final placeholder = '__COPILOT_KEEP_${placeholderIndex++}__';
      placeholders[placeholder] = value;
      return placeholder;
    }

    String protectWithPattern(String input, RegExp pattern) {
      return input.replaceAllMapped(
        pattern,
        (match) => reservePlaceholder(match.group(0)!),
      );
    }

    protectedText = protectWithPattern(protectedText, _fencedCodePattern);
    protectedText = protectWithPattern(protectedText, _inlineCodePattern);
    protectedText = protectWithPattern(protectedText, _functionCallPattern);

    for (final term in _protectedProgrammingTerms) {
      final termPattern = RegExp(
        '(?<![A-Za-z0-9_])${RegExp.escape(term)}(?![A-Za-z0-9_])',
      );
      protectedText = protectWithPattern(protectedText, termPattern);
    }

    return _ProtectedText(
      text: protectedText,
      placeholders: Map<String, String>.unmodifiable(placeholders),
    );
  }

  static String _restoreProtectedTokens({
    required String text,
    required Map<String, String> placeholders,
  }) {
    if (placeholders.isEmpty || text.isEmpty) {
      return text;
    }

    var restored = text;
    for (final entry in placeholders.entries) {
      restored = restored.replaceAll(entry.key, entry.value);
    }
    return restored;
  }
}

class _ProtectedText {
  final String text;
  final Map<String, String> placeholders;

  const _ProtectedText({required this.text, required this.placeholders});
}
