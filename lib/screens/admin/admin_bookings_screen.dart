import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/admin/admin_bookings_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/screens/owner/owner_booking_detail_screen.dart';
import 'package:marriage_hall_app/utils/api_error_text.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/owner/owner_booking_card.dart';

const _statusFilters = [
  'All',
  'Pending',
  'Confirmed',
  'Completed',
  'Cancelled',
  'Rejected',
];

/// Bookings tab: every booking on the platform. Detail/status updates
/// reuse the owner booking detail screen — the backend allows Admin on
/// the same PATCH endpoints.
class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  String selectedStatus = 'All';

  Future<void> refresh() async {
    ref.invalidate(adminBookingsProvider);
    await ref.read(adminBookingsProvider.future);
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
    final bookingsAsync = ref.watch(adminBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(friendlyErrorMessage(error), textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(onPressed: refresh, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      data: (bookings) {
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
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              bookings.isEmpty
                                  ? 'No bookings found.'
                                  : 'No $selectedStatus bookings.',
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
                          return OwnerBookingCard(
                            booking: booking,
                            metaLine:
                                'Booking #${booking.id}'
                                '${booking.advanceAmount > 0 ? ' · Advance ${formatPkr(booking.advanceAmount)}' : ''}',
                            onTap: () => openBooking(booking),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
