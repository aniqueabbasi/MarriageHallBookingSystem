import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class AmenitiesSection extends StatelessWidget {
  final List<String> amenities;

  const AmenitiesSection({super.key, required this.amenities});

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'parking':
        return Icons.local_parking_outlined;
      case 'ac':
        return Icons.ac_unit;
      case 'catering':
        return Icons.restaurant;
      case 'generator':
        return Icons.bolt;
      case 'stage':
        return Icons.celebration;
      case 'bridal room':
        return Icons.meeting_room_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: AppSizes.sm),

          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: amenities.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      amenity,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
