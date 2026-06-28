import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy        = Color(0xFF0A0F1E);
  static const navyCard    = Color(0xFF111827);
  static const navyCard2   = Color(0xFF1A2235);
  static const navyBorder  = Color(0xFF1E2D4A);
  static const cyan        = Color(0xFF00D4FF);
  static const cyanDim     = Color(0x2200D4FF);
  static const gold        = Color(0xFFFFB800);
  static const goldDim     = Color(0x22FFB800);
  static const green       = Color(0xFF00E676);
  static const red         = Color(0xFFFF3D5A);
  static const textDark    = Color(0xFFE2E8F0);
  static const mutedDark   = Color(0xFF64748B);
  static const lightBg     = Color(0xFFF0F4FF);
  static const lightCard   = Color(0xFFFFFFFF);
  static const lightCard2  = Color(0xFFEEF2FF);
  static const lightBorder = Color(0xFFD1D9F0);
  static const textLight   = Color(0xFF0F172A);
  static const mutedLight  = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyan,
      secondary: AppColors.gold,
      surface: AppColors.navyCard,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.cyan),
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.navyCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AppColors.navyBorder),
      ),
    ),
    dividerColor: AppColors.navyBorder,
    useMaterial3: true,
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0088AA),
      secondary: Color(0xFFCC8800),
      surface: AppColors.lightCard,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: AppColors.textLight,
      displayColor: AppColors.textLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightCard,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0088AA)),
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: AppColors.lightBorder),
      ),
    ),
    dividerColor: AppColors.lightBorder,
    useMaterial3: true,
  );
}