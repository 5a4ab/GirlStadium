import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A widget that shows one match statistic as two values with a
// split progress bar in between (e.g. Possession 58% vs 42%).
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftValue,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                rightValue,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
                  flex: (leftRatio * 100).round(),
                  child: Container(
                    height: 6,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  flex: (100 - (leftRatio * 100).round()),
                  child: Container(
                    height: 6,
                    color: AppColors.card,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}