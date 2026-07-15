import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';

class TimeRangeField extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const TimeRangeField({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _pick(BuildContext context, ValueChanged<TimeOfDay> onPicked, TimeOfDay? initial) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeTile(
            icon: Icons.schedule,
            label: 'Start Time',
            time: startTime,
            onTap: () => _pick(context, onStartTimeChanged, startTime),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _TimeTile(
            icon: Icons.schedule_outlined,
            label: 'End Time',
            time: endTime,
            onTap: () => _pick(context, onEndTimeChanged, endTime),
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.icon,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time == null ? label : time!.format(context),
                style: TextStyle(
                  fontSize: 14,
                  color: time == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
