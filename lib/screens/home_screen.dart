import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/fixture.dart';
import '../models/lesson.dart';
import '../models/article.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../constants/api_constants.dart';
import '../constants/lessons_data.dart';
import '../constants/news_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/featured_player_card.dart';
import '../widgets/home_background.dart';
import '../widgets/match_card.dart';
import '../widgets/fixture_card.dart';
import '../widgets/learn_card.dart';
import '../widgets/learn_preview_card.dart';
import '../widgets/news_card.dart';
import '../widgets/news_preview_card.dart';
import '../widgets/section_header.dart';
import 'match_details_screen.dart';
import 'lesson_details_screen.dart';
import 'news_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FootballService _footballService = FootballService();

  // The Premier League - same league ID used on the Fixtures and
  // Standings screens.
  static const int _leagueId = 39;

  bool _isLoading = true;
  String? _errorMessage;
  List<Fixture> _fixtures = [];

  // The player featured on Home. Mohamed Salah's API-Football player
  // ID - only the ID is hardcoded, the rest of the card's content
  // (name, club, nationality, photo) comes from the real API response.
  static const int _featuredPlayerId = 306;

  bool _isFeaturedPlayerLoading = true;
  String? _featuredPlayerErrorMessage;
  Player? _featuredPlayer;

  // Local search - filters the local lessons/articles lists only.
  // No API request is involved in searching.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _loadFixtures();
    _loadFeaturedPlayer();
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Works out the football season year expected by the API. Matches
  // the same calculation used on the Fixtures screen.
  int _currentSeason() {
    final now = DateTime.now();
    return now.month >= 7 ? now.year : now.year - 1;
  }

  // Formats a DateTime as 'YYYY-MM-DD', which is what the API expects.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Requests today's fixtures from the API. Makes exactly ONE request -
  // the result is then split locally into "live" and "upcoming" for
  // the two Home sections below, so no extra requests are needed.
  Future<void> _loadFixtures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _footballService.getFixtures(
        date: _formatDate(DateTime.now()),
        leagueId: _leagueId,
        season: _currentSeason(),
      );
      setState(() {
        _fixtures = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "These fixtures aren't available on your current API plan.",
          genericMessage: "Couldn't load matches",
        );
        _isLoading = false;
      });
    }
  }

  // Requests the Home featured player from the API. Makes exactly one
  // request - triggered once in initState(), independent of the
  // fixtures request above, so a slow/failed lookup never blocks the
  // rest of Home.
  Future<void> _loadFeaturedPlayer() async {
    setState(() {
      _isFeaturedPlayerLoading = true;
      _featuredPlayerErrorMessage = null;
    });

    try {
      final result = await _footballService.getPlayerProfile(
        playerId: _featuredPlayerId,
        // The Free plan only has data access for this season - reuse
        // the same season used for Standings.
        season: ApiConstants.standingsSeason,
      );
      setState(() {
        _featuredPlayer = result;
        _isFeaturedPlayerLoading = false;
      });
    } catch (error) {
      setState(() {
        _featuredPlayerErrorMessage = apiErrorMessage(
          error,
          planMessage:
              "The featured player isn't available on your current API plan.",
          genericMessage: "Couldn't load the featured player right now.",
        );
        _isFeaturedPlayerLoading = false;
      });
    }
  }

  List<Fixture> get _liveFixtures =>
      _fixtures.where((fixture) => fixture.isLive).toList();

  List<Fixture> get _upcomingFixtures =>
      _fixtures.where((fixture) => fixture.isUpcoming).toList();

  // Lessons matching the current search query (title or description).
  // Purely local filtering over lessons_data.dart - no API request.
  List<Lesson> get _matchingLessons {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return lessons.where((lesson) {
      return lesson.title.toLowerCase().contains(query) ||
          lesson.description.toLowerCase().contains(query);
    }).toList();
  }

  // Articles matching the current search query (title or description).
  // Purely local filtering over news_data.dart - no API request.
  List<Article> get _matchingArticles {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(query) ||
          article.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand header.
              const CustomAppBar(),

              // Greeting section.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Good Evening 👋',
                      style: TextStyle(
                        color: AppColors.textWarm,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ready to discover today's football?",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search bar. Searches local lessons and news articles only.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBase,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _searchFocused
                          ? AppColors.accentPink
                          : AppColors.borderLavender.withValues(alpha: 0.5),
                      width: _searchFocused ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: _searchFocused
                            ? AppColors.accentPink
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim();
                            });
                          },
                          style: const TextStyle(color: AppColors.textWarm),
                          decoration: const InputDecoration(
                            hintText: 'Search lessons, news...',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Search results - only shown while actively searching.
              // Purely local, no API request.
              if (_searchQuery.isNotEmpty) ...[
                _buildSearchResultsSection(),
                const SizedBox(height: 24),
              ],

              // Football data (Live & Upcoming), backed by a single
              // /fixtures request loaded once in initState().
              FadeSlideIn(
                child: _buildFootballSection(),
              ),

              const SizedBox(height: 28),

              // Featured Player section. Loads real API data once in
              // initState(), independent of the fixtures request above.
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Featured Player',
                        icon: Icons.star_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildFeaturedPlayerSection(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Learn Football section.
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: _buildLearnSection(),
              ),

              const SizedBox(height: 28),

              // Latest News section.
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _buildNewsSection(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Decides what to show for the Featured Player section: a small
  // loading indicator, a simple fallback message, or the real
  // FeaturedPlayerCard - all inside a stable-height container so the
  // section's footprint stays stable while loading.
  Widget _buildFeaturedPlayerSection() {
    if (_isFeaturedPlayerLoading) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentPink,
            ),
          ),
        ),
      );
    }

    if (_featuredPlayerErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          _featuredPlayerErrorMessage!,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    if (_featuredPlayer == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          'No featured player available right now.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    return FeaturedPlayerCard(
      playerName: _featuredPlayer!.name,
      clubName: _featuredPlayer!.team ?? '-',
      nationality: _featuredPlayer!.nationality ?? '-',
      photoUrl: _featuredPlayer!.photo,
    );
  }

  // Builds the local search results section, shown only while the
  // search bar has text. Searches lessons and articles only - never
  // the football API. Reuses the shared LearnCard/NewsCard so this
  // stays consistent with the Learn and News screens.
  Widget _buildSearchResultsSection() {
    final matchingLessons = _matchingLessons;
    final matchingArticles = _matchingArticles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Search Results',
            icon: Icons.search,
          ),
          const SizedBox(height: 12),
          if (matchingLessons.isEmpty && matchingArticles.isEmpty)
            const Text(
              'No results found',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            )
          else ...[
            ...matchingLessons.map((lesson) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LearnCard(
                  title: lesson.title,
                  description: lesson.description,
                  readTime: lesson.readTime,
                  icon: lesson.icon,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonDetailsScreen(
                          lesson: lesson,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            ...matchingArticles.map((article) {
              return NewsCard(
                title: article.title,
                description: article.description,
                timeAgo: article.timeAgo,
                icon: article.icon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailsScreen(
                        article: article,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  // Decides what to show for the football data area: a loading
  // spinner, an error message with a retry button, or the Live &
  // Upcoming sections built from the same request.
  Widget _buildFootballSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentPink),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _loadFixtures,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final liveFixtures = _liveFixtures;
    final upcomingFixtures = _upcomingFixtures;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Live & Upcoming',
            icon: Icons.bolt_rounded,
            subtitle: liveFixtures.isEmpty
                ? "Today's Premier League fixtures"
                : '${liveFixtures.length} match${liveFixtures.length == 1 ? '' : 'es'} live now',
          ),
        ),
        const SizedBox(height: 14),
        if (liveFixtures.isNotEmpty) ...[
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: liveFixtures.map((fixture) {
                return MatchCard(
                  fixture: fixture,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchDetailsScreen(
                          fixtureId: fixture.id,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: upcomingFixtures.isEmpty
              ? const Text(
                  'No upcoming fixtures',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                )
              : Column(
                  children: upcomingFixtures.map((fixture) {
                    return FixtureCard(
                      fixture: fixture,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailsScreen(
                              fixtureId: fixture.id,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // Builds the "Learn Football" preview: the first few lessons shown
  // as a horizontally scrollable row of richer cards. Purely local
  // data (lessons_data.dart) - no API request.
  Widget _buildLearnSection() {
    final previewLessons = lessons.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Learn Football',
            icon: Icons.menu_book_rounded,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: previewLessons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final lesson = previewLessons[index];
              return LearnPreviewCard(
                title: lesson.title,
                category: lesson.category,
                readTime: lesson.readTime,
                icon: lesson.icon,
                gradient: AppColors.accentGradientForIndex(index),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailsScreen(lesson: lesson),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Builds the "Latest News" preview: the first article as one large
  // featured story and the next two as smaller supporting cards.
  // Purely local data (news_data.dart) - no additional GNews request.
  Widget _buildNewsSection() {
    if (articles.isEmpty) return const SizedBox.shrink();

    final featured = articles.first;
    final supporting = articles.skip(1).take(2).toList();

    void openArticle(Article article) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailsScreen(article: article),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Latest Stories',
            icon: Icons.newspaper_rounded,
          ),
          const SizedBox(height: 12),
          FeaturedNewsCard(
            title: featured.title,
            category: featured.category,
            timeAgo: featured.timeAgo,
            icon: featured.icon,
            gradient: AppColors.accentGradientForIndex(0),
            onTap: () => openArticle(featured),
          ),
          if (supporting.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(supporting.length, (index) {
              final article = supporting[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == supporting.length - 1 ? 0 : 10,
                ),
                child: NewsPreviewCard(
                  title: article.title,
                  category: article.category,
                  timeAgo: article.timeAgo,
                  icon: article.icon,
                  gradient: AppColors.accentGradientForIndex(index + 1),
                  onTap: () => openArticle(article),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
