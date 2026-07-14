import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';

class HallStatus {
  HallStatus._();

  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
}

extension HallStatusX on String {
  String get hallStatusLabel {
    switch (this) {
      case HallStatus.pending:
        return 'Pending Review';
      case HallStatus.approved:
        return 'Approved';
      case HallStatus.rejected:
        return 'Rejected';
      default:
        return this;
    }
  }

  Color get hallStatusColor {
    switch (this) {
      case HallStatus.approved:
        return AppColors.success;
      case HallStatus.rejected:
        return AppColors.error;
      case HallStatus.pending:
      default:
        return AppColors.warning;
    }
  }
}
