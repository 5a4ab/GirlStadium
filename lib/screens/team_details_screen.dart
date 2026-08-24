import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_card.dart';
import 'team_squad_screen.dart';

class TeamDetailsScreen extends StatefulWidget {
  final int teamId;

  const TeamDetailsScreen({super.key, required this.teamId});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  final FootballService _footballService = FootballService();

  bool _isLoading = true;
  String? _errorMessage;
  Team? _team;

  // Squad state is tracked separately so a squad problem never
  // affects the rest of the team details.
  bool _isSquadLoading = true;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadTeamDetails();
    _loadSquad();
  }

  // Requests the team details from the API. Makes exactly one
  // request per call - triggered once when the screen opens, and
  // again only if the user taps Retry.
  Future<void> _loadTeamDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _footballService.getTeamDetails(widget.teamId);
      setState(() {
        _team = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "Team details aren't available on your current API plan.",
          genericMessage: "Couldn't load team details right now.",
        );
        _isLoading = false;
      });
    }
  }

  // Requests the team's squad from the API. Runs once alongside the
  // team details request. A failure here never turns the whole
  // screen into an error state - the "Top Players" section simply
  // shows its own empty message.
  Future<void> _loadSquad() async {
    try {
      final result = await _footballService.getTeamSquad(widget.teamId);
      if (!mounted) return;
      setState(() {
        _players = result;
        _isSquadLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _players = [];
        _isSquadLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Team Details'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  // Decides what to show: a loading spinner, an error message with a
  // retry button, an unavailable message, or the team details.
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

    if (_team == null) {
      return _buildMessageState(
        icon: Icons.info_outline,
        iconColor: AppColors.textSecondary,
        title: 'Team details unavailable',
        subtitle: 'No information is available for this team right now.',
        showRetry: false,
      );
    }

    final team = _team!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Team logo and name.
          Center(
            child: Column(
              children: [
                _buildLogo(team.logo),
                const SizedBox(height: 14),
                Text(
                  team.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Team info card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Club Info',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildInfoRow('Country', team.country ?? '-'),
                const SizedBox(height: 10),
                _buildInfoRow('Founded', team.founded?.toString() ?? '-'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stadium info card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stadium',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildInfoRow('Name', team.venueName ?? '-'),
                const SizedBox(height: 10),
                _buildInfoRow('City', team.venueCity ?? '-'),
                const SizedBox(height: 10),
                _buildInfoRow('Address', team.venueAddress ?? '-'),
                const SizedBox(height: 10),
                _buildInfoRow(
                  'Capacity',
                  team.venueCapacity?.toString() ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Top Players section.
          const Text(
            'Top Players',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildTopPlayersSection(team),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Builds the horizontally scrollable "Top Players" preview, with a
  // "View All Players" button when there are more than 5 players.
  Widget _buildTopPlayersSection(Team team) {
    if (_isSquadLoading) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_players.isEmpty) {
      return const Text(
        'No player information available.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }

    final topPlayers = _players.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topPlayers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final player = topPlayers[index];
              return SizedBox(
                width: 100,
                child: PlayerCard(
                  name: player.name,
                  photo: player.photo,
                  position: player.position,
                ),
              );
            },
          ),
        ),
        if (_players.length > 5) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamSquadScreen(
                      teamId: widget.teamId,
                      teamName: team.name,
                    ),
                  ),
                );
              },
              child: const Text(
                'View All Players',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Builds the circular team logo, falling back to a placeholder
  // icon if there's no logo URL or it fails to load.
  Widget _buildLogo(String? logoUrl) {
    const double size = 84;

    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shield_outlined,
          color: AppColors.textSecondary,
          size: 40,
        ),
      );
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.card,
        padding: const EdgeInsets.all(12),
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.shield_outlined,
              color: AppColors.textSecondary,
              size: 40,
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds one label/value row used in the info cards.
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
                onPressed: _loadTeamDetails,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}