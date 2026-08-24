import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/article.dart';

// The News screen's large editorial hero: the first filtered
// article's real image (or a branded fallback), with a gradient
// scrim and its title/category/source overlaid at the bottom.
// Distinct from Home's FeaturedNewsCard (news_preview_card.dart),
// which uses a flat gradient panel with no real image - so this
// widget never affects Home.
class FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: radius,
            border: Border.all(
              color: AppColors.borderLavender.withValues(alpha: 0.4),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE60B0918)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.heroGradient),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            article.sourceName ?? 'GirlStadium News',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildImage() {
    if (article.imageUrl == null || article.imageUrl!.isEmpty) {
      return _fallback();
    }

    return Image.network(
      article.imageUrl!,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  // A branded fallback so a missing/broken image never leaves a
  // blank rectangle - the pink-violet gradient plus the article's
  // existing category icon.
  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: Center(
        child: Icon(
          article.icon,
          color: Colors.white.withValues(alpha: 0.35),
          size: 64,
        ),
      ),
    );
  }
}
