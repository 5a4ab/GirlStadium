import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/article.dart';
import '../widgets/app_back_button.dart';

class NewsDetailsScreen extends StatelessWidget {
  final Article article;

  const NewsDetailsScreen({super.key, required this.article});

  // True when Article.content actually adds something beyond the
  // description - i.e. it isn't empty, isn't just the "no further
  // details" placeholder, and isn't a duplicate of the description
  // (which happens when GNews's content field was missing and the
  // model fell back to using the description as content).
  bool get _hasDistinctContent {
    if (article.content.isEmpty) return false;
    final joined = article.content.join(' ').trim();
    if (joined.isEmpty) return false;
    if (joined == 'No further details are available for this article.') {
      return false;
    }
    if (joined == article.description.trim()) return false;
    return true;
  }

  bool get _hasSourceUrl =>
      article.articleUrl != null && article.articleUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('News'),
        actions: [
          IconButton(
            onPressed: () {
              // No functionality yet.
            },
            icon: const Icon(
              Icons.bookmark_border,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Large rounded article image, falling back to a
              // polished GirlStadium placeholder when unavailable.
              _buildHeroImage(),

              const SizedBox(height: 16),

              // Category badge.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article.category,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Headline - the strongest text on the page.
              Text(
                article.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 10),

              // Source and time.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      article.sourceName ?? 'GirlStadium News',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article.timeAgo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description - GNews provides this even when content
              // is truncated, so it's shown as a short lead-in.
              if (article.description.trim().isNotEmpty) ...[
                Text(
                  article.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Available content - only whatever GNews actually
              // provided. Never fabricated, and skipped entirely
              // when there's nothing beyond the description.
              if (_hasDistinctContent)
                ...article.content.map((paragraph) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      paragraph,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  );
                }),

              // Preview notice + Read Full Article action - only for
              // real GNews articles (they have a source URL). Local
              // static articles already contain their full content,
              // so neither of these apply to them.
              if (_hasSourceUrl) ...[
                const SizedBox(height: 4),
                const Text(
                  "You're viewing an article preview.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Read the full story from the original publisher.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _handleReadFullArticle(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Read Full Article',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // The project has no URL-launching package (no url_launcher, no
  // platform channel) and this milestone explicitly forbids adding
  // one automatically. Copying the link uses Flutter's built-in
  // Clipboard API (part of the SDK, not a package) so the button is
  // genuinely functional rather than a no-op.
  void _handleReadFullArticle(BuildContext context) {
    final url = article.articleUrl;
    if (url == null || url.isEmpty) return;

    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Article link copied. Paste it in your browser to read the full story.',
        ),
      ),
    );
  }

  // Builds the article hero image: a controlled rounded image
  // (~170-190px tall, full content width, not full-bleed) when a
  // real GNews image is available, falling back to a polished
  // GirlStadium placeholder card of the same size otherwise or on
  // load failure.
  Widget _buildHeroImage() {
    const double height = 180;

    if (article.imageUrl == null || article.imageUrl!.isEmpty) {
      return _buildHeroFallback(height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        article.imageUrl!,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildHeroFallback(height),
      ),
    );
  }

  // A rounded, card-colored placeholder matching the hero image's
  // footprint, with a centered icon - used whenever there's no real
  // image to show, so the layout never leaves an empty gap.
  Widget _buildHeroFallback(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            article.icon,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}
