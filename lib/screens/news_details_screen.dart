import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/article.dart';
import '../widgets/app_back_button.dart';
import '../widgets/fade_slide_in.dart';

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              FadeSlideIn(child: _buildHero()),

              const SizedBox(height: 22),

              // Description - GNews provides this even when content
              // is truncated, so it's shown as a short lead-in.
              if (article.description.trim().isNotEmpty)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      article.description,
                      style: const TextStyle(
                        color: AppColors.textWarm,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),

              // Available content - only whatever GNews actually
              // provided. Never fabricated, and skipped entirely
              // when there's nothing beyond the description.
              if (_hasDistinctContent)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: article.content.map((paragraph) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          paragraph,
                          style: const TextStyle(
                            color: AppColors.textWarm,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Preview notice + full-story action - only for real
              // GNews articles (they have a source URL). Local static
              // articles already contain their full content, so
              // neither applies to them.
              if (_hasSourceUrl)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildPreviewNotice(),
                      const SizedBox(height: 20),
                      _buildCopyLinkButton(context),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // A short callout explaining that this is a preview, not the full
  // story - with more specific wording when GNews actually truncated
  // the content (article.isTruncated), so the app never implies a
  // full article was loaded when it wasn't.
  Widget _buildPreviewNotice() {
    final message = article.isTruncated
        ? 'This preview is shortened. Open the original story to read '
            'the full article.'
        : "You're viewing an article preview. Read the full story from "
            'the original publisher.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentViolet.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentViolet.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.accentViolet,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The project has no URL-launching package (no url_launcher, no
  // platform channel) so this only copies the link to the clipboard -
  // the label and icon say exactly that, rather than implying it
  // opens a browser.
  Widget _buildCopyLinkButton(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleCopyLink(context),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.heroGradient),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Copy Article Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCopyLink(BuildContext context) {
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

  // The article hero: a large image (or branded fallback), category
  // badge, headline, and source/time.
  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildHeroImage(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        const SizedBox(height: 12),
        Text(
          article.title,
          style: const TextStyle(
            color: AppColors.textWarm,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: Text(
                article.sourceName ?? 'GirlStadium News',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
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
                color: AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              article.timeAgo,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Builds the article hero image: a large rounded image, full
  // content width, when a real GNews image is available, falling
  // back to a polished GirlStadium placeholder of the same size
  // otherwise or on load failure.
  Widget _buildHeroImage() {
    const double height = 220;

    if (article.imageUrl == null || article.imageUrl!.isEmpty) {
      return _buildHeroFallback(height);
    }

    return Image.network(
      article.imageUrl!,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildHeroFallback(height),
    );
  }

  // A rounded, gradient placeholder matching the hero image's
  // footprint, with a centered icon - used whenever there's no real
  // image to show, so the layout never leaves an empty gap.
  Widget _buildHeroFallback(double height) {
    return Container(
      width: double.infinity,
      height: height,
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
          color: Colors.white.withValues(alpha: 0.4),
          size: 56,
        ),
      ),
    );
  }
}
