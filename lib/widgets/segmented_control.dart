import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A full-width, equal-width segmented selector (e.g. Yesterday /
// Today / Tomorrow, or Overview / Statistics / Events). Purely
// presentational - the caller owns the selected value and decides
// what happens on selection via [onSelected].
class SegmentedControl extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderLavender.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: options.map(_buildOption).toList(),
      ),
    );
  }

  Widget _buildOption(String option) {
    final bool isSelected = option == selected;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(option),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(colors: AppColors.heroGradient)
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentPink.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              option,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
