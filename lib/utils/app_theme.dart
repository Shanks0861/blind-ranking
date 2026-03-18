import 'package:flutter/material.dart';

class AppColors {
  // Ranking Farben (Position 1–10)
  static const Map<int, Color> rankColors = {
    1: Color(0xFFFF6B9D), // pink
    2: Color(0xFFFF8C42), // orange
    3: Color(0xFFFFD166), // gelb
    4: Color(0xFF06D6A0), // grün
    5: Color(0xFF118AB2), // blau
    6: Color(0xFF9B5DE5), // violett
    7: Color(0xFFF15BB5), // pink-lila
    8: Color(0xFF00BBF9), // hellblau
    9: Color(0xFF00F5D4), // mint
    10: Color(0xFFEF233C), // rot
  };

  // Tier List Farben
  static const Map<String, Color> tierColors = {
    'S': Color(0xFFFF6B6B),
    'A': Color(0xFFFFB347),
    'B': Color(0xFFFFFF66),
    'C': Color(0xFF90EE90),
    'D': Color(0xFF87CEEB),
    'F': Color(0xFFDDA0DD),
  };

  static Color rankColor(int position) {
    return rankColors[position] ?? const Color(0xFF888888);
  }

  // App Theme
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryVariant = Color(0xFF5048C9);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color border = Color(0xFF2A2A4A);
}

class AppConstants {
  static const String supabaseUrl = 'https://dadfpdkvivsvxmdrwjqc.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_0TuuuvLoHqV0o087xFPhYg_dm2pCPBS';

  static const List<String> tiers = ['S', 'A', 'B', 'C', 'D', 'F'];

  static const int lobbyCodeLength = 6;
  static const int defaultRoundTimerSeconds = 30;
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),
    );
  }
}
