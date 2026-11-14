import 'package:flutter/material.dart';

const brandBlue = Color(0xFF6574FF);
const brandMint = Color(0xFF80E9C4);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: brandBlue,
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFA9B1FF) : const Color(0xFF4C55D4),
        secondary: const Color(0xFF389E80),
        surface: dark ? const Color(0xFF151A2C) : const Color(0xFFF8F9FE),
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? const Color(0xFF0D1120)
        : const Color(0xFFF3F5FC),
    fontFamily: 'sans-serif',
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        height: 1.18,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: scheme.onSurface,
      ),
      headlineMedium: const TextStyle(
        fontSize: 27,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -.6,
      ),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.6),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .35)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: .5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: .4),
    ),
  );
}
