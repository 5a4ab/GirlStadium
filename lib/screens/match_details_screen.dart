import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/match_details.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/segmented_control.dart';
import '../widgets/stat_bar.dart';

const List<String> _matchTabs = ['Overview', 'Statistics', 'Events'];

const List<String> _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class MatchDetailsScreen extends StatefulWidget {
  // The fixture to load details for. When null (e.g. a sample card
  // with no real API data behind it), the screen simply shows the
  // "unavailable" state without making any API request.
  final int? fixtureId;

  const MatchDetailsScreen({super.key, this.fixtureId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final FootballService _footballService = FootballService();

  bool _isLoading = true;
  String? _errorMessage;
  MatchDetails? _matchDetails;

  // Which tab is currently selected. Purely local UI state - switching
  // tabs never triggers another API request, it just changes which
  // widget is built from the data already loaded above.
  String _selectedTab = 'Overview';

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  // Requests the match details from the API. Makes exactly one
  // request per call - this is only triggered once when the screen
  // opens, and again if the user taps Retry.
  Future<void> _loadMatchDetails() async {
    if (widget.fixtureId == null) {
      // No fixture ID to look up - nothing to request.
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _matchDetails = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _footballService.getMatchDetails(widget.fixtureId!);
      setState(() {
        _matchDetails = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "This match isn't available on your current API plan.",
          genericMessage: "Couldn't load match details right now.",
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Match Details'),
        actions: [
          IconButton(
            onPressed: () {
              // No functionality yet.
            },
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  // Decides what to show: a loading spinner, an error message with a
  // retry button, an unavailable message, or the full match details.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        title: _errorMessage!,
        showRetry: true,
      );
    }

    if (_matchDetails == null) {
      return _buildMessageState(
        icon: Icons.info_outline,
        iconColor: AppColors.textSecondary,
        title: 'Match details unavailable',
        subtitle: 'No details are available for this match right now.',
        showRetry: false,
      );
    }

    final match = _matchDetails!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          _buildHeaderCard(match),

          const SizedBox(height: 20),

          // Overview / Statistics / Events - a real segmented control.
          // Switching tabs only changes which widget below is built;
          // it never re-fetches match data.
          SegmentedControl(
            options: _matchTabs,
            selected: _selectedTab,
            onSelected: (tab) => setState(() => _selectedTab = tab),
          ),

          const SizedBox(height: 20),

          _buildTabContent(match),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Builds a centered message with an optional Retry button. Used
  // for both the error state and the "unavailable" empty state.
  Widget _buildMessageState({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool showRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            if (showRetry) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loadMatchDetails,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Picks which tab's content to show below the segmented control.
  // Reuses the already-loaded `match` - no branch here ever triggers
  // an API request.
  Widget _buildTabContent(MatchDetails match) {
    switch (_selectedTab) {
      case 'Statistics':
        return _buildStatsCard(match);
      case 'Events':
        return _buildEventsCard(match);
      case 'Overview':
      default:
        return _buildOverviewTab(match);
    }
  }

  // The Overview tab: a short match-info summary (kickoff, venue,
  // competition) rather than a repeat of the Statistics/Events tabs.
  Widget _buildOverviewTab(MatchDetails match) {
    final rows = <Widget>[
      _infoRow(Icons.emoji_events_outlined, 'Competition', match.leagueName),
    ];

    if (match.date != null) {
      rows.add(_infoRow(
        Icons.calendar_today_outlined,
        'Kickoff',
        _formatFullDateTime(match.date!),
      ));
    }

    if (match.venue != null) {
      rows.add(_infoRow(Icons.stadium_outlined, 'Venue', match.venue!));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Formats a full kickoff date/time, e.g. "24 Aug 2026 · 20:00".
  String _formatFullDateTime(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthAbbreviations[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month ${local.year} · $hour:$minute';
  }

  // Builds the match header card: league, both teams with logos, the
  // score (or kickoff time for matches that haven't started), status,
  // and venue.
  Widget _buildHeaderCard(MatchDetails match) {
    final isLive = match.isLive;
    final bool showScore = match.status != 'NS' &&
        match.homeScore != null &&
        match.awayScore != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (match.leagueLogo != null) ...[
                _buildLogo(match.leagueLogo, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  match.leagueName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isLive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTeamColumn(match.homeTeamLogo, match.homeTeamName),
              ),
              SizedBox(
                width: 96,
                child: Column(
                  children: [
                    if (showScore)
                      Text(
                        '${match.homeScoreDisplay} - ${match.awayScoreDisplay}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        match.statusLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (showScore) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (isLive ? AppColors.success : AppColors.primary)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.statusLabel,
                          style: TextStyle(
                            color: isLive ? AppColors.success : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _buildTeamColumn(match.awayTeamLogo, match.awayTeamName),
              ),
            ],
          ),
          if (match.venue != null) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    match.venue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // One team's logo + name, stacked, used on both sides of the header.
  Widget _buildTeamColumn(String? logoUrl, String name) {
    return Column(
      children: [
        _buildLogo(logoUrl, size: 48),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // A circular team/league badge. Falls back to a placeholder icon
  // when there's no logo URL or the image fails to load.
  Widget _buildLogo(String? url, {required double size}) {
    Widget placeholder() => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            size: size * 0.5,
            color: AppColors.textSecondary,
          ),
        );

    if (url == null || url.isEmpty) {
      return placeholder();
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder(),
        errorBuilder: (context, error, stackTrace) => placeholder(),
      ),
    );
  }

  // Builds the Statistics tab content using real statistics when
  // available - a clean empty state otherwise (not an API error).
  Widget _buildStatsCard(MatchDetails match) {
    if (match.statistics.isEmpty) {
      return _buildEmptyTabCard("Statistics aren't available for this match yet.");
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: match.statistics.map((stat) {
          return StatBar(
            label: stat.name,
            leftValue: stat.homeValue,
            rightValue: stat.awayValue,
            leftRatio: _statRatio(stat.homeValue, stat.awayValue),
          );
        }).toList(),
      ),
    );
  }

  // Works out the left-side ratio for the StatBar progress indicator
  // from two stat values. Falls back to an even split when the
  // values can't be compared numerically (e.g. missing data).
  double _statRatio(String homeValue, String awayValue) {
    final home = _parseStatNumber(homeValue);
    final away = _parseStatNumber(awayValue);
    if (home == null || away == null || (home + away) == 0) return 0.5;
    return home / (home + away);
  }

  double? _parseStatNumber(String value) {
    final cleaned = value.replaceAll('%', '').trim();
    return double.tryParse(cleaned);
  }

  // Builds the Events tab content using real events when available -
  // a clean empty state otherwise (not an API error).
  Widget _buildEventsCard(MatchDetails match) {
    if (match.events.isEmpty) {
      return _buildEmptyTabCard('No match events available yet.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(match.events.length, (index) {
          final event = match.events[index];
          final isLast = index == match.events.length - 1;

          return _EventRow(
            minute: event.minute != null ? "${event.minute}'" : '-',
            icon: _iconForEvent(event),
            iconColor: _colorForEvent(event),
            title: event.playerName ?? event.teamName ?? 'Unknown',
            subtitle: _eventSubtitle(event),
            isLast: isLast,
          );
        }),
      ),
    );
  }

  // Builds a short secondary line for an event row from whichever of
  // team / detail / assist are actually present, e.g.
  // "Manchester City · Normal Goal · Assist: Kevin De Bruyne".
  String? _eventSubtitle(MatchEvent event) {
    final parts = <String>[
      if (event.teamName != null) event.teamName!,
      if (event.detail != null) event.detail!,
      if (event.assistName != null) 'Assist: ${event.assistName}',
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  // A shared empty state for the Statistics/Events tabs - this
  // represents "nothing to show yet", not an API error.
  Widget _buildEmptyTabCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  // Picks a built-in icon based on the event type.
  IconData _iconForEvent(MatchEvent event) {
    switch (event.type) {
      case 'Goal':
        return Icons.sports_soccer;
      case 'Card':
        return Icons.square;
      case 'subst':
        return Icons.swap_horiz;
      default:
        return Icons.info_outline;
    }
  }

  // Picks a color based on the event type/detail (e.g. red vs yellow
  // card).
  Color _colorForEvent(MatchEvent event) {
    switch (event.type) {
      case 'Goal':
        return AppColors.success;
      case 'Card':
        if (event.detail != null && event.detail!.toLowerCase().contains('red')) {
          return AppColors.error;
        }
        return Colors.amber;
      case 'subst':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

// One row in the match events timeline.
class _EventRow extends StatelessWidget {
  final String minute;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isLast;

  const _EventRow({
    required this.minute,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              minute,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}