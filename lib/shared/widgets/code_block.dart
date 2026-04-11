import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final bool showLineNumbers;
  final double fontSize;

  const CodeBlock({
    super.key,
    required this.code,
    this.language = 'python',
    this.showLineNumbers = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with language indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLanguageColor(language).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getLanguageColor(
                          language,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _languageLabel(language),
                      style: TextStyle(
                        color: _getLanguageColor(language),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.code,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            // Code content
            if (showLineNumbers)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Line numbers
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      color: Colors.black.withValues(alpha: 0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          lines.length,
                          (index) => Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: fontSize,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Code
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        child: HighlightView(
                          code,
                          language: language,
                          theme: atomOneDarkTheme,
                          textStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: fontSize,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: HighlightView(
                  code,
                  language: language,
                  theme: atomOneDarkTheme,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: fontSize,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return const Color(0xFF3776AB);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'cpp':
      case 'c++':
      case 'cplusplus':
        return const Color(0xFF00599C);
      case 'html':
        return const Color(0xFFE34F26);
      case 'css':
        return const Color(0xFF1572B6);
      case 'dart':
        return const Color(0xFF0175C2);
      case 'bash':
      case 'shell':
      case 'sh':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF61DAFB);
    }
  }

  String _languageLabel(String lang) {
    final normalized = lang.trim().toLowerCase();
    if (normalized == 'cpp' ||
        normalized == 'c++' ||
        normalized == 'cplusplus') {
      return 'C++';
    }
    return lang.toUpperCase();
  }
}

class InlineCode extends StatelessWidget {
  final String code;

  const InlineCode({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Color(0xFFE06C75),
        ),
      ),
    );
  }
}
