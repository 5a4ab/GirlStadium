import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/api_constants.dart';
import '../models/standing.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/standing_row.dart';
import 'team_details_screen.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final FootballService _footballService = FootballService();

  // Keeps track of the currently selected league.
  String _selectedLeague = 'Premier League';

  // The leagues available in the dropdown, mapped to their
  // API-Football league IDs. Sourced from the shared constant so
  // this mapping only lives in one place.
  final Map<String, int> _leagueIds = ApiConstants.supportedLeagues;

  // Loading / error / data state for the standings request.
  bool _isLoading = true;
  String? _errorMessage;
  List<Standing> _standings = [];

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  // Requests standings from the API for the currently selected league.
  Future<void> _loadStandings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leagueId = _leagueIds[_selectedLeague]!;

      final result = await _footballService.getStandings(
        leagueId: leagueId,
        season: ApiConstants.standingsSeason,
      );

      setState(() {
        _standings = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "These standings aren't available on your current API plan.",
          genericMessage: "Couldn't load standings right now.",
        );
        _isLoading = false;
      });
    }
  }

  // Decides the indicator color for a given position, based on the
  // actual number of teams returned rather than assuming a fixed size.
  Color? _indicatorColorFor(int position, int totalTeams) {
    if (position <= 4) return AppColors.success;
    if (position == 5) return Colors.blue;
    if (position > totalTeams - 3) return AppColors.error;
    return null;
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
                    'Standings',
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

            // League selector dropdown.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedLeague = value;
                  });
                  _loadStandings();
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

            // Table header.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Club',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'P',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'GD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Pts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // League table / loading / error / empty state.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStandingsContent(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Decides what to show below the header: a loading spinner, an
  // error message with a retry button, an empty state, or the table.
  Widget _buildStandingsContent() {
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
              onPressed: _loadStandings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_standings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              color: AppColors.textSecondary,
              size: 36,
            ),
            SizedBox(height: 12),
            Text(
              'No standings found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'There is no standings table available for this league yet.',
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

    final totalTeams = _standings.length;

    return Column(
      children: _standings.map((standing) {
        return StandingRow(
          position: standing.position,
          clubName: standing.teamName,
          played: standing.played,
          goalDifference: standing.formattedGoalDifference,
          points: standing.points,
          indicatorColor: _indicatorColorFor(standing.position, totalTeams),
          onTap: () {
            if (standing.teamId == null) {
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailsScreen(
                  teamId: standing.teamId!,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}