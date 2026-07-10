import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/gradient_button.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String hallName;
  final DateTime bookingDate;
  final int guests;
  final String selectedPackage;
  final List<String> selectedExtras;
  final int totalPrice;
  final int advancePercentage;
  final int advanceAmount;
  final int remainingBalance;

  const BookingConfirmationScreen({
    super.key,
    required this.hallName,
    required this.bookingDate,
    required this.guests,
    required this.selectedPackage,
    required this.selectedExtras,
    required this.totalPrice,
    required this.advancePercentage,
    required this.advanceAmount,
    required this.remainingBalance,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  bool cnicUploaded = false;
  bool showCnicError = false;

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String formatPrice(int price) => "PKR $price";

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
    setState(() {
      cnicUploaded = true;
      showCnicError = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "CNIC picture selected (image picker isn't wired up in this UI-only build).",
        ),
      ),
    );
  }

  void removeCnicPicture() {
    setState(() => cnicUploaded = false);
  }

  void validateAndPay() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isCnicMissing = !cnicUploaded;

    setState(() => showCnicError = isCnicMissing);

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
          "Advance of ${formatPrice(widget.advanceAmount)} would be charged here.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.hallName,
                    ),
                    _detailRow(
                      Icons.calendar_today_outlined,
                      "Booking Date",
                      DateFormat("dd MMM yyyy").format(widget.bookingDate),
                    ),
                    _detailRow(
                      Icons.groups_outlined,
                      "Number of Guests",
                      "${widget.guests}",
                    ),
                    _detailRow(
                      Icons.restaurant_menu_outlined,
                      "Food Package",
                      widget.selectedPackage,
                    ),
                    _detailRow(
                      Icons.add_circle_outline,
                      "Extra Services",
                      widget.selectedExtras.isEmpty
                          ? "None"
                          : widget.selectedExtras.join(", "),
                      isLast: true,
                    ),
                  ],
                ),
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
                    const Text(
                      "Payment Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _priceRow(
                      "Total Booking Amount",
                      formatPrice(widget.totalPrice),
                    ),
                    _priceRow(
                      "Advance Percentage",
                      "${widget.advancePercentage}%",
                    ),
                    const Divider(height: AppSizes.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              "Advance Amount (Pay Now)",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            formatPrice(widget.advanceAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _priceRow(
                      "Remaining Balance",
                      formatPrice(widget.remainingBalance),
                    ),
                  ],
                ),
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
                      isUploaded: cnicUploaded,
                      hasError: showCnicError,
                      onUpload: pickCnicPicture,
                      onRemove: removeCnicPicture,
                    ),
                    if (showCnicError) ...[
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
                label: "Pay Advance (${formatPrice(widget.advanceAmount)})",
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

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
