import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const card = Color(0xFF1C2128);
  static const border = Color(0xFF30363D);
  static const accent = Color(0xFF2196F3);
  static const accentGlow = Color(0x332196F3);
  static const cyan = Color(0xFF00BCD4);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFEF5350);
  static const warning = Color(0xFFFF9800);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);
  static const rBadge = Color(0xFF2196F3);
  static const hBadge = Color(0xFFFF9800);
  static const nBadge = Color(0xFF424242);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    fontFamily: 'Orbitron',
  );
}
