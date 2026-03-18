import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light Mode Colors ───
  static const _lightPrimary = Color(0xFF0049E6);
  static const _lightPrimaryContainer = Color(0xFF829BFF);
  static const _lightOnPrimary = Color(0xFFF2F1FF);
  static const _lightOnPrimaryContainer = Color(0xFF001A63);

  static const _lightSecondary = Color(0xFF006A28);
  static const _lightSecondaryContainer = Color(0xFF5CFD80);
  static const _lightOnSecondary = Color(0xFFCFFFCE);

  static const _lightTertiary = Color(0xFFAF2700);
  static const _lightTertiaryContainer = Color(0xFFFF9479);
  static const _lightOnTertiary = Color(0xFFFFEFEC);

  static const _lightError = Color(0xFFB41340);
  static const _lightErrorContainer = Color(0xFFF74B6D);

  static const _lightSurface = Color(0xFFF8F5FF);
  static const _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const _lightSurfaceContainerLow = Color(0xFFF2EFFF);
  static const _lightSurfaceContainer = Color(0xFFE8E6FF);
  static const _lightSurfaceContainerHigh = Color(0xFFE1DFFF);
  static const _lightSurfaceContainerHighest = Color(0xFFDBD9FF);

  static const _lightOnSurface = Color(0xFF2A2B51);
  static const _lightOnSurfaceVariant = Color(0xFF575881);
  static const _lightOutline = Color(0xFF73739E);
  static const _lightOutlineVariant = Color(0xFFA9A9D7);

  // ─── Dark Mode Colors (Dashboard canonical) ───
  static const _darkPrimary = Color(0xFF4D80FF);
  static const _darkPrimaryContainer = Color(0xFF0041C2);
  static const _darkOnPrimary = Color(0xFF00287A);
  static const _darkOnPrimaryContainer = Color(0xFFDBE1FF);

  static const _darkSecondary = Color(0xFF4BEE74);
  static const _darkSecondaryContainer = Color(0xFF00521C);
  static const _darkOnSecondary = Color(0xFF003912);

  static const _darkTertiary = Color(0xFFFFB4A1);
  static const _darkTertiaryContainer = Color(0xFF8D2100);

  static const _darkError = Color(0xFFFFB4AB);
  static const _darkErrorContainer = Color(0xFF93001A);

  static const _darkSurface = Color(0xFF0F0F17);
  static const _darkSurfaceContainerLowest = Color(0xFF0B0B0E);
  static const _darkSurfaceContainerLow = Color(0xFF1D1D2B);
  static const _darkSurfaceContainer = Color(0xFF21212E);
  static const _darkSurfaceContainerHigh = Color(0xFF2B2B3D);
  static const _darkSurfaceContainerHighest = Color(0xFF36364A);

  static const _darkOnSurface = Color(0xFFE2E2E9);
  static const _darkOnSurfaceVariant = Color(0xFFC5C5D3);
  static const _darkOutline = Color(0xFF8E90A6);
  static const _darkOutlineVariant = Color(0xFF454655);

  // ─── Semantic Colors (accessible from anywhere) ───
  static const Color incomeGreen = Color(0xFF006A28);
  static const Color incomeGreenDark = Color(0xFF4BEE74);
  static const Color expenseRed = Color(0xFFAF2700);
  static const Color expenseRedDark = Color(0xFFFFB4A1);

  // ─── Text Theme ───
  static TextTheme _buildTextTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: onSurfaceVariant,
        letterSpacing: 1.5,
      ),
    );
  }

  // ─── Light Theme ───
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      secondaryContainer: _lightSecondaryContainer,
      onSecondaryContainer: _lightSecondary,
      tertiary: _lightTertiary,
      onTertiary: _lightOnTertiary,
      tertiaryContainer: _lightTertiaryContainer,
      onTertiaryContainer: _lightTertiary,
      error: _lightError,
      onError: Colors.white,
      errorContainer: _lightErrorContainer,
      onErrorContainer: Colors.white,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      surfaceContainerLowest: _lightSurfaceContainerLowest,
      surfaceContainerLow: _lightSurfaceContainerLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceContainerHigh,
      surfaceContainerHighest: _lightSurfaceContainerHighest,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightSurface,
      textTheme: _buildTextTheme(_lightOnSurface, _lightOnSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _lightOnSurface,
        ),
        iconTheme: IconThemeData(color: _lightOnSurface),
      ),
      cardTheme: CardThemeData(
        color: _lightSurfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          minimumSize: Size(double.infinity, 56),
          shape: StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          minimumSize: Size(double.infinity, 56),
          shape: StadiumBorder(),
          side: BorderSide(color: _lightOutlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightPrimaryContainer, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurfaceContainerLowest,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightOnSurfaceVariant.withValues(alpha: 0.7),
      ),
      dividerTheme: DividerThemeData(
        color: _lightOutlineVariant.withValues(alpha: 0.3),
      ),
    );
  }

  // ─── Dark Theme ───
  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      secondaryContainer: _darkSecondaryContainer,
      onSecondaryContainer: _darkSecondary,
      tertiary: _darkTertiary,
      onTertiary: Color(0xFF621200),
      tertiaryContainer: _darkTertiaryContainer,
      onTertiaryContainer: _darkTertiary,
      error: _darkError,
      onError: Color(0xFF690005),
      errorContainer: _darkErrorContainer,
      onErrorContainer: _darkError,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      surfaceContainerLowest: _darkSurfaceContainerLowest,
      surfaceContainerLow: _darkSurfaceContainerLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkSurface,
      textTheme: _buildTextTheme(_darkOnSurface, _darkOnSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _darkOnSurface,
        ),
        iconTheme: IconThemeData(color: _darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: _darkSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          minimumSize: Size(double.infinity, 56),
          shape: StadiumBorder(),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          minimumSize: Size(double.infinity, 56),
          shape: StadiumBorder(),
          side: BorderSide(color: _darkOutlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkPrimaryContainer, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceContainer,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkOnSurfaceVariant.withValues(alpha: 0.7),
      ),
      dividerTheme: DividerThemeData(
        color: _darkOutlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}
