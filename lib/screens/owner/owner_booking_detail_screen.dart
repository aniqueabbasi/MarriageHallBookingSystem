import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/booking_detail_controller.dart';
import 'package:marriage_hall_app/controllers/booking/booking_status_controller.dart';
import 'package:marriage_hall_app/controllers/booking/owner_bookings_controller.dart';
import 'package:marriage_hall_app/controllers/payments/booking_payments_controller.dart';
import 'package:marriage_hall_app/controllers/payments/verify_payment_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/payments/payment_history_section.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

/// Owner-side detail for a booking against one of their halls — the
/// screen where a booking actually gets confirmed (with an advance
/// amount), rejected, completed, or cancelled, and where submitted
/// payments get verified.
class OwnerBookingDetailScreen extends ConsumerWidget {
  final int bookingId;

  const OwnerBookingDetailScreen({super.key, required this.bookingId});

  void _refreshBooking(WidgetRef ref) {
    ref.invalidate(bookingDetailProvider(bookingId));
    ref.invalidate(bookingPaymentsProvider(bookingId));
    ref.invalidate(ownerBookingsProvider);
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status, {
    double? advanceAmount,
    required String successMessage,
  }) async {
    final result = await ref
        .read(bookingStatusControllerProvider(bookingId).notifier)
        .submit(bookingId, status, advanceAmount: advanceAmount);

    if (!context.mounted) return;
    if (result != null) {
      _refreshBooking(ref);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } else {
      final message = ref
          .read(bookingStatusControllerProvider(bookingId))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not update the booking.')),
      );
    }
  }

  /// Confirm requires an advance amount (> 0, <= total) — collected here.
  Future<void> confirmBooking(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final advance = await showDialog<double>(
      context: context,
      builder: (context) => _AdvanceAmountDialog(booking: booking),
    );
    if (advance == null || !context.mounted) return;

    await _updateStatus(
      context,
      ref,
      'Confirmed',
      advanceAmount: advance,
      successMessage:
          'Booking confirmed — the customer has been asked to pay an '
          'advance of ${formatPkr(advance)}.',
    );
  }

  Future<void> _confirmThenUpdate(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String body,
    required String actionLabel,
    required String status,
    required String successMessage,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _updateStatus(context, ref, status, successMessage: successMessage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Request'), centerTitle: true),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Text('Could not load this booking: $error'),
          ),
        ),
        data: (booking) => _OwnerBookingDetailBody(
          booking: booking,
          onConfirm: () => confirmBooking(context, ref, booking),
          onReject: () => _confirmThenUpdate(
            context,
            ref,
            title: 'Reject this booking?',
            body:
                'The request from ${booking.customerName} for '
                '${DateFormat('dd MMM yyyy').format(booking.eventDate)} will '
                'be rejected. This cannot be undone.',
            actionLabel: 'Reject',
            status: 'Rejected',
            successMessage: 'Booking rejected.',
            destructive: true,
          ),
          onComplete: () => _confirmThenUpdate(
            context,
            ref,
            title: 'Mark as completed?',
            body:
                'This marks the event as held. The customer will be able to '
                'leave a review afterwards.',
            actionLabel: 'Complete',
            status: 'Completed',
            successMessage: 'Booking marked as completed.',
          ),
          onCancel: () => _confirmThenUpdate(
            context,
            ref,
            title: 'Cancel this booking?',
            body:
                'The confirmed booking for ${booking.customerName} will be '
                'cancelled. This cannot be undone.',
            actionLabel: 'Cancel Booking',
            status: 'Cancelled',
            successMessage: 'Booking cancelled.',
            destructive: true,
          ),
          onPaymentsChanged: () => _refreshBooking(ref),
          onRefresh: () async {
            _refreshBooking(ref);
            await ref.read(bookingDetailProvider(bookingId).future);
          },
        ),
      ),
    );
  }
}

class _OwnerBookingDetailBody extends ConsumerWidget {
  final Booking booking;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onPaymentsChanged;
  final Future<void> Function() onRefresh;

