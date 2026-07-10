import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_button.dart';

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
