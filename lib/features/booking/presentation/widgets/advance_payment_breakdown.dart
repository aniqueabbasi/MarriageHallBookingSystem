import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class AdvancePaymentBreakdown extends StatelessWidget {
  final int totalPrice;
  final int advancePercentage;
  final int advanceAmount;
  final int remainingBalance;

  const AdvancePaymentBreakdown({
    super.key,
    required this.totalPrice,
    required this.advancePercentage,
    required this.advanceAmount,
    required this.remainingBalance,
  });

  String formatPrice(int price) => "PKR $price";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              const Text(
                "Advance Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row("Total Booking Amount", formatPrice(totalPrice)),
          _row("Advance Required", "$advancePercentage%"),
          _row(
            "Advance Amount (Pay Now)",
            formatPrice(advanceAmount),
            valueColor: AppColors.primary,
            isBold: true,
          ),
          _row("Remaining Balance", formatPrice(remainingBalance)),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
