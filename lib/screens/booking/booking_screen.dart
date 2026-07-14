import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marriage_hall_app/widgets/booking/food_selection_section.dart';
import 'package:marriage_hall_app/widgets/booking/guest_counter.dart';

import 'package:marriage_hall_app/resources/app_colors.dart';
import 'package:marriage_hall_app/resources/app_sizes.dart';
import 'package:marriage_hall_app/controllers/booking/booking_form_controller.dart';
import 'package:marriage_hall_app/screens/booking/booking_confirmation_screen.dart';
import 'package:marriage_hall_app/screens/booking/booking_summary_card.dart';
import 'package:marriage_hall_app/widgets/booking/advance_payment_breakdown.dart';
import 'package:marriage_hall_app/widgets/booking/booking_price_section.dart';
import 'package:marriage_hall_app/widgets/booking/confirm_booking_button.dart';
import 'package:marriage_hall_app/widgets/booking/date_picker_field.dart';
import 'package:marriage_hall_app/widgets/booking/phone_textfield.dart';
import 'package:marriage_hall_app/widgets/booking/special_request_field.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> hall;

  const BookingScreen({super.key, required this.hall});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  final Map<String, int> packagePrices = {
    "Standard Package": 1200,
    "Premium Package": 1800,
    "Luxury Package": 2500,
  };

  final Map<String, int> extraPrices = {
    "Cold Drinks": 15000,
    "Raita + Salad": 10000,
    "BBQ": 40000,
    "Extra Sweet Dish": 20000,
    "Mineral Water": 12000,
  };

  @override
  void dispose() {
    phoneController.dispose();
    specialRequestController.dispose();
    super.dispose();
  }

  int getHallBasePrice() {
    final priceText = widget.hall['price'].toString();
    final onlyNumbers = priceText.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyNumbers) ?? 0;
  }

  int foodPrice(BookingFormState formState) {
    return formState.guests * packagePrices[formState.selectedPackage]!;
  }

  int extrasPrice(BookingFormState formState) {
    int total = 0;

    for (var extra in formState.selectedExtras) {
      total += extraPrices[extra] ?? 0;
    }

    return total;
  }

  int totalPrice(BookingFormState formState) {
    return getHallBasePrice() + foodPrice(formState) + extrasPrice(formState);
  }

  int get advancePercentage {
    return int.tryParse('${widget.hall['advancePercentage'] ?? 20}') ?? 20;
  }

  int advanceAmount(BookingFormState formState) {
    return (totalPrice(formState) * advancePercentage / 100).round();
  }

  int remainingBalance(BookingFormState formState) {
    return totalPrice(formState) - advanceAmount(formState);
  }

  void confirmBooking(BookingFormState formState) {
    if (formState.bookingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a booking date")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          hallName: widget.hall['hallName'],
          bookingDate: formState.bookingDate!,
          guests: formState.guests,
          selectedPackage: formState.selectedPackage,
          selectedExtras: formState.selectedExtras,
          totalPrice: totalPrice(formState),
          advancePercentage: advancePercentage,
          advanceAmount: advanceAmount(formState),
          remainingBalance: remainingBalance(formState),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hallId = widget.hall['id'];
    final formProvider = bookingFormControllerProvider(hallId);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

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
              imagePath: widget.hall['imagePath'],
              hallName: widget.hall['hallName'],
              location: widget.hall['location'],
              price: widget.hall['price'],
            ),

            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.event, label: "Booking Date"),

            const SizedBox(height: 10),

            DatePickerField(
              selectedDate: formState.bookingDate,
              onDateChanged: (date) => formNotifier.setBookingDate(date),
            ),

            const SizedBox(height: 24),

            GuestCounter(
              guests: formState.guests,
              onIncrement: () => formNotifier.setGuests(formState.guests + 50),
              onDecrement: () => formNotifier.setGuests(formState.guests - 50),
            ),

            const SizedBox(height: 24),

            FoodSelectionSection(
              selectedPackage: formState.selectedPackage,
              selectedExtras: formState.selectedExtras,
              onPackageChanged: (value) {
                if (value != null) formNotifier.setPackage(value);
              },
              onExtraChanged: (extra, isSelected) {
                formNotifier.setExtraSelected(extra, isSelected);
              },
            ),

            const SizedBox(height: 24),

            BookingPriceSection(
              hallBasePrice: getHallBasePrice(),
              foodPrice: foodPrice(formState),
              extrasPrice: extrasPrice(formState),
              totalPrice: totalPrice(formState),
            ),

            const SizedBox(height: 16),

            AdvancePaymentBreakdown(
              totalPrice: totalPrice(formState),
              advancePercentage: advancePercentage,
              advanceAmount: advanceAmount(formState),
              remainingBalance: remainingBalance(formState),
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

            ConfirmBookingButton(onPressed: () => confirmBooking(formState)),

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
