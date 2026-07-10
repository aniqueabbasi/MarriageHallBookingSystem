import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/owner_booking_dummy_data.dart';
import '../widgets/owner_booking_card.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Bookings"), centerTitle: true),
      body: dummyOwnerBookings.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: dummyOwnerBookings.length,
              itemBuilder: (context, index) {
                return OwnerBookingCard(booking: dummyOwnerBookings[index]);
              },
            ),
    );
  }
}
