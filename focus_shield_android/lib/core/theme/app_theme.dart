import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF020617);
  static const card = Color(0xFF0F172A);
  static const cardSoft = Color(0xFF111C33);
  static const primary = Color(0xFF22C55E);
  static const secondary = Color(0xFF2563EB);
  static const warning = Color(0xFFFACC15);
  static const danger = Color(0xFFFB7185);
  static const text = Color(0xFFE5E7EB);
  static const muted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: card,
        error: danger,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: text,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(
          color: text,
          height: 1.45,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
      ),
    );
  }
}
