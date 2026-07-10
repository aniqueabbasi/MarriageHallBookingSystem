import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class FoodSelectionSection extends StatelessWidget {
  final String selectedPackage;
  final List<String> selectedExtras;
  final Function(String?) onPackageChanged;
  final Function(String, bool) onExtraChanged;

  const FoodSelectionSection({
    super.key,
    required this.selectedPackage,
    required this.selectedExtras,
    required this.onPackageChanged,
    required this.onExtraChanged,
  });

  @override
  Widget build(BuildContext context) {
    final packages = {
      "Standard Package": "Karahi + Rice/Biryani + Sweet Dish",
      "Premium Package": "Karahi + Biryani + BBQ + Sweet Dish",
      "Luxury Package": "Karahi + Biryani + BBQ + Salad + Drinks + Sweet Dish",
    };

    final extras = [
      "Cold Drinks",
      "Raita + Salad",
      "BBQ",
      "Extra Sweet Dish",
      "Mineral Water",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.restaurant_menu, color: AppColors.primary),
            SizedBox(width: AppSizes.sm),
            Text(
              "Food Package",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        ...packages.entries.map((item) {
          final isSelected = selectedPackage == item.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: GestureDetector(
              onTap: () => onPackageChanged(item.key),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.chipBackground : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.value,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: AppSizes.lg),

        const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary),
            SizedBox(width: AppSizes.sm),
            Text(
              "Add Extra Dishes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: extras.map((extra) {
            final isSelected = selectedExtras.contains(extra);
            return GestureDetector(
              onTap: () => onExtraChanged(extra, !isSelected),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.add_circle_outline,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      extra,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
