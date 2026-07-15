import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/halls/extra_service.dart';
import 'package:marriage_hall_app/models/halls/food_package.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';

class FoodSelectionSection extends StatelessWidget {
  final List<FoodPackage> foodPackages;
  final List<ExtraService> extraServices;
  final int? selectedFoodPackageId;
  final Set<int> selectedExtraServiceIds;
  final ValueChanged<int> onPackageChanged;
  final void Function(int extraServiceId, bool isSelected) onExtraChanged;

  const FoodSelectionSection({
    super.key,
    required this.foodPackages,
    required this.extraServices,
    required this.selectedFoodPackageId,
    required this.selectedExtraServiceIds,
    required this.onPackageChanged,
    required this.onExtraChanged,
  });

  @override
  Widget build(BuildContext context) {
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

        if (foodPackages.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
            child: Text(
              "This hall hasn't listed any food packages yet.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...foodPackages.map((package) {
            final isSelected = selectedFoodPackageId == package.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: GestureDetector(
                onTap: () => onPackageChanged(package.id),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.chipBackground : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
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
                              package.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              package.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${formatPkr(package.pricePerHead)}/head",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        if (extraServices.isNotEmpty) ...[
          const SizedBox(height: AppSizes.lg),

          const Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary),
              SizedBox(width: AppSizes.sm),
              Text(
                "Add Extra Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: extraServices.map((extra) {
              final isSelected = selectedExtraServiceIds.contains(extra.id);
              return GestureDetector(
                onTap: () => onExtraChanged(extra.id, !isSelected),
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
                        "${extra.name} (${formatPkr(extra.price)})",
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
      ],
    );
  }
}
