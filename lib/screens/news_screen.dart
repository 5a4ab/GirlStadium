import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/news_card.dart';
import 'news_details_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();

  // The categories shown as chips. "All" is not a real Article
  // category - it simply means no filtering is applied.
  static const List<String> _categories = [
    'All',
    'Transfers',
    'Premier League',
    'Champions League',
    'La Liga',
    'Players',
  ];

  String _selectedCategory = 'All';

  bool _isLoading = true;
  String? _errorMessage;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  // Loads articles through NewsService. Prefers the shared cache
  // (populated by whichever screen - Home or News - asks first), so
  // opening News after Home already loaded successfully makes 0
  // additional GNews requests. An explicit Retry passes
  // [forceRefresh] so a stale successful cache never blocks a request
  // the user actually asked for.
  Future<void> _loadArticles({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _newsService.getArticles(forceRefresh: forceRefresh);
      setState(() {
        _articles = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = newsErrorMessage(error);
        _isLoading = false;
      });
    }
  }

  // Returns only the articles matching the currently selected
  // category, or all articles when "All" is selected. Purely local
  // filtering over the already-loaded list - no additional request.
  List<Article> get _filteredArticles {
    if (_selectedCategory == 'All') return _articles;
    return _articles
        .where((article) => article.category == _selectedCategory)
        .toList();
  }

  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailsScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // Category chips.
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _buildCategoryChips(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // News feed.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: _buildArticlesContent(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // An editorial header - the same warm-white/muted language used
  // across the redesigned app, with a small pink glow for depth.
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPink.withValues(alpha: 0.16),
                  AppColors.accentPink.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Stories',
                style: TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Football news, without the noise.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Builds the category chips, with SizedBox spacers between them,
  // matching the original manual list layout.
  List<Widget> _buildCategoryChips() {
    final List<Widget> chips = [];
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      chips.add(
        _CategoryChip(
          label: category,
          isSelected: _selectedCategory == category,
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
      );
      if (i != _categories.length - 1) {
        chips.add(const SizedBox(width: 10));
      }
    }
    return chips;
  }

  // Decides what to show in the news feed area: a loading spinner, an
  // error message with a retry button, an empty state (no articles at
  // all, or none matching the selected category), or the featured
  // story plus supporting article cards.
  Widget _buildArticlesContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentPink),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _loadArticles(forceRefresh: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.heroGradient),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        title: 'No news available',
        subtitle: 'There is no news to show right now.',
      );
    }

    final filteredArticles = _filteredArticles;

    if (filteredArticles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.dynamic_feed_outlined,
        title: 'No stories here yet',
        subtitle: 'Try another category.',
      );
    }

    final featured = filteredArticles.first;
    final supporting = filteredArticles.skip(1).toList();

    return Column(
      children: [
        FeaturedArticleCard(
          article: featured,
          onTap: () => _openArticle(featured),
        ),
        if (supporting.isNotEmpty) ...[
          const SizedBox(height: 18),
          ...supporting.map((article) {
            return NewsCard(
              title: article.title,
              category: article.category,
              sourceName: article.sourceName,
              timeAgo: article.timeAgo,
              icon: article.icon,
              imageUrl: article.imageUrl,
              onTap: () => _openArticle(article),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLavender.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWarm,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// A single category chip shown at the top of the News feed.
// Highlights when it is the currently selected filter.
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: AppColors.heroGradient)
              : null,
          color: isSelected ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.borderLavender.withValues(alpha: 0.4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentPink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
