import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';

class FoodPackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onDelete;

  const FoodPackageCard({
    super.key,
    required this.package,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = List<String>.from(package['items'] as List);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "PKR ${package['pricePerPerson']}/head",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, color: AppColors.error, size: 20),
              ),
            ],
          ),
          Wrap(
            spacing: AppSizes.xs,
            runSpacing: AppSizes.xs,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(item, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.chipBackground,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
