import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/my_bookings_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/screens/bookings/booking_detail_screen.dart';
import 'package:marriage_hall_app/widgets/bookings/client_booking_card.dart';

const _statusFilters = [
  'All',
  'Pending',
  'Confirmed',
  'Completed',
  'Cancelled',
  'Rejected',
];

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String selectedStatus = 'All';

  Future<void> refresh() async {
    ref.invalidate(myBookingsProvider);
    await ref.read(myBookingsProvider.future);
  }

  void openBooking(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Bookings'), centerTitle: true),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Could not load your bookings: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton(onPressed: refresh, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        data: (bookings) {
          // Newest requests first.
          final sorted = [...bookings]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final filtered = selectedStatus == 'All'
              ? sorted
              : sorted.where((b) => b.status == selectedStatus).toList();

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  children: [
                    for (final status in _statusFilters)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: selectedStatus == status,
                          onSelected: (_) =>
                              setState(() => selectedStatus = status),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: filtered.isEmpty
                      ? ListView(
                          // Scrollable so pull-to-refresh still works.
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Text(
                                bookings.isEmpty
                                    ? 'No bookings yet'
                                    : 'No $selectedStatus bookings',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final booking = filtered[index];
                            return ClientBookingCard(
                              booking: booking,
                              onTap: () => openBooking(booking),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
