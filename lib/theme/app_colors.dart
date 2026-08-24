import 'package:flutter/material.dart';

// All the colors used across the GirlStadium app.
class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFFA855F7);

  // Background colors
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF273449);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Redesign palette - the pink/violet visual system used by the new
  // GirlStadium look. Added alongside the original tokens above so
  // existing screens are unaffected; only screens that opt in (Home,
  // for now) use these.
  static const Color deepBackground = Color(0xFF0B0918);
  static const Color surfaceBase = Color(0xFF171229);
  static const Color surfaceElevated = Color(0xFF21183A);
  static const Color accentPink = Color(0xFFFF4DB8);
  static const Color accentViolet = Color(0xFF8A4FFF);
  static const Color textWarm = Color(0xFFF8F5FF);
  static const Color textMuted = Color(0xFFA9A1BE);
  static const Color borderLavender = Color(0xFF4A3F6B);

  // The primary GirlStadium gradient (pink -> violet), plus a couple
  // of variants within the same family for category cards so they
  // read as one cohesive system rather than random colors.
  static const List<Color> heroGradient = [accentPink, accentViolet];
  static const List<Color> violetIndigoGradient = [
    Color(0xFF8A4FFF),
    Color(0xFF4F5FFF),
  ];
  static const List<Color> magentaPurpleGradient = [
    Color(0xFFE64DFF),
    Color(0xFF7C4DFF),
  ];

  // Cycles through the accent gradients above for category-style
  // cards (Learn/News previews) so adjacent cards feel varied but
  // stay within the same palette.
  static List<Color> accentGradientForIndex(int index) {
    const gradients = [heroGradient, violetIndigoGradient, magentaPurpleGradient];
    return gradients[index % gradients.length];
  }
}