  const _OwnerBookingDetailBody({
    required this.booking,
    required this.onConfirm,
    required this.onReject,
    required this.onComplete,
    required this.onCancel,
    required this.onPaymentsChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(bookingPaymentsProvider(booking.id));
    final statusState = ref.watch(bookingStatusControllerProvider(booking.id));
    final remaining = booking.totalAmount - booking.amountPaid;
    final busy = statusState.isLoading;

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
                        booking.customerName,
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
                const SizedBox(height: 2),
                Text(
                  booking.hallName,
                  style: const TextStyle(color: AppColors.textSecondary),
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
                ),
                _detailRow(
                  Icons.history_outlined,
                  'Requested On',
                  DateFormat('dd MMM yyyy').format(booking.createdAt.toLocal()),
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
                _amountRow(
                  'Remaining',
                  remaining < 0 ? 0 : remaining,
                  highlight: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          PaymentHistorySection(
            paymentsAsync: paymentsAsync,
            actionsBuilder: (payment) => _paymentActions(payment, ref),
          ),
          const SizedBox(height: AppSizes.lg),
          if (booking.status == 'Pending') ...[
            GradientButton(
              label: busy ? 'Working...' : 'Confirm Booking',
              icon: Icons.check_circle_outline,
              onPressed: busy ? null : onConfirm,
            ),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: busy ? null : onReject,
              style: _dangerButtonStyle,
              icon: const Icon(Icons.block_outlined),
              label: const Text('Reject Booking'),
            ),
          ],
          if (booking.status == 'Confirmed') ...[
            GradientButton(
              label: busy ? 'Working...' : 'Mark as Completed',
              icon: Icons.task_alt_outlined,
              onPressed: busy ? null : onComplete,
            ),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: busy ? null : onCancel,
              style: _dangerButtonStyle,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  static final _dangerButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.error,
    side: const BorderSide(color: AppColors.error),
    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
  );

  /// Verify buttons under a payment row: a pending payment can be marked
  /// Completed or Failed; a completed one can be refunded.
  Widget? _paymentActions(Payment payment, WidgetRef ref) {
    final actions = switch (payment.status) {
      'Pending' => const [('Completed', 'Verify'), ('Failed', 'Mark Failed')],
      'Completed' => const [('Refunded', 'Refund')],
      _ => const <(String, String)>[],
    };
    if (actions.isEmpty) return null;

    return Consumer(
      builder: (context, ref, child) {
        final verifyState = ref.watch(
          verifyPaymentControllerProvider(payment.id),
        );

        Future<void> verify(String status) async {
          final result = await ref
              .read(verifyPaymentControllerProvider(payment.id).notifier)
              .submit(payment.id, status);
          if (!context.mounted) return;
          if (result != null) {
            onPaymentsChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment marked as $status.')),
            );
          } else {
            final message = ref
                .read(verifyPaymentControllerProvider(payment.id))
                .errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? 'Could not update the payment.'),
              ),
            );
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (final (status, label) in actions)
              TextButton(
                onPressed: verifyState.isLoading ? null : () => verify(status),
                style: status == 'Completed'
                    ? null
                    : TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(verifyState.isLoading ? '...' : label),
              ),
          ],
        );
      },
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

/// Collects the advance amount required to confirm a booking. Pops with
/// the amount, or null when dismissed.
class _AdvanceAmountDialog extends StatefulWidget {
  final Booking booking;

  const _AdvanceAmountDialog({required this.booking});

  @override
  State<_AdvanceAmountDialog> createState() => _AdvanceAmountDialogState();
}

class _AdvanceAmountDialogState extends State<_AdvanceAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String? validate(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) {
      return 'Enter an amount greater than 0';
    }
    if (amount > widget.booking.totalAmount) {
      return 'Cannot exceed the total (${formatPkr(widget.booking.totalAmount)})';
    }
    return null;
  }

  void submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, double.parse(amountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Booking'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the advance the customer must pay to secure this '
              'booking. Total: ${formatPkr(widget.booking.totalAmount)}.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: validate,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Advance Amount (PKR)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        TextButton(onPressed: submit, child: const Text('Confirm')),
      ],
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
