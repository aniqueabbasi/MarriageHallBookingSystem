import 'package:flutter/material.dart';

import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

class BookNowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BookNowButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GradientButton(
          label: "Book Now",
          icon: Icons.event_available,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
