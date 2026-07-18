import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/models/payments/create_payment_request.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/shared/status_chip.dart';

/// Payment timeline for a booking, shared between the customer and owner
/// booking detail screens. [actionsBuilder] lets the owner screen attach
/// verify buttons per payment; customers pass null.
class PaymentHistorySection extends StatelessWidget {
  final AsyncValue<List<Payment>> paymentsAsync;
  final Widget? Function(Payment payment)? actionsBuilder;

  const PaymentHistorySection({
    super.key,
    required this.paymentsAsync,
    this.actionsBuilder,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: AppColors.primary),
              SizedBox(width: AppSizes.sm),
              Text(
                'Payments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Text(
                'Could not load payments: $error',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            data: (payments) {
              if (payments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: Text(
                    'No payments yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  for (final payment in payments)
                    _PaymentRow(
                      payment: payment,
                      actions: actionsBuilder?.call(payment),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final Widget? actions;

  const _PaymentRow({required this.payment, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPkr(payment.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${PaymentMethods.label(payment.method)}'
                      '${payment.transactionId == null ? '' : ' · ${payment.transactionId}'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.paidAt != null
                          ? 'Paid ${DateFormat('dd MMM yyyy').format(payment.paidAt!.toLocal())}'
                          : 'Submitted ${DateFormat('dd MMM yyyy').format(payment.createdAt.toLocal())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: payment.status,
                color: paymentStatusColor(payment.status),
              ),
            ],
          ),
          if (payment.status == 'Pending' && actions == null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Awaiting verification by the hall owner — it will count '
                'toward your paid amount once verified.',
                style: TextStyle(fontSize: 11, color: AppColors.warning),
              ),
            ),
          ?actions,
        ],
      ),
    );
  }
}
