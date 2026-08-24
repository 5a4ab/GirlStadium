import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A large editorial-style card that highlights one featured football
// player, using their real photo when the API provides one. Only
// used on Home.
class FeaturedPlayerCard extends StatelessWidget {
  final String playerName;
  final String clubName;
  final String nationality;
  final String? photoUrl;

  const FeaturedPlayerCard({
    super.key,
    required this.playerName,
    required this.clubName,
    required this.nationality,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(22);

    return ClipRRect(
      borderRadius: cardRadius,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: cardRadius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPhoto(),
            // Gradient overlay so the text stays readable over any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6120A24)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.heroGradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FEATURED PLAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$clubName · $nationality',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      photoUrl!,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white54, size: 64),
      ),
    );
  }
}
