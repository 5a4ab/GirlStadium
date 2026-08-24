import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A consistent back button used in the `leading` slot of every detail
// screen's AppBar: a rounded, subtly bordered dark surface instead of
// a bare default back icon.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Material(
          color: AppColors.surfaceElevated,
          shape: CircleBorder(
            side: BorderSide(color: AppColors.borderLavender.withValues(alpha: 0.6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textWarm,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
