import 'package:flutter/material.dart';

const brandBlue = Color(0xFF6574FF);
const brandMint = Color(0xFF80E9C4);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final ink = dark ? const Color(0xFFF2F2F0) : const Color(0xFF1A1A18);
  final muted = dark ? const Color(0xFF98979F) : const Color(0xFF6E6D68);
  final background = dark ? const Color(0xFF0C0C0D) : const Color(0xFFF3F2EE);
  final surface = dark ? const Color(0xFF1A1A1C) : Colors.white;
  final raised = dark ? const Color(0xFF26262A) : const Color(0xFFE8E6E0);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: brandBlue,
        brightness: brightness,
      ).copyWith(
        primary: ink,
        onPrimary: background,
        primaryContainer: raised,
        onPrimaryContainer: ink,
        secondary: dark ? const Color(0xFF5AA2FF) : const Color(0xFF1F6FEB),
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: muted,
        surfaceContainerHighest: raised,
        outlineVariant: dark
            ? const Color(0xFF2C2C30)
            : const Color(0xFFE3E1DB),
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    fontFamily: 'Onest',
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Source Serif 4',
        fontSize: 36,
        height: 1.12,
        fontWeight: FontWeight.w600,
        letterSpacing: -.6,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Source Serif 4',
        fontSize: 27,
        height: 1.18,
        fontWeight: FontWeight.w600,
        letterSpacing: -.3,
        color: ink,
      ),
      titleLarge: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.55),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
      bodySmall: TextStyle(fontSize: 13, height: 1.4, color: muted),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
      horizontalTitleGap: 14,
      iconColor: muted,
      titleTextStyle: TextStyle(
        fontFamily: 'Onest',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: 'Onest',
        fontSize: 13,
        color: muted,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? ink : surface,
      ),
      labelStyle: TextStyle(
        fontFamily: 'Onest',
        fontWeight: FontWeight.w500,
        color: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected) ? background : ink,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: background,
        minimumSize: const Size(44, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Onest',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.secondary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: raised,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: ink,
      linearTrackColor: raised,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );
}
