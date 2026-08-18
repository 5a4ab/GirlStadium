import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// One row in the league standings table.
class StandingRow extends StatelessWidget {
  final int position;
  final String clubName;
  final int played;
  final String goalDifference;
  final int points;

  // Optional small color indicator on the left (e.g. green for top 4).
  // Pass null for no indicator.
  final Color? indicatorColor;

  // Optional tap callback. When null, the row simply doesn't respond
  // to taps (InkWell handles a null onTap safely on its own).
  final VoidCallback? onTap;

  const StandingRow({
    super.key,
    required this.position,
    required this.clubName,
    required this.played,
    required this.goalDifference,
    required this.points,
    this.indicatorColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rowRadius = BorderRadius.circular(12);

    // The margin lives OUTSIDE the tappable Material/InkWell, and the
    // row's background color lives directly on the Material (instead
    // of on an inner Container). This is the standard Flutter pattern
    // for a fully tappable card and guarantees the whole row -
    // including the empty space between the text columns - responds
    // to taps.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: rowRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: rowRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Position indicator bar.
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: indicatorColor ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),

                // Position number.
                SizedBox(
                  width: 24,
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Club name.
                Expanded(
                  flex: 3,
                  child: Text(
                    clubName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Played.
                Expanded(
                  child: Text(
                    '$played',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Goal difference.
                Expanded(
                  child: Text(
                    goalDifference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Points.
                Expanded(
                  child: Text(
                    '$points',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}