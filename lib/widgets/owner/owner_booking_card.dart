import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

class OwnerBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  /// Extra context line under the header (e.g. the admin list shows
  /// "Booking #7 · Advance Rs. 20,000" here). Hidden when null.
  final String? metaLine;

  const OwnerBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.metaLine,
  });

  @override
  Widget build(BuildContext context) {
    final initials = booking.customerName
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.chipBackground,
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.hallName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: booking.status,
                    color: bookingStatusColor(booking.status),
                  ),
                ],
              ),
              if (metaLine != null) ...[
                const SizedBox(height: 4),
                Text(
                  metaLine!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat('dd MMM yyyy').format(booking.eventDate),
                  ),
                  _InfoChip(
                    icon: Icons.groups_outlined,
                    label: '${booking.guestCount} Guests',
                  ),
                  if (booking.foodPackageName.isNotEmpty)
                    _InfoChip(
                      icon: Icons.restaurant_menu_outlined,
                      label: booking.foodPackageName,
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${Booking.formatTimeOfDay(booking.startTime)} - '
                      '${Booking.formatTimeOfDay(booking.endTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    formatPkr(booking.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
