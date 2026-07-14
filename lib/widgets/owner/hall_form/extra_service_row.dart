import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class ExtraServiceRow extends StatelessWidget {
  final String name;
  final TextEditingController priceController;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const ExtraServiceRow({
    super.key,
    required this.name,
    required this.priceController,
    required this.enabled,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                prefixText: "PKR ",
                border: InputBorder.none,
              ),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
