import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A card used to display one football news article.
class NewsCard extends StatelessWidget {
  final String title;
  final String timeAgo;

  // Optional short description shown under the title.
  final String? description;

  // Optional icon shown on the left. Defaults to a plain article icon.
  // Used as a fallback when there is no [imageUrl], or it fails to load.
  final IconData icon;

  // Optional real article image. When provided, it's shown instead of
  // the icon box below.
  final String? imageUrl;

  // Optional tap callback. When null, the card is not tappable.
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.title,
    required this.timeAgo,
    this.description,
    this.icon = Icons.article_outlined,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(14);

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: cardRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

  // Builds the leading thumbnail: a real image when [imageUrl] is
  // available, falling back to the existing icon box otherwise - or
  // if the image fails to load.
  Widget _buildThumbnail() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildIconBox();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildIconBox(),
      ),
    );
  }

  // The existing icon-box visual fallback.
  Widget _buildIconBox() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}