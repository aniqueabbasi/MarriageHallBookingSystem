import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/payments/submit_payment_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/payments/create_payment_request.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';

/// Bottom sheet for `POST /api/payments`. Pops with the created [Payment]
/// on success (always `Pending` until the owner verifies it) or null when
/// dismissed.
class SubmitPaymentSheet extends ConsumerStatefulWidget {
  final Booking booking;

  const SubmitPaymentSheet({super.key, required this.booking});

  @override
  ConsumerState<SubmitPaymentSheet> createState() => _SubmitPaymentSheetState();
}

class _SubmitPaymentSheetState extends ConsumerState<SubmitPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController amountController;
  final transactionIdController = TextEditingController();
  String method = 'JazzCash';

  /// What's still owed on the advance — the natural default for the next
  /// payment. Falls back to the remaining total once the advance is
  /// covered.
  double get _suggestedAmount {
    final booking = widget.booking;
    final remainingAdvance = booking.advanceAmount - booking.amountPaid;
    if (remainingAdvance > 0) return remainingAdvance;
    final remainingTotal = booking.totalAmount - booking.amountPaid;
    return remainingTotal > 0 ? remainingTotal : 0;
  }

  @override
  void initState() {
    super.initState();
    final suggested = _suggestedAmount;
    amountController = TextEditingController(
      text: suggested > 0 ? suggested.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    transactionIdController.dispose();
    super.dispose();
  }

  String? validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || amount <= 0) return 'Enter an amount greater than 0';
    return null;
  }

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payment = await ref
        .read(submitPaymentControllerProvider(widget.booking.id).notifier)
        .submit(
          CreatePaymentRequest(
            bookingId: widget.booking.id,
            amount: double.parse(amountController.text.trim()),
            method: method,
            transactionId: transactionIdController.text.trim(),
          ),
        );

    if (!mounted) return;
    if (payment != null) {
      Navigator.pop(context, payment);
    } else {
      final message = ref
          .read(submitPaymentControllerProvider(widget.booking.id))
          .errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not submit the payment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(
      submitPaymentControllerProvider(widget.booking.id),
    );
    final booking = widget.booking;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Advance due: ${formatPkr(booking.advanceAmount)} · '
              'Paid so far: ${formatPkr(booking.amountPaid)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: validateAmount,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: [
                for (final m in PaymentMethods.all)
                  DropdownMenuItem(value: m, child: Text(PaymentMethods.label(m))),
              ],
              onChanged: (value) => setState(() => method = value ?? method),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: transactionIdController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Transaction ID (optional)',
                counterText: '',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Your payment will show as Pending until the hall owner '
              'verifies it.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.md),
            GradientButton(
              label: submitState.isLoading ? 'Submitting...' : 'Submit Payment',
              icon: Icons.lock_outline,
              onPressed: submitState.isLoading ? null : submit,
            ),
          ],
        ),
      ),
    );
  }
}
