import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/resources/app_strings.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SocialLoginButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.g_mobiledata, color: AppColors.primary, size: 28),
      label: const Text(
        AppStrings.continueWithGoogle,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }
}
