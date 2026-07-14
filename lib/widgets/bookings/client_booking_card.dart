import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class ClientBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ClientBookingCard({super.key, required this.booking});

  Color get _statusColor {
    switch (booking['status']) {
      case 'Confirmed':
        return AppColors.success;
      case 'Pending':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Image.asset(
                booking['imagePath'],
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking['subtitle'],
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking['date'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Text(
                booking['status'],
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
