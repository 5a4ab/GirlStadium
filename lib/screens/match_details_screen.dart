import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/match_details.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/stat_bar.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Match Details',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
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

          // Tabs (visual only, Overview is active).
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab('Overview', isActive: true),
                _buildTab('Statistics', isActive: false),
                _buildTab('Events', isActive: false),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Match Statistics section.
          const Text(
            'Match Stats',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildStatsCard(match),

          const SizedBox(height: 24),

          // Match Events section.
          const Text(
            'Match Events',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildEventsCard(match),

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

  // Builds the match header card (league, score, status, venue).
  Widget _buildHeaderCard(MatchDetails match) {
    final isLive = match.isLive;

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
              Text(
                match.leagueName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
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
          const SizedBox(height: 16),
          Text(
            '${match.homeTeamName} vs ${match.awayTeamName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${match.homeScoreDisplay} - ${match.awayScoreDisplay}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isLive ? AppColors.success : AppColors.primary)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              match.statusLabel,
              style: TextStyle(
                color: isLive ? AppColors.success : AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (match.venue != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  match.venue!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Builds the Match Stats card using real statistics when available.
  Widget _buildStatsCard(MatchDetails match) {
    if (match.statistics.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No statistics available yet.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
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

  // Builds the Match Events card using real events when available.
  Widget _buildEventsCard(MatchDetails match) {
    if (match.events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No events yet',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
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
            description: event.playerName ?? event.teamName ?? 'Unknown',
            isLast: isLast,
          );
        }),
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

  // Builds one tab item for the visual-only tab bar.
  Widget _buildTab(String label, {required bool isActive}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// One row in the match events timeline.
class _EventRow extends StatelessWidget {
  final String minute;
  final IconData icon;
  final Color iconColor;
  final String description;
  final bool isLast;

  const _EventRow({
    required this.minute,
    required this.icon,
    required this.iconColor,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
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
            child: Text(
              description,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}