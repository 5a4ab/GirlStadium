import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/lesson.dart';
import '../constants/lessons_data.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/lesson_card.dart';
import 'lesson_details_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // The categories shown as chips. "All" is not a real Lesson
  // category - it simply means no filtering is applied.
  static const List<String> _categories = [
    'All',
    'Rules',
    'Competitions',
    'Players',
    'Positions',
    'Referees',
    'History',
  ];

  String _selectedCategory = 'All';

  // Returns only the lessons matching the currently selected category,
  // or all lessons when "All" is selected. Purely local filtering -
  // no API request involved.
  List<Lesson> get _filteredLessons {
    if (_selectedCategory == 'All') return lessons;
    return lessons
        .where((lesson) => lesson.category == _selectedCategory)
        .toList();
  }

  void _openLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetailsScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // Beginner CTA.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(child: _buildBeginnerCta()),
            ),

            const SizedBox(height: 22),

            // Category chips.
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _buildCategoryChips(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lessons grid / empty state.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: _buildLessonsContent(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // A short, editorial-feeling header - the same warm-white/muted
  // language used across the redesigned app, with a small pink glow
  // for a bit of depth.
  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -30,
          left: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPink.withValues(alpha: 0.16),
                  AppColors.accentPink.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learn Football 💗',
                style: TextStyle(
                  color: AppColors.textWarm,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Simple. Clear. Easy to understand.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // The beginner-guide banner. Tapping it opens the first lesson in
  // the local lesson list - the natural starting point.
  Widget _buildBeginnerCta() {
    final radius = BorderRadius.circular(20);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: lessons.isEmpty ? null : () => _openLesson(lessons.first),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New to Football?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Start with our beginner guide',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the category chips, with SizedBox spacers between them,
  // matching the original manual list layout.
  List<Widget> _buildCategoryChips() {
    final List<Widget> chips = [];
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      chips.add(
        _CategoryChip(
          label: category,
          isSelected: _selectedCategory == category,
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
      );
      if (i != _categories.length - 1) {
        chips.add(const SizedBox(width: 10));
      }
    }
    return chips;
  }

  // Decides what to show below the category chips: a two-column grid
  // of visual lesson cards, or a designed empty state when no lesson
  // matches the selected category.
  Widget _buildLessonsContent() {
    final filteredLessons = _filteredLessons;

    if (filteredLessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderLavender.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                color: AppColors.textWarm,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'More beginner lessons are coming to this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        final lesson = filteredLessons[index];
        return LessonCard(
          lesson: lesson,
          onTap: () => _openLesson(lesson),
        );
      },
    );
  }
}

// A single category chip shown at the top of the Learn screen.
// Highlights when it is the currently selected filter.
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: AppColors.heroGradient)
              : null,
          color: isSelected ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.borderLavender.withValues(alpha: 0.4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentPink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
