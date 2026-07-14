import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class EventPricingSection extends StatelessWidget {
  final List<Map<String, dynamic>> eventPricing;

  const EventPricingSection({super.key, required this.eventPricing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: eventPricing.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.celebration_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    entry['event'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                entry['price'],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
