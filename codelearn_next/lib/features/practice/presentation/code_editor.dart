import 'dart:math';

import 'package:flutter/material.dart';

class CodeEditingController extends TextEditingController {
  final String language;
  CodeEditingController({required this.language, super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (withComposing &&
        value.composing.isValid &&
        !value.composing.isCollapsed) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final pattern = RegExp(
      r'''("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|#[^\n]*|//[^\n]*|\b(?:def|class|return|if|else|elif|for|while|in|import|from|as|try|except|with|const|let|var|function|async|await|new|int|float|double|bool|void|using|namespace|include|SELECT|FROM|WHERE|JOIN|ON|GROUP|ORDER|BY|LIMIT|CREATE|TABLE|INSERT|UPDATE|DELETE|true|false|True|False|None|null)\b|\b\d+(?:\.\d+)?\b)''',
    );
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      final color = token.startsWith('#') || token.startsWith('//')
          ? const Color(0xFF7F8AAB)
          : token.startsWith('"') || token.startsWith("'")
          ? const Color(0xFF9EE6C1)
          : RegExp(r'^\d').hasMatch(token)
          ? const Color(0xFFF4C48B)
          : const Color(0xFFB8B0FF);
      spans.add(
        TextSpan(
          text: token,
          style: TextStyle(color: color),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return TextSpan(style: style, children: spans);
  }
}

class LearningCodeEditor extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  const LearningCodeEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    this.readOnly = false,
  });
  @override
  State<LearningCodeEditor> createState() => LearningCodeEditorState();
}

class LearningCodeEditorState extends State<LearningCodeEditor> {
  final ScrollController vertical = ScrollController();
  String previousText = '';
  bool adjusting = false;
  @override
  void initState() {
    super.initState();
    previousText = widget.controller.text;
  }

  @override
  void dispose() {
    vertical.dispose();
    super.dispose();
  }

  void changed(String text) {
    if (!adjusting &&
        text.length == previousText.length + 1 &&
        widget.controller.selection.isCollapsed) {
      final cursor = widget.controller.selection.baseOffset;
      if (cursor > 0 && text[cursor - 1] == '\n') {
        final before = text.substring(0, cursor - 1).split('\n').last;
        final indentation = RegExp(r'^\s*').firstMatch(before)?.group(0) ?? '';
        final extra =
            before.trimRight().endsWith(':') || before.trimRight().endsWith('{')
            ? '    '
            : '';
        final insertion = '$indentation$extra';
        if (insertion.isNotEmpty) {
          adjusting = true;
          widget.controller.value = TextEditingValue(
            text: text.replaceRange(cursor, cursor, insertion),
            selection: TextSelection.collapsed(
              offset: cursor + insertion.length,
            ),
          );
          adjusting = false;
        }
      }
    }
    previousText = widget.controller.text;
    widget.onChanged(previousText);
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.controller.text.split('\n');
    final longest = lines.fold<int>(
      0,
      (value, line) => max(value, line.length),
    );
    const style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.65,
      color: Color(0xFFDCF2EC),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: max(constraints.maxWidth, longest * 8.5 + 58),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  height: min(22, max(10, lines.length)) * 23.1,
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: vertical,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          0,
                          vertical.hasClients ? -vertical.offset : 0,
                        ),
                        child: child,
                      ),
                      child: Text(
                        List.generate(
                          lines.length,
                          (index) => '${index + 1}',
                        ).join('\n'),
                        textAlign: TextAlign.right,
                        style: style.copyWith(color: const Color(0xFF64708F)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    key: const ValueKey('code-editor'),
                    controller: widget.controller,
                    scrollController: vertical,
                    readOnly: widget.readOnly,
                    minLines: 10,
                    maxLines: 22,
                    autocorrect: false,
                    enableSuggestions: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    keyboardType: TextInputType.multiline,
                    style: style,
                    decoration: const InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: changed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
