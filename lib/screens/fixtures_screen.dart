import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/api_constants.dart';
import '../models/fixture.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/fixture_card.dart';
import 'match_details_screen.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({super.key});

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  final FootballService _footballService = FootballService();

  // Keeps track of which date chip is selected. "Today" is selected by default.
  String _selectedDate = 'Today';

  // Keeps track of the currently selected league.
  String _selectedLeague = 'Premier League';

  // The leagues available in the dropdown, mapped to their
  // API-Football league IDs. Sourced from the shared constant so
  // this mapping only lives in one place.
  final Map<String, int> _leagueIds = ApiConstants.supportedLeagues;

  // Loading / error / data state for the fixtures request.
  bool _isLoading = true;
  String? _errorMessage;
  List<Fixture> _fixtures = [];

  @override
  void initState() {
    super.initState();
    _loadFixtures();
  }

  // Works out the football season year expected by the API.
  // A season is identified by the year it starts in (e.g. 2025 for
  // the 2025-2026 season). Seasons typically start around July.
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

  // Requests fixtures from the API based on the currently selected
  // date option and league.
  Future<void> _loadFixtures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final leagueId = _leagueIds[_selectedLeague];
      final season = _currentSeason();

      List<Fixture> result;

      if (_selectedDate == 'Yesterday') {
        final yesterday = now.subtract(const Duration(days: 1));
        result = await _footballService.getFixtures(
          date: _formatDate(yesterday),
          leagueId: leagueId,
          season: season,
        );
      } else if (_selectedDate == 'Today') {
        result = await _footballService.getFixtures(
          date: _formatDate(now),
          leagueId: leagueId,
          season: season,
        );
      } else {
        // Tomorrow.
        final tomorrow = now.add(const Duration(days: 1));
        result = await _footballService.getFixtures(
          date: _formatDate(tomorrow),
          leagueId: leagueId,
          season: season,
        );
      }

      setState(() {
        _fixtures = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "These fixtures aren't available on your current API plan.",
          genericMessage: "Couldn't load fixtures right now.",
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title with a search icon.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fixtures',
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

            // Date selector chips.
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildDateChip('Yesterday'),
                  const SizedBox(width: 10),
                  _buildDateChip('Today'),
                  const SizedBox(width: 10),
                  _buildDateChip('Tomorrow'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // League filter dropdown.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedLeague = value;
                  });
                  _loadFixtures();
                },
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) {
                  return _leagueIds.keys.map((league) {
                    return PopupMenuItem<String>(
                      value: league,
                      child: Text(
                        league,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedLeague,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Fixtures list / loading / error / empty state.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFixturesContent(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Decides what to show below the filters: a loading spinner, an
  // error message with a retry button, an empty state, or the list
  // of fixtures.
  Widget _buildFixturesContent() {
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
              onPressed: _loadFixtures,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_fixtures.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(
              Icons.sports_soccer_outlined,
              color: AppColors.textSecondary,
              size: 36,
            ),
            const SizedBox(height: 12),
            const Text(
              'No fixtures found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no matches scheduled for the selected date and league.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
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
              onPressed: () {
                // No functionality yet - the date chips and league
                // dropdown above already let the user try another
                // date or league.
              },
              child: const Text('Try Another Date'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _fixtures.map((fixture) {
        return FixtureCard(
          leagueName: fixture.league,
          homeTeam: fixture.homeTeam,
          awayTeam: fixture.awayTeam,
          time: fixture.formattedTime,
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
    );
  }

  // Builds one date chip (Yesterday / Today / Tomorrow).
  Widget _buildDateChip(String label) {
    final bool isSelected = _selectedDate == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedDate = label;
        });
        _loadFixtures();
      },
      backgroundColor: AppColors.card,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }
}