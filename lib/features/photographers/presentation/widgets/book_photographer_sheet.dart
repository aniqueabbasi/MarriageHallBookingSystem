import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/gradient_button.dart';

class BookPhotographerSheet extends StatefulWidget {
  final String photographerName;

  const BookPhotographerSheet({super.key, required this.photographerName});

  @override
  State<BookPhotographerSheet> createState() => _BookPhotographerSheetState();
}

class _BookPhotographerSheetState extends State<BookPhotographerSheet> {
  static const events = ['Engagement', 'Mehndi', 'Barat / Nikkah', 'Walima'];

  String selectedEvent = events.first;
  DateTime? selectedDate;
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void submit() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Booking request sent to ${widget.photographerName}!",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            "Book ${widget.photographerName}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.lg),
          DropdownButtonFormField<String>(
            initialValue: selectedEvent,
            decoration: const InputDecoration(
              labelText: "Event Type",
              prefixIcon: Icon(Icons.celebration_outlined),
            ),
            items: events
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedEvent = value);
            },
          ),
          const SizedBox(height: AppSizes.md),
          GestureDetector(
            onTap: pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    selectedDate == null
                        ? "Select Event Date"
                        : DateFormat("dd MMM yyyy").format(selectedDate!),
                    style: TextStyle(
                      color: selectedDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              hintText: "03XX XXXXXXX",
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          GradientButton(
            label: "Send Booking Request",
            icon: Icons.check_circle_outline,
            onPressed: submit,
          ),
        ],
      ),
    );
  }
}
