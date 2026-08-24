import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/lesson.dart';

// Picks a category-based gradient so lessons read as visually
// distinct groups rather than identical cards, while staying within
// the approved GirlStadium palette.
List<Color> gradientForCategory(String category) {
  switch (category) {
    case 'Rules':
      return AppColors.heroGradient;
    case 'Players':
      return AppColors.violetIndigoGradient;
    case 'Competitions':
      return AppColors.magentaPurpleGradient;
    case 'Referees':
      return [AppColors.surfaceElevated, AppColors.accentPink];
    default:
      return AppColors.heroGradient;
  }
}

// A legible accent color for category labels/text. Usually the same
// as the visual panel's gradient start, except for categories (like
// Referees) whose panel gradient deliberately starts with a dark
// tone that would be unreadable as text.
Color categoryAccentColor(String category) {
  if (category == 'Referees') return AppColors.accentPink;
  return gradientForCategory(category).first;
}

// A lightweight visual panel for one lesson: a category-gradient
// background with a small built-in motif (a mini pitch for offside,
// a monitor for VAR, etc). Used both small (lesson cards) and large
// (the Lesson Details hero) via [height]. Purely decorative - no
// network images, no CustomPaint, just simple shapes and icons.
class LessonVisual extends StatelessWidget {
  final Lesson lesson;
  final double height;

  const LessonVisual({super.key, required this.lesson, required this.height});

  @override
  Widget build(BuildContext context) {
    final gradient = gradientForCategory(lesson.category);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -height * 0.3,
              right: -height * 0.2,
              child: _decorCircle(height * 0.8),
            ),
            Positioned(
              bottom: -height * 0.35,
              left: -height * 0.25,
              child: _decorCircle(height * 0.9),
            ),
            _motifFor(lesson, height * 0.34),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _motifFor(Lesson lesson, double unit) {
    switch (lesson.id) {
      case 'offside':
        return _offsideMotif(unit);
      case 'var':
        return _varMotif(unit);
      case 'cards':
        return _cardsMotif(unit);
      case 'champions-league':
        return Icon(
          Icons.emoji_events,
          color: Colors.white.withValues(alpha: 0.92),
          size: unit * 1.7,
        );
      case 'hat-trick':
        return _hatTrickMotif(unit);
      case 'extra-time-penalties':
        return Icon(
          Icons.timer_outlined,
          color: Colors.white.withValues(alpha: 0.92),
          size: unit * 1.6,
        );
      default:
        return Icon(
          lesson.icon,
          color: Colors.white.withValues(alpha: 0.92),
          size: unit * 1.6,
        );
    }
  }

  // A tiny mini-pitch: an attacking dot, a defending dot, and a
  // dashed "offside line" between them.
  Widget _offsideMotif(double unit) {
    return SizedBox(
      width: unit * 3.2,
      height: unit * 3.2,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    width: 2,
                    height: 6,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            left: unit * 0.1,
            top: unit * 0.4,
            child: _dot(unit * 0.5, Colors.white),
          ),
          Positioned(
            right: unit * 0.1,
            bottom: unit * 0.4,
            child: _dot(unit * 0.5, Colors.white.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // A small monitor shape with a check mark, for VAR.
  Widget _varMotif(double unit) {
    return Container(
      width: unit * 2,
      height: unit * 1.5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(unit * 0.22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Icon(Icons.check_circle, color: Colors.white, size: unit * 0.9),
    );
  }

  // Two overlapping tilted card shapes, for Red Card vs Yellow Card.
  Widget _cardsMotif(double unit) {
    return SizedBox(
      width: unit * 2.6,
      height: unit * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(-unit * 0.45, 0),
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: unit,
                height: unit * 1.4,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(unit * 0.14),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(unit * 0.45, 0),
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                width: unit,
                height: unit * 1.4,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(unit * 0.14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Three footballs, the middle one emphasized, for a hat-trick.
  Widget _hatTrickMotif(double unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sports_soccer, color: Colors.white.withValues(alpha: 0.5), size: unit),
        SizedBox(width: unit * 0.2),
        Icon(Icons.sports_soccer, color: Colors.white, size: unit * 1.4),
        SizedBox(width: unit * 0.2),
        Icon(Icons.sports_soccer, color: Colors.white.withValues(alpha: 0.5), size: unit),
      ],
    );
  }
}
