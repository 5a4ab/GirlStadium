import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/api_constants.dart';
import '../models/fixture.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/fixture_card.dart';
import '../widgets/segmented_control.dart';
import 'match_details_screen.dart';

// The date options shown on the Fixtures screen, matching exactly
// what the current API plan supports (yesterday, today, tomorrow).
const List<String> _dateOptions = ['Yesterday', 'Today', 'Tomorrow'];

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

  // All fixtures returned for the currently selected date, across every
  // league. Kept around so switching leagues can filter locally instead
  // of making another request.
  List<Fixture> _rawFixtures = [];

  // The fixtures actually shown: `_rawFixtures` filtered down to the
  // currently selected league.
  List<Fixture> _fixtures = [];

  @override
  void initState() {
    super.initState();
    _loadFixtures();
  }

  // Keeps only the fixtures that belong to the currently selected
  // league, matched by API-Football league ID (not display name).
  List<Fixture> _filterByLeague(List<Fixture> fixtures) {
    final leagueId = _leagueIds[_selectedLeague];
    return fixtures.where((fixture) => fixture.leagueId == leagueId).toList();
  }

  // Resolves the DateTime for the currently selected date chip.
  DateTime _resolveSelectedDate() {
    final now = DateTime.now();
    if (_selectedDate == 'Yesterday') {
      return now.subtract(const Duration(days: 1));
    }
    if (_selectedDate == 'Tomorrow') {
      return now.add(const Duration(days: 1));
    }
    return now;
  }

  // Formats a DateTime as 'YYYY-MM-DD', which is what the API expects.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Requests fixtures from the API for the currently selected date.
  //
  // Sends only `date` - no `league` and no `season`. API-Football's
  // Free plan rejects the current (2026) season when filtering by
  // league, but a plain date-only request still returns every
  // fixture for that day across all leagues. League filtering is
  // then done locally in `_filterByLeague`, so switching leagues
  // never needs another request.
  Future<void> _loadFixtures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final date = _resolveSelectedDate();
      final result = await _footballService.getFixtures(
        date: _formatDate(date),
      );

      setState(() {
        _rawFixtures = result;
        _fixtures = _filterByLeague(result);
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
            // Screen title.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Fixtures',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Date selector: a full-width segmented control for
            // Yesterday / Today / Tomorrow.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedControl(
                options: _dateOptions,
                selected: _selectedDate,
                onSelected: (label) {
                  if (label == _selectedDate) return;
                  setState(() {
                    _selectedDate = label;
                  });
                  _loadFixtures();
                },
              ),
            ),

            const SizedBox(height: 16),

            // League filter dropdown.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  // League changes are filtered locally from the
                  // fixtures already loaded for the selected date -
                  // no new API request.
                  setState(() {
                    _selectedLeague = value;
                    _fixtures = _filterByLeague(_rawFixtures);
                  });
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
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedLeague,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
          ],
        ),
      );
    }

    return Column(
      children: _fixtures.map((fixture) {
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
    );
  }
}
