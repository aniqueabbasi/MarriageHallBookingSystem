import 'package:flutter/material.dart';

import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

class ConfirmBookingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const ConfirmBookingButton({
    super.key,
    required this.onPressed,
    this.label = "Confirm Booking",
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: label,
      icon: Icons.check_circle_outline,
      onPressed: onPressed,
    );
  }
}
