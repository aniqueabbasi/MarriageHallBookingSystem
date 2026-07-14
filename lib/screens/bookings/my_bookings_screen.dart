import 'package:flutter/material.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/data/dummy/client_booking_dummy_data.dart';
import 'package:marriage_hall_app/widgets/bookings/client_booking_card.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Bookings"), centerTitle: true),
      body: dummyClientBookings.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: dummyClientBookings.length,
              itemBuilder: (context, index) {
                return ClientBookingCard(booking: dummyClientBookings[index]);
              },
            ),
    );
  }
}
