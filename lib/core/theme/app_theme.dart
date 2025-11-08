import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../styles/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData buildNoirOrange(Color accent) {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: AppPalette.noirBackground,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: accent,
        secondary: AppPalette.noirWarning,
        surface: AppPalette.noirSurface,
        background: AppPalette.noirBackground,
      ),
      canvasColor: AppPalette.noirSurface,
      cardColor: AppPalette.noirSurface,
      textTheme: AppTypography.buildTextTheme(AppPalette.noirTextPrimary),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: TextStyle(color: AppPalette.noirTextPrimary),
        backgroundColor: AppPalette.noirSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppPalette.noirTextPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppPalette.noirSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppPalette.noirTextSecondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent),
        ),
      ),
      dividerTheme: base.dividerTheme.copyWith(color: AppPalette.noirTextSecondary.withOpacity(0.1)),
    );
  }

  static ThemeData buildIvoryYellow(Color accent) {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: AppPalette.ivoryBackground,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: accent,
        secondary: AppPalette.ivoryWarning,
        surface: AppPalette.ivorySurface,
        background: AppPalette.ivoryBackground,
      ),
      canvasColor: AppPalette.ivorySurface,
      cardColor: AppPalette.ivorySurface,
      textTheme: AppTypography.buildTextTheme(AppPalette.ivoryTextPrimary),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: TextStyle(color: AppPalette.ivoryTextPrimary),
        backgroundColor: AppPalette.ivorySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppPalette.ivoryTextPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppPalette.ivorySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppPalette.ivoryTextSecondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent),
        ),
      ),
      dividerTheme: base.dividerTheme.copyWith(color: AppPalette.ivoryTextSecondary.withOpacity(0.1)),
    );
  }
}
