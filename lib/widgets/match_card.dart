import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/fixture.dart';

// A card that shows one live match. Only used on Home's "Live &
// Upcoming" section.
class MatchCard extends StatelessWidget {
  final Fixture fixture;

  // Optional tap callback. When null, the card is not tappable.
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.fixture,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(20);

    final cardContent = Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: cardRadius,
        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fixture.league,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.heroGradient),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _teamRow(fixture.homeTeamLogo, fixture.homeTeam, fixture.homeScoreDisplay),
          const SizedBox(height: 10),
          _teamRow(fixture.awayTeamLogo, fixture.awayTeam, fixture.awayScoreDisplay),
          if (fixture.minuteLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                fixture.minuteLabel,
                style: const TextStyle(
                  color: AppColors.accentPink,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

  Widget _teamRow(String? logoUrl, String name, String scoreDisplay) {
    return Row(
      children: [
        _buildLogo(logoUrl),
        const SizedBox(width: 10),
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
        Text(
          scoreDisplay,
          style: const TextStyle(
            color: AppColors.textWarm,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(String? url) {
    const double size = 24;

    Widget placeholder() => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 13,
            color: AppColors.textMuted,
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
}
