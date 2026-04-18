import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackText;
  final double size;
  final TextStyle? fallbackStyle;
  final List<Color> fallbackGradient;

  const UserAvatar({
    required this.photoUrl,
    required this.fallbackText,
    required this.size,
    this.fallbackStyle,
    this.fallbackGradient = const [Color(0xFF0066FF), Color(0xFF8B5CF6)],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = _resolveImageProvider(photoUrl);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: imageProvider == null
            ? LinearGradient(colors: fallbackGradient)
            : null,
        color: imageProvider != null ? Colors.white : null,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageProvider == null
            ? _buildFallback()
            : Image(
                image: imageProvider,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(),
              ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: fallbackGradient),
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackText,
        style:
            fallbackStyle ??
            TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  ImageProvider<Object>? _resolveImageProvider(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    final normalized = source.trim();

    if (normalized.startsWith('data:image')) {
      final bytes = _decodeDataUrl(normalized);
      if (bytes != null && bytes.isNotEmpty) {
        return MemoryImage(bytes);
      }
      return null;
    }

    if (normalized.startsWith('assets/')) {
      return AssetImage(normalized);
    }

    final uri = Uri.tryParse(normalized);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(normalized);
    }

    return null;
  }

  Uint8List? _decodeDataUrl(String source) {
    final commaIndex = source.indexOf(',');
    if (commaIndex == -1 || commaIndex == source.length - 1) {
      return null;
    }
    final encoded = source.substring(commaIndex + 1);
    try {
      return base64Decode(encoded);
    } on FormatException {
      return null;
    }
  }
}
