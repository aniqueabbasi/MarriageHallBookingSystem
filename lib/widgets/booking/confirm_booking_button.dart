import 'package:flutter/material.dart';

import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

class ConfirmBookingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmBookingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: "Confirm Booking",
      icon: Icons.check_circle_outline,
      onPressed: onPressed,
    );
  }
}
