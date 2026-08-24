import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A consistent section title used across Home's redesigned sections -
// a bold warm-white title with a small accent icon, and an optional
// subtitle underneath.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentPink, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textWarm,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
