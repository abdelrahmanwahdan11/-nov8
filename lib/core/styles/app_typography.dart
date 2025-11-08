import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(Color color) {
    final base = ThemeData(brightness: Brightness.light).textTheme;
    return TextTheme(
      displayLarge: GoogleFonts.urbanist(
        textStyle: base.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -1.0,
        ),
      ),
      displayMedium: GoogleFonts.urbanist(
        textStyle: base.displayMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: -0.8,
        ),
      ),
      displaySmall: GoogleFonts.urbanist(
        textStyle: base.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      headlineMedium: GoogleFonts.urbanist(
        textStyle: base.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      headlineSmall: GoogleFonts.urbanist(
        textStyle: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge?.copyWith(
          color: color,
        ),
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium?.copyWith(
          color: color.withOpacity(0.85),
        ),
      ),
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      labelMedium: GoogleFonts.inter(
        textStyle: base.labelMedium?.copyWith(
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }
}
