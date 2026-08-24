import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/lesson.dart';
import '../constants/lessons_data.dart';
import '../widgets/app_back_button.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/lesson_visual.dart';
import '../widgets/section_header.dart';

class LessonDetailsScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailsScreen({super.key, required this.lesson});

  // The next lesson in the local lesson list, if any. Used for the
  // bottom action - purely local, no persistence, no API request.
  Lesson? get _nextLesson {
    final index = lessons.indexWhere((l) => l.id == lesson.id);
    if (index == -1 || index + 1 >= lessons.length) return null;
    return lessons[index + 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Lesson'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              FadeSlideIn(child: _buildHero()),

              const SizedBox(height: 26),

              // The simple explanation - the lesson's existing content
              // paragraphs, presented under a clear section title.
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'The Simple Explanation',
                      icon: Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 14),
                    ...lesson.content.map((paragraph) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          paragraph,
                          style: const TextStyle(
                            color: AppColors.textWarm,
                            fontSize: 15,
                            height: 1.55,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              if (lesson.tips.isNotEmpty) ...[
                const SizedBox(height: 12),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Quick Tips',
                        icon: Icons.tips_and_updates_outlined,
                      ),
                      const SizedBox(height: 14),
                      ...lesson.tips.map(_buildTipCallout),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _buildBottomAction(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // The lesson hero: a large visual panel, category label, title, and
  // read time.
  Widget _buildHero() {
    final accentColor = categoryAccentColor(lesson.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LessonVisual(lesson: lesson, height: 180),
        ),
        const SizedBox(height: 18),
        Text(
          lesson.category.toUpperCase(),
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          lesson.title,
          style: const TextStyle(
            color: AppColors.textWarm,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: AppColors.textMuted,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              lesson.readTime,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // One compact tip callout - a translucent pink surface with a check
  // icon, using the lesson's real tip text.
  Widget _buildTipCallout(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentPink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentPink.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.accentPink,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: AppColors.textWarm,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Next Lesson" moves to the next lesson in the local list without
  // growing the back stack (pushReplacement); on the final lesson it
  // becomes "Back to Learn" instead. No persistence, no API request.
  Widget _buildBottomAction(BuildContext context) {
    final next = _nextLesson;
    final label = next != null ? 'Next Lesson' : 'Back to Learn';
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (next != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonDetailsScreen(lesson: next),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.heroGradient),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
