import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/player_card.dart';
import '../widgets/section_header.dart';
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
        child: CircularProgressIndicator(color: AppColors.accentPink),
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
        iconColor: AppColors.textMuted,
        title: 'Team information unavailable',
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
          const SizedBox(height: 8),

          FadeSlideIn(child: _buildHero(team)),

          const SizedBox(height: 16),

          FadeSlideIn(
            delay: const Duration(milliseconds: 60),
            child: _buildQuickInfo(team),
          ),

          const SizedBox(height: 22),

          FadeSlideIn(
            delay: const Duration(milliseconds: 110),
            child: _buildStadiumSection(team),
          ),

          const SizedBox(height: 22),

          FadeSlideIn(
            delay: const Duration(milliseconds: 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Top Players',
                  icon: Icons.stars_outlined,
                  subtitle: 'A first look at the squad.',
                ),
                const SizedBox(height: 14),
                _buildTopPlayersSection(team),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // The club-profile hero: a large crest on a layered gradient
  // backdrop with a subtle pink/violet glow, the team name, and a
  // compact country/founded caption. Uses only real team data.
  Widget _buildHero(Team team) {
    final metaParts = <String>[
      if (team.country != null && team.country!.isNotEmpty) team.country!,
      if (team.founded != null) 'Founded ${team.founded}',
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPink.withValues(alpha: 0.18),
                    AppColors.accentPink.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                _buildCrest(team.logo),
                const SizedBox(height: 16),
                Text(
                  team.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    metaParts.join(' · '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  // The large club crest, on a tonal circular backdrop. Falls back to
  // a placeholder icon if there's no logo URL or it fails to load.
  Widget _buildCrest(String? logoUrl) {
    const double size = 96;

    Widget placeholder() => const Icon(
          Icons.shield_outlined,
          color: AppColors.textMuted,
          size: 44,
        );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.5),
        ),
      ),
      child: logoUrl == null || logoUrl.isEmpty
          ? placeholder()
          : Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentPink,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // A compact at-a-glance strip: Country / Founded / Stadium, as
  // three equal tonal tiles.
  Widget _buildQuickInfo(Team team) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoTile(
            icon: Icons.flag_outlined,
            label: 'Country',
            value: team.country ?? '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickInfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Founded',
            value: team.founded?.toString() ?? '-',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickInfoTile(
            icon: Icons.stadium_outlined,
            label: 'Stadium',
            value: team.venueName ?? '-',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentPink, size: 17),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textWarm,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // The "Home Ground" section: stadium name, city, capacity, and
  // address, using only fields the API actually returned.
  Widget _buildStadiumSection(Team team) {
    final hasVenueData = team.venueName != null ||
        team.venueCity != null ||
        team.venueAddress != null ||
        team.venueCapacity != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Home Ground',
          icon: Icons.stadium_outlined,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderLavender.withValues(alpha: 0.35),
            ),
          ),
          child: !hasVenueData
              ? const Text(
                  'No stadium information available.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.venueName ?? 'Stadium',
                      style: const TextStyle(
                        color: AppColors.textWarm,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (team.venueCity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            team.venueCity!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (team.venueCapacity != null) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Capacity',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCapacity(team.venueCapacity!),
                        style: const TextStyle(
                          color: AppColors.textWarm,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (team.venueAddress != null &&
                        team.venueAddress!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Address',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        team.venueAddress!,
                        style: const TextStyle(
                          color: AppColors.textWarm,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  // Formats a capacity number with thousands separators (e.g.
  // "53,400"), without needing an extra package.
  String _formatCapacity(int capacity) {
    final digits = capacity.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // Builds the horizontally scrollable "Top Players" preview, with a
  // "View All Players" CTA when there are more than 5 players.
  Widget _buildTopPlayersSection(Team team) {
    if (_isSquadLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentPink),
        ),
      );
    }

    if (_players.isEmpty) {
      return const Text(
        'No player information available.',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }

    final topPlayers = _players.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topPlayers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final player = topPlayers[index];
              return SizedBox(
                width: 116,
                child: PlayerCard(
                  name: player.name,
                  photo: player.photo,
                  position: player.position,
                  number: player.number,
                ),
              );
            },
          ),
        ),
        if (_players.length > 5) ...[
          const SizedBox(height: 16),
          _buildViewAllPlayersButton(team),
        ],
      ],
    );
  }

  // The "View All Players" CTA - opens Team Squad with the current
  // team ID and name, unchanged navigation behavior.
  Widget _buildViewAllPlayersButton(Team team) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamSquadScreen(
                teamId: widget.teamId,
                teamName: team.name,
                teamLogo: team.logo,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.heroGradient),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View All Players',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWarm,
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
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
            if (showRetry) ...[
              const SizedBox(height: 18),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _loadTeamDetails,
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
          ],
        ),
      ),
    );
  }
}
