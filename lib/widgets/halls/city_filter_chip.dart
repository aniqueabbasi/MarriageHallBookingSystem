import 'package:flutter/material.dart';
import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class CityFilterChip extends StatelessWidget {
  final String cityName;
  final bool isSelected;
  final VoidCallback onTap;

  const CityFilterChip({
    super.key,
    required this.cityName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.sm),
      child: ChoiceChip(
        label: Text(
          cityName,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        elevation: isSelected ? 4 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
      ),
    );
  }
}
