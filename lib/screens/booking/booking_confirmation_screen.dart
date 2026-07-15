import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/controllers/booking/cnic_upload_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/booking/advance_payment_breakdown.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final Booking booking;

  /// The live total shown on the booking form, computed client-side before
  /// submission — the server's [Booking.totalAmount] is authoritative. If
  /// they diverge, we surface it instead of silently trusting one over the
  /// other.
  final num clientEstimatedTotal;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.clientEstimatedTotal,
  });

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  late final String _instanceId = UniqueKey().toString();

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "You must fill this before proceeding to payment";
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "You must fill this before proceeding to payment";
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }

  void pickCnicPicture() {
    ref.read(cnicUploadControllerProvider(_instanceId).notifier).pickCnicPicture();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "CNIC picture selected (image picker isn't wired up in this UI-only build).",
        ),
      ),
    );
  }

  void removeCnicPicture() {
    ref.read(cnicUploadControllerProvider(_instanceId).notifier).removeCnicPicture();
  }

  void validateAndPay() {
    final cnicNotifier = ref.read(cnicUploadControllerProvider(_instanceId).notifier);
    final isCnicUploaded =
        ref.read(cnicUploadControllerProvider(_instanceId)).cnicUploaded;

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isCnicMissing = !isCnicUploaded;

    cnicNotifier.setShowError(isCnicMissing);

    if (!isFormValid || isCnicMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You must fill in all details before proceeding to payment",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Payment gateway isn't wired up in this UI-only build. "
          "Advance of ${formatPkr(widget.booking.advanceAmount)} would be charged here.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cnicState = ref.watch(cnicUploadControllerProvider(_instanceId));
    final booking = widget.booking;
    final remainingBalance = booking.totalAmount - booking.amountPaid;
    final advancePercentage = booking.totalAmount == 0
        ? 0
        : (booking.advanceAmount / booking.totalAmount) * 100;
    final hasDiscrepancy =
        (widget.clientEstimatedTotal - booking.totalAmount).abs() >= 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Booking Confirmation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDiscrepancy) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_outlined, color: AppColors.error),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          "Heads up: the estimated total shown while booking "
                          "(${formatPkr(widget.clientEstimatedTotal)}) doesn't "
                          "match what the server calculated "
                          "(${formatPkr(booking.totalAmount)}). The server "
                          "amount below is the one that applies.",
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
              Container(
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
                    _detailRow(
                      Icons.villa_outlined,
                      "Hall Name",
                      booking.hallName,
                    ),
                    _detailRow(
                      Icons.calendar_today_outlined,
                      "Event Date",
                      DateFormat("dd MMM yyyy").format(booking.eventDate),
                    ),
                    _detailRow(
                      Icons.schedule_outlined,
                      "Event Time",
                      "${Booking.formatTimeOfDay(booking.startTime)} - "
                          "${Booking.formatTimeOfDay(booking.endTime)}",
                    ),
                    _detailRow(
                      Icons.groups_outlined,
                      "Number of Guests",
                      "${booking.guestCount}",
                    ),
                    _detailRow(
                      Icons.restaurant_menu_outlined,
                      "Food Package",
                      booking.foodPackageName,
                    ),
                    _detailRow(
                      Icons.add_circle_outline,
                      "Extra Services",
                      booking.extraServiceNames.isEmpty
                          ? "None"
                          : booking.extraServiceNames.join(", "),
                    ),
                    _detailRow(
                      Icons.info_outline,
                      "Status",
                      booking.status,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AdvancePaymentBreakdown(
                totalPrice: booking.totalAmount,
                advancePercentage: advancePercentage,
                advanceAmount: booking.advanceAmount,
                remainingBalance: remainingBalance,
              ),
              const SizedBox(height: AppSizes.md),
              Container(
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
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Expanded(
                          child: Text(
                            "Contact & Verification Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Required to confirm your identity before payment",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: requiredValidator,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "03XX XXXXXXX",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      validator: requiredValidator,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        hintText: "House #, Street, City",
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: emailValidator,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "you@example.com",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    const Text(
                      "CNIC Picture",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _CnicUploadTile(
                      isUploaded: cnicState.cnicUploaded,
                      hasError: cnicState.showCnicError,
                      onUpload: pickCnicPicture,
                      onRemove: removeCnicPicture,
                    ),
                    if (cnicState.showCnicError) ...[
                      const SizedBox(height: 6),
                      const Text(
                        "You must fill this before proceeding to payment",
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        "Only the advance payment is required to confirm your "
                        "booking. The remaining balance will be paid directly to "
                        "the Hall Owner according to the hall's payment policy.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              GradientButton(
                label: "Pay Advance (${formatPkr(booking.advanceAmount)})",
                icon: Icons.lock_outline,
                onPressed: validateAndPay,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
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
}

class _CnicUploadTile extends StatelessWidget {
  final bool isUploaded;
  final bool hasError;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _CnicUploadTile({
    required this.isUploaded,
    required this.hasError,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploaded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: AppSizes.sm),
            const Expanded(
              child: Text(
                "CNIC picture selected",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(onPressed: onRemove, child: const Text("Remove")),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: hasError ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              "Upload CNIC Picture",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
