import 'package:flutter/material.dart';

import 'package:marriage_hall_app/screens/profile/view_profile_screen.dart';

/// Owner profile is the same `GET /api/users/me` data as the customer's —
/// this exists only so owner-side navigation keeps its own entry point.
class OwnerViewProfileScreen extends StatelessWidget {
  const OwnerViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const ViewProfileScreen();
}
