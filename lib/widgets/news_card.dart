import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A card used to display one football news article. Shared by the
// News screen's supporting-story list and Home's local search
// results - [category] and [sourceName] are optional additions used
// by News; Home's call site doesn't pass them, so its appearance is
// unaffected beyond the shared visual refresh.
class NewsCard extends StatelessWidget {
  final String title;
  final String timeAgo;

  // Optional short description shown under the title.
  final String? description;

  // Optional category label shown above the title (e.g. "Transfers").
  final String? category;

  // Optional source name shown before the time (e.g. "BBC Sport").
  final String? sourceName;

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
    this.category,
    this.sourceName,
    this.icon = Icons.article_outlined,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(16);

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
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
          _buildThumbnail(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null) ...[
                  Text(
                    category!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accentPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _buildMeta(),
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

  // Source + time when a source is available, otherwise just the time
  // - matches the previous (Home) behavior exactly when no source is
  // passed.
  Widget _buildMeta() {
    if (sourceName == null || sourceName!.isEmpty) {
      return Text(
        timeAgo,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            sourceName!,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          timeAgo,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _buildIconBox(),
        errorBuilder: (context, error, stackTrace) => _buildIconBox(),
      ),
    );
  }

  // The existing icon-box visual fallback.
  Widget _buildIconBox() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.accentPink.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AppColors.accentPink,
        size: 28,
      ),
    );
  }
}
