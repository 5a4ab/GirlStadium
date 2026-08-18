import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/article.dart';
import '../services/news_service.dart';
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

  // Loads articles through NewsService. Makes exactly one GNews
  // request per load/retry - never automatically, and never more
  // than once per call.
  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _newsService.getArticles();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar with title and search icon.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Football News',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Featured news card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.campaign,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Breaking News',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mbappé scores twice as Real Madrid wins season opener',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Real Madrid started the season in style, with Kylian '
                          'Mbappé netting a brace to secure a comfortable win '
                          'at the Santiago Bernabéu.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '2 hours ago',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category chips.
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _buildCategoryChips(),
              ),
            ),

            const SizedBox(height: 20),

            // News feed.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildArticlesContent(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
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
  // all, or none matching the selected category), or the article
  // cards.
  Widget _buildArticlesContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _loadArticles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(
              Icons.article_outlined,
              color: AppColors.textSecondary,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'No news available',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There is no news to show right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final filteredArticles = _filteredArticles;

    if (filteredArticles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No articles in this category',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      children: filteredArticles.map((article) {
        return NewsCard(
          title: article.title,
          description: article.description,
          timeAgo: article.timeAgo,
          icon: article.icon,
          imageUrl: article.imageUrl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailsScreen(article: article),
              ),
            );
          },
        );
      }).toList(),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
