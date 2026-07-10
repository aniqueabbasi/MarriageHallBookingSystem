import 'package:flutter/material.dart';

import '../widgets/legal_page_scaffold.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: "Terms & Conditions",
      sections: [
        MapEntry(
          "1. Acceptance of Terms",
          "By using Hall & Feast to browse or book marriage halls and photographers, "
              "you agree to be bound by these Terms & Conditions.",
        ),
        MapEntry(
          "2. Bookings",
          "All bookings made through the app are requests sent to the respective hall "
              "owner or photographer. Confirmation is subject to their availability.",
        ),
        MapEntry(
          "3. Payments",
          "Any advance or booking fee must be paid directly as agreed with the hall "
              "owner or photographer. Hall & Feast does not process payments directly.",
        ),
        MapEntry(
          "4. Cancellations",
          "Cancellation policies vary by venue and service provider. Please confirm "
              "cancellation terms before confirming your booking.",
        ),
        MapEntry(
          "5. User Conduct",
          "Users are expected to provide accurate information and communicate "
              "respectfully with hall owners and photographers.",
        ),
      ],
    );
  }
}
