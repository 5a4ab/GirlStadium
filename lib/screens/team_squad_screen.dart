import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../services/football_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/player_card.dart';

class TeamSquadScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  // Optional - passed straight through from Team Details when
  // available, so the header can show the crest without an extra
  // network request. Safe to omit (e.g. if this screen is ever
  // opened from elsewhere without a logo on hand).
  final String? teamLogo;

  const TeamSquadScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
  });

  @override
  State<TeamSquadScreen> createState() => _TeamSquadScreenState();
}

class _TeamSquadScreenState extends State<TeamSquadScreen> {
  final FootballService _footballService = FootballService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  // Requests the full squad from the API. Makes exactly one request
  // per call - triggered once when the screen opens, and again only
  // if the user taps Retry.
  Future<void> _loadSquad() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _footballService.getTeamSquad(widget.teamId);
      setState(() {
        _players = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = apiErrorMessage(
          error,
          planMessage: "This squad isn't available on your current API plan.",
          genericMessage: "Couldn't load squad",
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
        title: const Text('Squad'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  // Decides what to show: a loading spinner, an error message with a
  // retry button, an empty message, or the squad grid.
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

    if (_players.isEmpty) {
      return _buildMessageState(
        icon: Icons.groups_outlined,
        iconColor: AppColors.textMuted,
        title: 'No squad available',
        subtitle: 'There are no players listed for this team right now.',
        showRetry: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: FadeSlideIn(child: _buildHeader()),
        ),
        Expanded(
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return PlayerCard(
                  name: player.name,
                  photo: player.photo,
                  position: player.position,
                  number: player.number,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // The squad header: crest (if available), team name, and player
  // count - all from data already on hand, no extra request.
  Widget _buildHeader() {
    return Row(
      children: [
        _buildCrest(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_players.length} player${_players.length == 1 ? '' : 's'} · Squad',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCrest() {
    const double size = 52;
    final logoUrl = widget.teamLogo;

    Widget placeholder() => const Icon(
          Icons.shield_outlined,
          color: AppColors.textMuted,
          size: 24,
        );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.45),
        ),
      ),
      child: logoUrl == null || logoUrl.isEmpty
          ? placeholder()
          : Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => placeholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder(),
            ),
    );
  }

  // Builds a centered message with an optional Retry button. Used
  // for both the error state and the empty state.
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
                  onTap: _loadSquad,
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
