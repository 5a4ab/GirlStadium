import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/lesson.dart';
import '../constants/lessons_data.dart';
import '../widgets/learn_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar with title and search icon.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Learn Football',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Introduction card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New to football?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learn football step by step with short and simple lessons.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // No functionality yet.
                      },
                      child: const Text(
                        'Start Learning',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category chips.
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _buildCategoryChips(),
              ),
            ),

            const SizedBox(height: 20),

            // Lessons list.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildLessonsContent(),
            ),

            const SizedBox(height: 20),
          ],
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

  // Decides what to show below the category chips: the filtered
  // lesson cards, or a simple empty state when no lesson matches the
  // selected category.
  Widget _buildLessonsContent() {
    final filteredLessons = _filteredLessons;

    if (filteredLessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: AppColors.textSecondary,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'No lessons available',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredLessons.asMap().entries.map((entry) {
        final isLast = entry.key == filteredLessons.length - 1;
        final lesson = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: LearnCard(
            title: lesson.title,
            description: lesson.description,
            readTime: lesson.readTime,
            icon: lesson.icon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonDetailsScreen(lesson: lesson),
                ),
              );
            },
          ),
        );
      }).toList(),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
