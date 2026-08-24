import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Home's "Latest Stories" preview treats the first article as one
// large editorial story and the rest as smaller supporting cards.
// Both are distinct from the shared NewsCard used on the News screen,
// so redesigning them never changes that screen.

// The large featured story card - a full-width gradient panel with a
// category pill, headline, and a faint decorative icon.
class FeaturedNewsCard extends StatelessWidget {
  final String title;
  final String category;
  final String timeAgo;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const FeaturedNewsCard({
    super.key,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(20);

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: cardRadius,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -12,
                bottom: -14,
                child: Icon(
                  icon,
                  size: 92,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A smaller supporting story card shown below the featured one.
class NewsPreviewCard extends StatelessWidget {
  final String title;
  final String category;
  final String timeAgo;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const NewsPreviewCard({
    super.key,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(16);

    return Material(
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
              color: AppColors.borderLavender.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: gradient.first,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWarm,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
