import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A compact, editorial-style lesson card for Home's "Learn Football"
// preview row. Distinct from the shared LearnCard used on the Learn
// screen itself, so redesigning this never changes that screen.
class LearnPreviewCard extends StatelessWidget {
  final String title;
  final String category;
  final String readTime;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const LearnPreviewCard({
    super.key,
    required this.title,
    required this.category,
    required this.readTime,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(18);

    return SizedBox(
      width: 160,
      child: Material(
        color: Colors.transparent,
        borderRadius: cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardRadius,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: cardRadius,
              border: Border.all(
                color: AppColors.borderLavender.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: gradient.first,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      readTime,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
