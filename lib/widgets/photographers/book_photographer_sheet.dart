import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/widgets/shared/gradient_button.dart';
import 'package:marriage_hall_app/constants/lists.dart';
import 'package:marriage_hall_app/controllers/photographers/book_photographer_controller.dart';

class BookPhotographerSheet extends ConsumerStatefulWidget {
  final String photographerName;

  const BookPhotographerSheet({super.key, required this.photographerName});

  @override
  ConsumerState<BookPhotographerSheet> createState() =>
      _BookPhotographerSheetState();
}

class _BookPhotographerSheetState
    extends ConsumerState<BookPhotographerSheet> {
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickDate(BookPhotographerController notifier) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      notifier.setDate(picked);
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
    final provider = bookPhotographerControllerProvider(
      widget.photographerName,
    );
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

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
            initialValue: state.selectedEvent,
            decoration: const InputDecoration(
              labelText: "Event Type",
              prefixIcon: Icon(Icons.celebration_outlined),
            ),
            items: photographerBookingEvents
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) notifier.setEvent(value);
            },
          ),
          const SizedBox(height: AppSizes.md),
          GestureDetector(
            onTap: () => pickDate(notifier),
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
                    state.selectedDate == null
                        ? "Select Event Date"
                        : DateFormat("dd MMM yyyy").format(state.selectedDate!),
                    style: TextStyle(
                      color: state.selectedDate == null
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
