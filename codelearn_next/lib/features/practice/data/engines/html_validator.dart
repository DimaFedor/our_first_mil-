class HTMLValidator {
  String validate(String code) {
    final lines = code.split('\n');
    final errors = <String>[];
    final tagStack = <String>[];

    final selfClosingTags = {
      'img',
      'br',
      'hr',
      'input',
      'meta',
      'link',
      'area',
      'base',
      'col',
      'embed',
      'source',
      'track',
      'wbr',
    };

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lineNum = i + 1;

      if (line.isEmpty || line.startsWith('//') || line.startsWith('/*')) {
        continue;
      }

      final openTagRegex = RegExp(r'<(\w+)(?:\s+[^>]*)?(?<!/)>');
      final closeTagRegex = RegExp(r'</(\w+)>');
      final selfClosingRegex = RegExp(r'<(\w+)(?:\s+[^>]*)?\s*/>');

      for (final match in openTagRegex.allMatches(line)) {
        final tagName = match.group(1)!.toLowerCase();
        if (!selfClosingTags.contains(tagName)) {
          tagStack.add(tagName);
        }
      }

      selfClosingRegex.allMatches(line);

      for (final match in closeTagRegex.allMatches(line)) {
        final tagName = match.group(1)!.toLowerCase();

        if (tagStack.isEmpty) {
          errors.add(
            'Line $lineNum: Closing tag </$tagName> without matching opening tag',
          );
        } else {
          final expectedTag = tagStack.removeLast();
          if (expectedTag != tagName) {
            errors.add(
              'Line $lineNum: Expected closing tag </$expectedTag> but found </$tagName>',
            );

            tagStack.add(expectedTag);
          }
        }
      }

      if (line.contains('class=') &&
          !line.contains('class="') &&
          !line.contains("class='")) {
        errors.add('Line $lineNum: class attribute should be in quotes');
      }
      if (line.contains('id=') &&
          !line.contains('id="') &&
          !line.contains("id='")) {
        errors.add('Line $lineNum: id attribute should be in quotes');
      }
    }

    if (tagStack.isNotEmpty) {
      errors.add('Unclosed tags: ${tagStack.join(', ')}');
    }

    if (code.contains('<style>') || code.contains('.') && code.contains('{')) {
      validateCSS(code, errors);
    }

    if (errors.isNotEmpty) {
      return 'Validation errors:\n${errors.join('\n')}';
    }

    return '';
  }

  void validateCSS(String code, List<String> errors) {
    final cssPropertyPattern = RegExp(r'(\w+-?\w+)\s*:\s*([^;]+);');

    final validProperties = {
      'color',
      'background',
      'background-color',
      'border',
      'margin',
      'padding',
      'width',
      'height',
      'display',
      'position',
      'top',
      'left',
      'right',
      'bottom',
      'font-size',
      'font-family',
      'font-weight',
      'text-align',
      'line-height',
      'flex',
      'flex-direction',
      'justify-content',
      'align-items',
      'grid',
      'grid-template-columns',
      'grid-template-rows',
      'gap',
      'opacity',
      'transition',
      'transform',
      'animation',
      'cursor',
      'overflow',
      'z-index',
      'box-shadow',
      'text-shadow',
      'border-radius',
      'float',
      'clear',
      'visibility',
      'max-width',
      'max-height',
      'min-width',
      'min-height',
    };

    final matches = cssPropertyPattern.allMatches(code);
    for (final match in matches) {
      final property = match.group(1)!.toLowerCase();
      if (!validProperties.contains(property) && !property.startsWith('-')) {
        errors.add('Unknown CSS property: $property');
      }
    }

    final openBraces = code.split('{').length - 1;
    final closeBraces = code.split('}').length - 1;
    if (openBraces != closeBraces) {
      errors.add(
        'Unbalanced CSS braces: $openBraces opening, $closeBraces closing',
      );
    }
  }

  HTMLResult execute(String code) {
    final validationError = validate(code);
    if (validationError.isNotEmpty) {
      return HTMLResult(output: '', error: validationError, hasError: true);
    }

    return HTMLResult(
      output: 'HTML code is valid ✓',
      error: null,
      hasError: false,
    );
  }
}

class HTMLResult {
  final String output;
  final String? error;
  final bool hasError;

  HTMLResult({required this.output, this.error, required this.hasError});
}
