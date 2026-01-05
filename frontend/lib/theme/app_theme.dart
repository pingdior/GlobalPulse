import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1);  // Indigo
  static const Color accentColor = Color(0xFF22D3EE);   // Cyan
  static const Color backgroundColor = Color(0xFF0F172A);  // Dark blue-gray
  static const Color surfaceColor = Color(0xFF1E293B);  // Slightly lighter
  static const Color cardColor = Color(0xFF334155);

  // Sentiment Colors
  static const Color positiveColor = Color(0xFF22C55E);
  static const Color negativeColor = Color(0xFFEF4444);
  static const Color neutralColor = Color(0xFF94A3B8);
  static const Color mixedColor = Color(0xFFF59E0B);

  // Heat Colors (gradient)
  static const List<Color> heatGradient = [
    Color(0xFF3B82F6),  // Blue (cold)
    Color(0xFF22D3EE),  // Cyan
    Color(0xFF22C55E),  // Green
    Color(0xFFF59E0B),  // Orange
    Color(0xFFEF4444),  // Red (hot)
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: negativeColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Get heat color based on score (0-100)
  static Color getHeatColor(int score) {
    if (score >= 80) return heatGradient[4];
    if (score >= 60) return heatGradient[3];
    if (score >= 40) return heatGradient[2];
    if (score >= 20) return heatGradient[1];
    return heatGradient[0];
  }
}
