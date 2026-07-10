import 'package:flutter/material.dart';

import '../widgets/legal_page_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: "Privacy Policy",
      sections: [
        MapEntry(
          "1. Information We Collect",
          "We collect basic profile information such as your name, email, phone "
              "number and city to help you book halls and photographers.",
        ),
        MapEntry(
          "2. How We Use Your Information",
          "Your information is used to process booking requests, show relevant "
              "listings, and send you notifications about your bookings.",
        ),
        MapEntry(
          "3. Sharing With Hall Owners & Photographers",
          "When you send a booking request, your contact details are shared with "
              "the relevant hall owner or photographer so they can confirm your event.",
        ),
        MapEntry(
          "4. Data Security",
          "We take reasonable measures to protect your personal information from "
              "unauthorized access, alteration or disclosure.",
        ),
        MapEntry(
          "5. Your Choices",
          "You can update your profile information at any time from the Profile "
              "section of the app.",
        ),
      ],
    );
  }
}
