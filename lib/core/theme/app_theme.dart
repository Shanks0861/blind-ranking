import 'package:flutter/material.dart';

class AppColors {
  // Background layers
  static const Color background = Color(0xFF080A0F);
  static const Color surface = Color(0xFF0E1118);
  static const Color surfaceElevated = Color(0xFF151820);
  static const Color card = Color(0xFF1A1E2A);

  // Blood red - Mafia accent
  static const Color blood = Color(0xFFB01020);
  static const Color bloodLight = Color(0xFFE01830);
  static const Color bloodGlow = Color(0x40B01020);

  // Gold - Citizens accent
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFF0C060);
  static const Color goldGlow = Color(0x40D4A843);

  // Hunter - teal accent
  static const Color hunter = Color(0xFF1E7A5A);
  static const Color hunterLight = Color(0xFF2EB07A);

  // Text
  static const Color textPrimary = Color(0xFFEEE8D8);
  static const Color textSecondary = Color(0xFF8A8070);
  static const Color textMuted = Color(0xFF4A4540);

  // States
  static const Color alive = Color(0xFF2EB07A);
  static const Color dead = Color(0xFF4A2028);
  static const Color voting = Color(0xFFD4A843);
  static const Color eliminated = Color(0xFFB01020);

  // Borders & dividers
  static const Color border = Color(0xFF252830);
  static const Color borderAccent = Color(0xFF3A3020);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.blood,
        secondary: AppColors.gold,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.textPrimary,
        error: AppColors.bloodLight,
      ),
      fontFamily: 'Raleway',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 4,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 3,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blood,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.blood),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Raleway',
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontFamily: 'Raleway',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Raleway',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
