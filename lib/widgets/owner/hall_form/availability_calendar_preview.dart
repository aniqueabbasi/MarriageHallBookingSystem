import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class AvailabilityCalendarPreview extends StatelessWidget {
  const AvailabilityCalendarPreview({super.key});

  static const List<int> _dummyBookedDays = [5, 12, 13, 21];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = (firstDayOfMonth.weekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                "Booking Calendar (UI only)",
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: [
              ...List.generate(leadingBlanks, (index) => const SizedBox()),
              ...List.generate(daysInMonth, (index) {
                final day = index + 1;
                final isBooked = _dummyBookedDays.contains(day);
                final isToday = day == now.day;

                return Container(
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBooked
                        ? AppColors.error.withValues(alpha: 0.15)
                        : isToday
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$day",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isBooked ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.error, "Booked"),
              const SizedBox(width: AppSizes.md),
              _legendDot(AppColors.primary, "Today"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
