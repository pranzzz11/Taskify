import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7B68EE);
  static const Color primaryDark = Color(0xFF5A4FCF);
  static const Color primaryLight = Color(0xFFDDD8FF);

  static const Color gradientStart = Color(0xFFF5F2FF);
  static const Color gradientEnd = Color(0xFFE8E3FD);

  static const Color background = Color(0xFFEFECFF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceVariant = Color(0xFFE8E4FF);

  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF6E6E82);
  static const Color textTertiary = Color(0xFF9E9EB8);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);

  static const Color divider = Color(0xFFE0DCF0);

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientStart, gradientEnd],
    ),
  );
}
