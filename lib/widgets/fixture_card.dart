import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/fixture.dart';

// A card that shows one football fixture: both teams (with logos)
// and the score/time/status appropriate for its current state
// (upcoming, live, or finished). The league isn't repeated on the
// card itself - callers only ever show fixtures already filtered to
// one league, so that context lives in the filter above the list.
class FixtureCard extends StatelessWidget {
  final Fixture fixture;

  // Optional tap callback. When null, the card is not tappable.
  final VoidCallback? onTap;

  const FixtureCard({
    super.key,
    required this.fixture,
    this.onTap,
  });

  // Scores are only shown once the match has actually kicked off -
  // never a fabricated "0 - 0" for a fixture that hasn't started.
  bool get _showScore =>
      !fixture.isUpcoming && fixture.homeScore != null && fixture.awayScore != null;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(18);
    final isLive = fixture.isLive;

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: cardRadius,
        border: Border.all(
          color: isLive
              ? AppColors.accentPink.withValues(alpha: 0.55)
              : AppColors.borderLavender.withValues(alpha: 0.35),
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.accentPink.withValues(alpha: 0.16),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _buildStatusBadge(),
          ),
          const SizedBox(height: 10),
          _buildTeamRow(fixture.homeTeamLogo, fixture.homeTeam, fixture.homeScoreDisplay),
          const SizedBox(height: 10),
          _buildTeamRow(fixture.awayTeamLogo, fixture.awayTeam, fixture.awayScoreDisplay),
        ],
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: cardContent,
      ),
    );
  }

  // One row for a team: logo, name (ellipsized so it never overflows
  // on small screens), and its score once the match has started.
  Widget _buildTeamRow(String? logoUrl, String name, String scoreDisplay) {
    return Row(
      children: [
        _buildLogo(logoUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textWarm,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_showScore) ...[
          const SizedBox(width: 8),
          Text(
            scoreDisplay,
            style: const TextStyle(
              color: AppColors.textWarm,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  // A small circular team badge on a tonal backdrop. Falls back to a
  // placeholder icon when there's no logo URL or the image fails to
  // load.
  Widget _buildLogo(String? url) {
    const double size = 34;

    Widget placeholder() => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.surfaceBase,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 17,
            color: AppColors.textMuted,
          ),
        );

    Widget logo = url == null || url.isEmpty
        ? placeholder()
        : ClipOval(
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

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        shape: BoxShape.circle,
      ),
      child: logo,
    );
  }

  // The right-aligned status pill: kickoff time for upcoming
  // fixtures, a live indicator with the minute when available, "FT"
  // for finished matches, or the raw status for anything else
  // (postponed, cancelled, etc).
  Widget _buildStatusBadge() {
    if (fixture.isLive) {
      final label = fixture.minuteLabel.isNotEmpty ? 'LIVE · ${fixture.minuteLabel}' : 'LIVE';
      return _badge(label, AppColors.accentPink, filled: true);
    }

    if (fixture.status == 'FT') {
      return _badge('FT', AppColors.textMuted);
    }

    if (fixture.isUpcoming) {
      return _badge(fixture.formattedTime, AppColors.accentViolet);
    }

    final label = fixture.status;
    if (label == null || label.isEmpty) {
      return _badge(fixture.formattedTime, AppColors.accentViolet);
    }
    return _badge(label, AppColors.textMuted);
  }

  Widget _badge(String label, Color color, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
