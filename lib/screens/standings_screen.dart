import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/api_constants.dart';
import '../models/standing.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/fade_slide_in.dart';
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

  // Decides the rank-group accent color for a given position, based
  // on the actual number of teams returned rather than assuming a
  // fixed size. Purely visual grouping - never labeled as a specific
  // competition zone (qualification rules differ per league/season).
  Color? _indicatorColorFor(int position, int totalTeams) {
    if (position <= 4) return AppColors.accentPink;
    if (position == 5) return AppColors.accentViolet;
    if (position > totalTeams - 3) return AppColors.error.withValues(alpha: 0.7);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // League selector + competition summary.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeagueSelector(),
                    const SizedBox(height: 16),
                    _buildCompetitionSummary(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Table header.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: _buildTableHeader(),
              ),
            ),

            const SizedBox(height: 8),

            // League table / loading / error / empty state.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _buildStandingsContent(),
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
                'Standings',
                style: TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "See who's leading the competition.",
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

  // The league selector, visually aligned with the redesigned
  // Fixtures league selector (same behavior: selecting a league
  // triggers exactly one new standings request).
  Widget _buildLeagueSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedLeague = value;
        });
        _loadStandings();
      },
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.borderLavender.withValues(alpha: 0.4),
        ),
      ),
      itemBuilder: (context) {
        return _leagueIds.keys.map((league) {
          return PopupMenuItem<String>(
            value: league,
            child: Text(
              league,
              style: const TextStyle(color: AppColors.textWarm),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLavender.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.heroGradient),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedLeague,
                style: const TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // A compact competition summary: the selected league and season,
  // using only real selected-state data (no invented competition
  // details, no extra request).
  Widget _buildCompetitionSummary() {
    return Row(
      children: [
        const Icon(
          Icons.leaderboard_outlined,
          color: AppColors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Season ${ApiConstants.standingsSeason} · League Table',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Mirrors StandingRow's column layout (accent strip + rank + logo +
  // club + P/GD/Pts) so headers line up exactly with the data below.
  Widget _buildTableHeader() {
    const labelStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: const [
        // These widths mirror StandingRow's accent strip + position +
        // logo lead-in exactly (3 + 10 + 20 + 8 + 30 + 10 = 81) so the
        // header labels line up with the data columns below.
        SizedBox(width: 3),
        SizedBox(width: 10),
        SizedBox(width: 20, child: Text('#', style: labelStyle)),
        SizedBox(width: 8),
        SizedBox(width: 30),
        SizedBox(width: 10),
        Expanded(flex: 3, child: Text('Club', style: labelStyle)),
        Expanded(
          child: Text('P', textAlign: TextAlign.center, style: labelStyle),
        ),
        Expanded(
          child: Text('GD', textAlign: TextAlign.center, style: labelStyle),
        ),
        Expanded(
          child: Text('Pts', textAlign: TextAlign.center, style: labelStyle),
        ),
      ],
    );
  }

  // Decides what to show below the header: a loading spinner, an
  // error message with a retry button, an empty state, or the table.
  Widget _buildStandingsContent() {
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
                onTap: _loadStandings,
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

    if (_standings.isEmpty) {
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
              child: const Icon(
                Icons.leaderboard_outlined,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No standings available',
              style: TextStyle(
                color: AppColors.textWarm,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "There isn't a table available for this competition right now.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final totalTeams = _standings.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: List.generate(_standings.length, (index) {
          final standing = _standings[index];
          return StandingRow(
            position: standing.position,
            clubName: standing.teamName,
            teamLogo: standing.teamLogo,
            played: standing.played,
            goalDifference: standing.formattedGoalDifference,
            points: standing.points,
            indicatorColor: _indicatorColorFor(standing.position, totalTeams),
            isLast: index == _standings.length - 1,
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
        }),
      ),
    );
  }
}
