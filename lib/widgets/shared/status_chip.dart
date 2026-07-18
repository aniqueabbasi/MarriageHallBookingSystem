import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

Color bookingStatusColor(String status) => switch (status) {
  'Pending' => AppColors.warning,
  'Confirmed' => AppColors.success,
  'Completed' => AppColors.primary,
  'Cancelled' || 'Rejected' => AppColors.error,
  _ => AppColors.textSecondary,
};

Color paymentStatusColor(String status) => switch (status) {
  'Pending' => AppColors.warning,
  'Completed' => AppColors.success,
  'Failed' => AppColors.error,
  'Refunded' => AppColors.textSecondary,
  _ => AppColors.textSecondary,
};

/// The pill-style status badge used on booking/payment cards everywhere.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
