import 'package:flutter/material.dart';

class PatientAppTheme {
  // Wellness healthcare color palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepNavy = Color(0xFF172554);
  static const Color background = Color(0xFFF5F7FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF15803D);
  static const Color softGreen = Color(0xFFE8F5EC);
  static const Color helpRed = Color(0xFFDC2626);
  static const Color softRed = Color(0xFFFEF2F2);
  static const Color voicePurple = Color(0xFF6D28D9);
  static const Color softPurple = Color(0xFFF3E8FF);
  static const Color primaryText = Color(0xFF172033);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color borders = Color(0xFFE2E8F0);

  // High contrast & extra large touch targets for cognitive accessibility with Liquid Glass tokens
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: primaryGreen,
      onSecondary: Colors.white,
      error: helpRed,
      onError: Colors.white,
      surface: cardBackground,
      onSurface: primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: deepNavy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: deepNavy,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.65), width: 1.2),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primaryText,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: secondaryText,
        height: 1.35,
      ),
    ),
  );
}
