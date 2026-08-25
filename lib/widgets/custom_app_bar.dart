import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../theme/app_colors.dart';

// GirlStadium's brand header: a small gradient mark plus wordmark, and a
// compact profile/account entry point. Currently only used on Home.
// Sign-out now lives inside ProfileScreen instead of here, so this
// widget stays a plain navigation trigger with no Firestore/Auth calls
// of its own.
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.heroGradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPink.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'GirlStadium',
            style: TextStyle(
              color: AppColors.textWarm,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.surfaceBase,
            shape: CircleBorder(
              side: BorderSide(
                color: AppColors.borderLavender.withValues(alpha: 0.5),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openProfile(context),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
