import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landing_groom_page/core/constants/app_constants.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
        primary: AppColors.ink,
        secondary: AppColors.gold,
        surface: AppColors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 76,
          fontWeight: FontWeight.w600,
          height: .96,
          letterSpacing: -2.2,
          color: AppColors.ink,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 56,
          fontWeight: FontWeight.w600,
          height: 1,
          letterSpacing: -1.2,
          color: AppColors.ink,
        ),
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 42,
          fontWeight: FontWeight.w600,
          height: 1.05,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 17,
          height: 1.65,
          color: AppColors.muted,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 15,
          height: 1.6,
          color: AppColors.muted,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: .15,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softCream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.goldDark, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB42318)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
