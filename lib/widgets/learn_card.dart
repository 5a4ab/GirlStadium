import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A card used to display one football lesson, e.g. "What is Offside?".
class LearnCard extends StatelessWidget {
  final String title;
  final String readTime;

  // Optional short description shown under the title.
  final String? description;

  // Optional icon shown on the left. Defaults to a football icon.
  final IconData icon;

  // Optional tap callback. When null, the card is not tappable.
  final VoidCallback? onTap;

  const LearnCard({
    super.key,
    required this.title,
    required this.readTime,
    this.description,
    this.icon = Icons.sports_soccer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(16);

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: cardRadius,
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.accentPink,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  readTime,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: cardContent,
      ),
    );
  }
}