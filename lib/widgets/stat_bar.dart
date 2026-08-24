import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A widget that shows one match statistic as two values with a
// split progress bar in between (e.g. Possession 58% vs 42%). The
// home side is pink, the away side is violet.
class StatBar extends StatelessWidget {
  final String label;
  final String leftValue;
  final String rightValue;

  // How much of the bar belongs to the left side, from 0.0 to 1.0.
  final double leftRatio;

  const StatBar({
    super.key,
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.leftRatio,
  });

  @override
  Widget build(BuildContext context) {
    // Flex values out of 1000 for finer precision than a 0-100 split,
    // each clamped to at least 1 so Expanded never gets a zero flex.
    final leftFlex = (leftRatio * 1000).round().clamp(1, 999);
    final rightFlex = 1000 - leftFlex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftValue,
                style: const TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                rightValue,
                style: const TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: leftFlex,
                  child: Container(height: 7, color: AppColors.accentPink),
                ),
                Expanded(
                  flex: rightFlex,
                  child: Container(height: 7, color: AppColors.accentViolet),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
