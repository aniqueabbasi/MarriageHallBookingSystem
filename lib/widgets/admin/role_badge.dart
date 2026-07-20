import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

Color roleColor(String role) => switch (role) {
  'Admin' => AppColors.primary,
  'HallOwner' => AppColors.warning,
  'Customer' => AppColors.success,
  _ => AppColors.textSecondary,
};

String roleLabel(String role) => switch (role) {
  'HallOwner' => 'Hall Owner',
  _ => role,
};

/// Pill badge for a user's backend role string.
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return StatusChip(label: roleLabel(role), color: roleColor(role));
  }
}
