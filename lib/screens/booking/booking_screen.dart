import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/booking_form_controller.dart';
import 'package:marriage_hall_app/controllers/booking/booking_submit_controller.dart';
import 'package:marriage_hall_app/controllers/halls/hall_detail_controller.dart';
import 'package:marriage_hall_app/models/halls/extra_service.dart';
import 'package:marriage_hall_app/models/halls/food_package.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/models/booking/create_booking_request.dart';
import 'package:marriage_hall_app/utils/currency_formatter.dart';
import 'package:marriage_hall_app/widgets/booking/food_selection_section.dart';
import 'package:marriage_hall_app/widgets/booking/guest_counter.dart';
import 'package:marriage_hall_app/widgets/booking/time_range_field.dart';
import 'booking_confirmation_screen.dart';
import 'booking_summary_card.dart';
import '../../widgets/booking/booking_price_section.dart';
import '../../widgets/booking/confirm_booking_button.dart';
import '../../widgets/booking/date_picker_field.dart';
import '../../widgets/booking/phone_textfield.dart';
import '../../widgets/booking/special_request_field.dart';

/// Exact server messages for a cached food package/extra service that was
/// soft-deleted after this hall was loaded — distinct from a generic
/// "doesn't belong to this hall" error, this means the user's selection is
/// just stale and they need to re-pick from a refreshed list.
const _staleFoodPackageMessage =
    "This food package is no longer offered. Please refresh and select again.";
const _staleExtraServiceMessage =
    "This extra service is no longer offered. Please refresh and select again.";

class BookingScreen extends ConsumerStatefulWidget {
  final Hall hall;

  const BookingScreen({super.key, required this.hall});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    specialRequestController.dispose();
    super.dispose();
  }

  FoodPackage? _selectedPackage(BookingFormState formState) {
    if (formState.foodPackageId == null) return null;
    final matches = widget.hall.foodPackages.where(
      (p) => p.id == formState.foodPackageId,
    );
    return matches.isEmpty ? null : matches.first;
  }

  List<ExtraService> _selectedExtras(BookingFormState formState) {
    return widget.hall.extraServices
        .where((e) => formState.extraServiceIds.contains(e.id))
        .toList();
  }

  num _estimatedTotal(BookingFormState formState) {
    final package = _selectedPackage(formState);
    final foodTotal = (package?.pricePerHead ?? 0) * formState.guests;
    final extrasTotal = _selectedExtras(
      formState,
    ).fold<num>(0, (sum, e) => sum + e.price);
    return widget.hall.pricePerDay + foodTotal + extrasTotal;
  }

  Future<void> confirmBooking(BookingFormState formState) async {
    final hall = widget.hall;

    if (!hall.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This hall is not currently accepting bookings.'),
        ),
      );
      return;
    }

    if (formState.eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an event date")),
      );
      return;
    }

    if (formState.startTime == null || formState.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a start and end time")),
      );
      return;
    }

    if (formState.foodPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a food package")),
      );
      return;
    }

    if (formState.guests > hall.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Guest count can't exceed this hall's capacity of ${hall.capacity}.",
          ),
        ),
      );
      return;
    }

    final estimatedTotal = _estimatedTotal(formState);

    final request = CreateBookingRequest(
      hallId: hall.id,
      foodPackageId: formState.foodPackageId!,
      eventDate: formState.eventDate!,
      startTime: formState.startTime!,
      endTime: formState.endTime!,
      guestCount: formState.guests,
      extraServiceIds: formState.extraServiceIds.toList(),
    );

    final booking = await ref
        .read(bookingSubmitControllerProvider(hall.id).notifier)
        .submit(request);

    if (!mounted) return;

    if (booking != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            booking: booking,
            clientEstimatedTotal: estimatedTotal,
          ),
        ),
      );
    } else {
      final message = ref
          .read(bookingSubmitControllerProvider(hall.id))
          .errorMessage;

      if (message == _staleFoodPackageMessage ||
          message == _staleExtraServiceMessage) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Selection Out of Date"),
            content: Text(message!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        if (!mounted) return;
        ref.invalidate(hallDetailProvider(hall.id));
        Navigator.pop(context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Could not create booking")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;
    final formProvider = bookingFormControllerProvider(hall.id);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);
    final isSubmitting = ref.watch(
      bookingSubmitControllerProvider(hall.id).select((s) => s.isLoading),
    );

    final selectedPackage = _selectedPackage(formState);
    final foodPrice = (selectedPackage?.pricePerHead ?? 0) * formState.guests;
    final extrasPrice = _selectedExtras(
      formState,
    ).fold<num>(0, (sum, e) => sum + e.price);
    final totalPrice = hall.pricePerDay + foodPrice + extrasPrice;
    final exceedsCapacity = formState.guests > hall.capacity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Book Hall"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSummaryCard(
              imageUrl: hall.primaryImageUrl,
              hallName: hall.name,
              location: '${hall.address}, ${hall.city}',
              price: formatPkr(hall.pricePerDay),
            ),

            if (!hall.isActive) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  "This hall isn't currently accepting bookings.",
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.event, label: "Event Date"),
            const SizedBox(height: 10),
            DatePickerField(
              selectedDate: formState.eventDate,
              onDateChanged: (date) => formNotifier.setEventDate(date),
            ),

            const SizedBox(height: 16),

            _SectionTitle(icon: Icons.schedule, label: "Event Time"),
            const SizedBox(height: 10),
            TimeRangeField(
              startTime: formState.startTime,
              endTime: formState.endTime,
              onStartTimeChanged: (time) => formNotifier.setStartTime(time),
              onEndTimeChanged: (time) => formNotifier.setEndTime(time),
            ),

            const SizedBox(height: 24),

            GuestCounter(
              guests: formState.guests,
              onIncrement: () => formNotifier.setGuests(formState.guests + 50),
              onDecrement: () => formNotifier.setGuests(formState.guests - 50),
            ),
            if (exceedsCapacity) ...[
              const SizedBox(height: 6),
              Text(
                "This hall's capacity is ${hall.capacity} guests.",
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],

            const SizedBox(height: 24),

            FoodSelectionSection(
              foodPackages: hall.foodPackages,
              extraServices: hall.extraServices,
              selectedFoodPackageId: formState.foodPackageId,
              selectedExtraServiceIds: formState.extraServiceIds,
              onPackageChanged: (id) => formNotifier.setFoodPackage(id),
              onExtraChanged: (id, selected) =>
                  formNotifier.toggleExtraService(id, selected),
            ),

            const SizedBox(height: 24),

            BookingPriceSection(
              hallBasePrice: hall.pricePerDay,
              foodPrice: foodPrice,
              extrasPrice: extrasPrice,
              totalPrice: totalPrice,
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "This total is an estimate — the confirmed amount is calculated by the server.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.contact_phone, label: "Contact Information"),

            const SizedBox(height: 10),

            PhoneTextField(controller: phoneController),

            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.edit_note, label: "Special Requests"),

            const SizedBox(height: 10),

            SpecialRequestField(controller: specialRequestController),

            const SizedBox(height: 30),

            ConfirmBookingButton(
              label: isSubmitting ? "Confirming..." : "Confirm Booking",
              onPressed: isSubmitting ? null : () => confirmBooking(formState),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
