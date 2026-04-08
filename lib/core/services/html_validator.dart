/// HTML/CSS Validator for code validation
/// 
/// Features:
/// - HTML tag validation (proper opening/closing)
/// - CSS property validation
/// - Nested structure validation
/// - Class/ID usage checks
class HTMLValidator {
  String validate(String code) {
    final lines = code.split('\n');
    final errors = <String>[];
    final tagStack = <String>[];
    
    // Self-closing tags that don't need closing
    final selfClosingTags = {'img', 'br', 'hr', 'input', 'meta', 'link', 'area', 'base', 'col', 'embed', 'source', 'track', 'wbr'};
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lineNum = i + 1;
      
      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('//') || line.startsWith('/*')) {
        continue;
      }
      
      // Check for HTML tags
      final openTagRegex = RegExp(r'<(\w+)(?:\s+[^>]*)?(?<!/)>');
      final closeTagRegex = RegExp(r'</(\w+)>');
      final selfClosingRegex = RegExp(r'<(\w+)(?:\s+[^>]*)?\s*/>');
      
      // Find all opening tags
      for (final match in openTagRegex.allMatches(line)) {
        final tagName = match.group(1)!.toLowerCase();
        if (!selfClosingTags.contains(tagName)) {
          tagStack.add(tagName);
        }
      }
      
      // Find self-closing tags (already valid) - just skip them
      selfClosingRegex.allMatches(line); // These are already properly closed
      
      // Find all closing tags
      for (final match in closeTagRegex.allMatches(line)) {
        final tagName = match.group(1)!.toLowerCase();
        
        if (tagStack.isEmpty) {
          errors.add('Line $lineNum: Closing tag </$tagName> without matching opening tag');
        } else {
          final expectedTag = tagStack.removeLast();
          if (expectedTag != tagName) {
            errors.add('Line $lineNum: Expected closing tag </$expectedTag> but found </$tagName>');
            // Try to recover by putting it back
            tagStack.add(expectedTag);
          }
        }
      }
      
      // Check for common HTML issues
      if (line.contains('class=') && !line.contains('class="') && !line.contains("class='")) {
        errors.add('Line $lineNum: class attribute should be in quotes');
      }
      if (line.contains('id=') && !line.contains('id="') && !line.contains("id='")) {
        errors.add('Line $lineNum: id attribute should be in quotes');
      }
    }
    
    // Check for unclosed tags
    if (tagStack.isNotEmpty) {
      errors.add('Unclosed tags: ${tagStack.join(', ')}');
    }
    
    // Check for CSS if present
    if (code.contains('<style>') || code.contains('.') && code.contains('{')) {
      _validateCSS(code, errors);
    }
    
    if (errors.isNotEmpty) {
      return 'Validation errors:\n${errors.join('\n')}';
    }
    
    return '';  // No errors
  }
  
  void _validateCSS(String code, List<String> errors) {
    // Basic CSS validation
    final cssPropertyPattern = RegExp(r'(\w+-?\w+)\s*:\s*([^;]+);');
    
    // Common CSS properties
    final validProperties = {
      'color', 'background', 'background-color', 'border', 'margin', 'padding',
      'width', 'height', 'display', 'position', 'top', 'left', 'right', 'bottom',
      'font-size', 'font-family', 'font-weight', 'text-align', 'line-height',
      'flex', 'flex-direction', 'justify-content', 'align-items', 'grid',
      'grid-template-columns', 'grid-template-rows', 'gap', 'opacity',
      'transition', 'transform', 'animation', 'cursor', 'overflow',
      'z-index', 'box-shadow', 'text-shadow', 'border-radius', 'float',
      'clear', 'visibility', 'max-width', 'max-height', 'min-width', 'min-height'
    };
    
    final matches = cssPropertyPattern.allMatches(code);
    for (final match in matches) {
      final property = match.group(1)!.toLowerCase();
      if (!validProperties.contains(property) && !property.startsWith('-')) {
        // Allow vendor prefixes (-webkit-, -moz-, etc.)
        errors.add('Unknown CSS property: $property');
      }
    }
    
    // Check for balanced braces in CSS
    final openBraces = code.split('{').length - 1;
    final closeBraces = code.split('}').length - 1;
    if (openBraces != closeBraces) {
      errors.add('Unbalanced CSS braces: $openBraces opening, $closeBraces closing');
    }
  }
  
  /// Execute HTML code (for preview/output)
  /// Returns rendered output or validation errors
  HTMLResult execute(String code) {
    // First validate
    final validationError = validate(code);
    if (validationError.isNotEmpty) {
      return HTMLResult(
        output: '',
        error: validationError,
        hasError: true,
      );
    }
    
    // For now, just return success message
    // In future, could integrate with flutter_html for actual rendering
    return HTMLResult(
      output: 'HTML code is valid ✓',
      error: null,
      hasError: false,
    );
  }
}

/// Result from HTML validation/execution
class HTMLResult {
  final String output;
  final String? error;
  final bool hasError;
  
  HTMLResult({
    required this.output,
    this.error,
    required this.hasError,
  });
}
