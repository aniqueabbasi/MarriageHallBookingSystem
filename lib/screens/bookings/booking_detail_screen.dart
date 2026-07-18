import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/booking_detail_controller.dart';
import 'package:marriage_hall_app/controllers/booking/booking_status_controller.dart';
import 'package:marriage_hall_app/controllers/booking/my_bookings_controller.dart';
import 'package:marriage_hall_app/controllers/payments/booking_payments_controller.dart';
import 'package:marriage_hall_app/controllers/reviews/submit_review_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/screens/reviews/add_review_screen.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/payments/payment_history_section.dart';
import 'package:marriage_hall_app/widgets/payments/submit_payment_sheet.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

/// Customer-side detail for one of their bookings: full info, payment
/// history, and the actions their booking's status allows (pay the
/// advance once confirmed, cancel while pending/confirmed, review once
/// completed).
class BookingDetailScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  void _refreshBooking(WidgetRef ref) {
    ref.invalidate(bookingDetailProvider(bookingId));
    ref.invalidate(bookingPaymentsProvider(bookingId));
    ref.invalidate(myBookingsProvider);
  }

  Future<void> cancelBooking(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text(
          'Your booking at "${booking.hallName}" on '
          '${DateFormat('dd MMM yyyy').format(booking.eventDate)} will be '
          'cancelled. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(bookingStatusControllerProvider(bookingId).notifier)
        .submit(bookingId, 'Cancelled');

    if (!context.mounted) return;
    if (result != null) {
      _refreshBooking(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your booking has been cancelled.')),
      );
    } else {
      final message = ref
          .read(bookingStatusControllerProvider(bookingId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not cancel the booking.')),
      );
    }
  }

  Future<void> openPaymentSheet(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final payment = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SubmitPaymentSheet(booking: booking),
    );

    if (payment == null || !context.mounted) return;
    _refreshBooking(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment submitted — it will be confirmed once the hall owner '
          'verifies it.',
        ),
      ),
    );
  }

  Future<void> openReview(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          bookingId: booking.id,
          hallName: booking.hallName,
        ),
      ),
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your review!')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Text('Could not load this booking: $error'),
          ),
        ),
        data: (booking) => _BookingDetailBody(
          booking: booking,
          onCancel: () => cancelBooking(context, ref, booking),
          onPay: () => openPaymentSheet(context, ref, booking),
          onReview: () => openReview(context, ref, booking),
          onRefresh: () async {
            _refreshBooking(ref);
            await ref.read(bookingDetailProvider(bookingId).future);
          },
        ),
      ),
    );
  }
}

class _BookingDetailBody extends ConsumerWidget {
  final Booking booking;
  final VoidCallback onCancel;
  final VoidCallback onPay;
  final VoidCallback onReview;
  final Future<void> Function() onRefresh;

  const _BookingDetailBody({
    required this.booking,
    required this.onCancel,
    required this.onPay,
    required this.onReview,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(bookingPaymentsProvider(booking.id));
    final statusState = ref.watch(bookingStatusControllerProvider(booking.id));
    final alreadyReviewed = ref.watch(
      reviewedBookingsProvider.select((ids) => ids.contains(booking.id)),
    );

    final canCancel =
        booking.status == 'Pending' || booking.status == 'Confirmed';
    final canPay = booking.status == 'Confirmed';
    final canReview = booking.status == 'Completed' && !alreadyReviewed;
    final remaining = booking.totalAmount - booking.amountPaid;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.hallName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusChip(
                      label: booking.status,
                      color: bookingStatusColor(booking.status),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                _detailRow(
                  Icons.calendar_today_outlined,
                  'Event Date',
                  DateFormat('dd MMM yyyy').format(booking.eventDate),
                ),
                _detailRow(
                  Icons.schedule_outlined,
                  'Event Time',
                  '${Booking.formatTimeOfDay(booking.startTime)} - '
                      '${Booking.formatTimeOfDay(booking.endTime)}',
                ),
                _detailRow(
                  Icons.groups_outlined,
                  'Guests',
                  '${booking.guestCount}',
                ),
                _detailRow(
                  Icons.restaurant_menu_outlined,
                  'Food Package',
                  booking.foodPackageName.isEmpty
                      ? 'None'
                      : booking.foodPackageName,
                ),
                _detailRow(
                  Icons.add_circle_outline,
                  'Extra Services',
                  booking.extraServiceNames.isEmpty
                      ? 'None'
                      : booking.extraServiceNames.join(', '),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.sm),
                _amountRow('Total Amount', booking.totalAmount),
                if (booking.advanceAmount > 0)
                  _amountRow('Advance Required', booking.advanceAmount),
                _amountRow('Paid (verified)', booking.amountPaid),
                _amountRow('Remaining', remaining < 0 ? 0 : remaining,
                    highlight: true),
                if (booking.status == 'Pending')
                  const Padding(
                    padding: EdgeInsets.only(top: AppSizes.sm),
                    child: Text(
                      'The hall owner will set the advance amount when '
                      'confirming your booking.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          PaymentHistorySection(paymentsAsync: paymentsAsync),
          const SizedBox(height: AppSizes.lg),
          if (canPay) ...[
            GradientButton(
              label: 'Pay Advance',
              icon: Icons.payments_outlined,
              onPressed: onPay,
            ),
            const SizedBox(height: AppSizes.md),
          ],
          if (canReview) ...[
            GradientButton(
              label: 'Leave a Review',
              icon: Icons.rate_review_outlined,
              onPressed: onReview,
            ),
            const SizedBox(height: AppSizes.md),
          ],
          if (canCancel)
            OutlinedButton.icon(
              onPressed: statusState.isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(
                statusState.isLoading ? 'Cancelling...' : 'Cancel Booking',
              ),
            ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, num amount, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            formatPkr(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
