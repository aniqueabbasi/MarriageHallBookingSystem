import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/owner_bookings_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/screens/owner/owner_booking_detail_screen.dart';
import 'package:marriage_hall_app/widgets/owner/owner_booking_card.dart';

const _statusFilters = [
  'All',
  'Pending',
  'Confirmed',
  'Completed',
  'Cancelled',
  'Rejected',
];

/// Incoming bookings across all of this owner's halls. New (`Pending`)
/// requests are surfaced in their own section on top — those are the ones
/// awaiting a confirm/reject decision.
class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() =>
      _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen> {
  String selectedStatus = 'All';

  Future<void> refresh() async {
    ref.invalidate(ownerBookingsProvider);
    await ref.read(ownerBookingsProvider.future);
  }

  void openBooking(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerBookingDetailScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bookings'), centerTitle: true),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Could not load bookings: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton(onPressed: refresh, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        data: (bookings) {
          final sorted = [...bookings]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final pending = sorted.where((b) => b.status == 'Pending').toList();
          final filtered = selectedStatus == 'All'
              ? sorted.where((b) => b.status != 'Pending').toList()
              : sorted.where((b) => b.status == selectedStatus).toList();
          final showPendingSection =
              selectedStatus == 'All' && pending.isNotEmpty;

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
                          label: Text(
                            status == 'Pending' && pending.isNotEmpty
                                ? 'Pending (${pending.length})'
                                : status,
                          ),
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
                  child: bookings.isEmpty ||
                          (filtered.isEmpty && !showPendingSection)
                      ? ListView(
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
                      : ListView(
                          padding: const EdgeInsets.all(AppSizes.md),
                          children: [
                            if (showPendingSection) ...[
                              const Text(
                                'New Requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              for (final booking in pending)
                                OwnerBookingCard(
                                  booking: booking,
                                  onTap: () => openBooking(booking),
                                ),
                              if (filtered.isNotEmpty) ...[
                                const SizedBox(height: AppSizes.sm),
                                const Text(
                                  'All Bookings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                              ],
                            ],
                            for (final booking in filtered)
                              OwnerBookingCard(
                                booking: booking,
                                onTap: () => openBooking(booking),
                              ),
                          ],
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
