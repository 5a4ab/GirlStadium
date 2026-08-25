import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A rich player profile card: a full-bleed photo with a dark gradient
// fade behind the name/position, and an optional shirt-number badge.
// Sized entirely by its parent (a SizedBox in a horizontal list, or a
// GridView cell) - used both by the "Top Players" preview on Team
// Details and the full grid on Team Squad.
class PlayerCard extends StatelessWidget {
  final String name;
  final String? photo;
  final String? position;
  final int? number;

  const PlayerCard({
    super.key,
    required this.name,
    this.photo,
    this.position,
    this.number,
  });

  // A subtle, position-based accent drawn only from the app's existing
  // pink/violet gradient family - never a new color, and only applied
  // when the API actually reports a recognizable position.
  List<Color> get _accent {
    final p = position?.toLowerCase() ?? '';
    if (p.contains('goalkeeper')) return AppColors.violetIndigoGradient;
    if (p.contains('midfielder')) return AppColors.magentaPurpleGradient;
    return AppColors.heroGradient;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPhoto(),

          // Gradient fade so the name/position stay readable over any
          // photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE6120A24)],
                stops: [0.45, 1],
              ),
            ),
          ),

          if (number != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
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
                  position ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The photo fills the whole card. Falls back to a tonal gradient
  // backdrop with a person icon when there's no photo URL or it fails
  // to load - safe in both cases, no extra request either way.
  Widget _buildPhoto() {
    if (photo == null || photo!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      photo!,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceBase,
            AppColors.surfaceElevated,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, color: AppColors.textMuted, size: 32),
      ),
    );
  }
}
