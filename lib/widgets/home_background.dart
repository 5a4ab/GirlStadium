import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Paints Home's deep navy/purple background with a couple of soft,
// low-opacity glow shapes behind the real content. Purely decorative -
// built entirely from Container/BoxDecoration, no images or packages.
class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.deepBackground,
      child: Stack(
        children: [
          // A large, mostly-off-screen pink glow near the top.
          Positioned(
            top: -120,
            right: -80,
            child: _glow(320, AppColors.accentPink.withValues(alpha: 0.22)),
          ),
          // A softer violet glow lower down, on the opposite side.
          Positioned(
            top: 260,
            left: -120,
            child: _glow(260, AppColors.accentViolet.withValues(alpha: 0.16)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
