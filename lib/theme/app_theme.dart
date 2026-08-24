import 'package:flutter/material.dart';
import 'app_colors.dart';

// The main theme for the GirlStadium app, built with Material 3.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // The redesigned deep navy/purple background, shared by every
      // screen's Scaffold unless it paints its own full-bleed
      // background (Home does, via HomeBackground).
      scaffoldBackgroundColor: AppColors.deepBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
      // Shared app-bar language for detail screens: transparent so
      // the deep background shows through, warm-white title/icons,
      // no default Material elevation/tint.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textWarm),
        titleTextStyle: TextStyle(
          color: AppColors.textWarm,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      // A safe dark-surface default for any popup/dropdown menu that
      // doesn't already set its own color explicitly.
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        textStyle: const TextStyle(color: AppColors.textWarm, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderLavender.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}