import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// One row in the league standings table. Rows sit inside a single
// shared table container (built by StandingsScreen) - this widget
// only renders its own content plus a subtle bottom divider, not a
// separate card, so the table reads as one compact list.
class StandingRow extends StatelessWidget {
  final int position;
  final String clubName;
  final String? teamLogo;
  final int played;
  final String goalDifference;
  final int points;

  // Optional thin left-edge accent (e.g. pink for the top group, muted
  // red for the bottom group). Purely visual - never labeled as a
  // specific competition zone. Pass null for no accent.
  final Color? indicatorColor;

  // Whether this is the last row - suppresses the bottom divider.
  final bool isLast;

  // Optional tap callback. When null, the row simply doesn't respond
  // to taps (InkWell handles a null onTap safely on its own).
  final VoidCallback? onTap;

  const StandingRow({
    super.key,
    required this.position,
    required this.clubName,
    this.teamLogo,
    required this.played,
    required this.goalDifference,
    required this.points,
    this.indicatorColor,
    this.isLast = false,
    this.onTap,
  });

  bool get _isLeader => position == 1;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isLeader
          ? AppColors.accentPink.withValues(alpha: 0.07)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: AppColors.borderLavender.withValues(alpha: 0.22),
                    ),
                  ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Rank-group accent strip.
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: indicatorColor ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),

              // Position number.
              SizedBox(
                width: 20,
                child: Text(
                  '$position',
                  style: TextStyle(
                    color: _isLeader ? AppColors.accentPink : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              _buildLogo(),
              const SizedBox(width: 10),

              // Club name.
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        clubName,
                        style: const TextStyle(
                          color: AppColors.textWarm,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isLeader) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.accentPink,
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ),

              // Played.
              Expanded(
                child: Text(
                  '$played',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),

              // Goal difference.
              Expanded(
                child: Text(
                  goalDifference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),

              // Points.
              Expanded(
                child: Text(
                  '$points',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWarm,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A small circular team crest on a tonal backdrop. Falls back to a
  // placeholder icon when there's no logo URL or the image fails to
  // load.
  Widget _buildLogo() {
    const double size = 30;

    Widget placeholder() => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.surfaceBase,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 15,
            color: AppColors.textMuted,
          ),
        );

    if (teamLogo == null || teamLogo!.isEmpty) {
      return placeholder();
    }

    return ClipOval(
      child: Image.network(
        teamLogo!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder(),
        errorBuilder: (context, error, stackTrace) => placeholder(),
      ),
    );
  }
}
