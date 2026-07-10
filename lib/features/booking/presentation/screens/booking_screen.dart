import 'package:flutter/material.dart';
import 'package:marriage_hall_app/hall_detail/screens/food_selection_section.dart';
import 'package:marriage_hall_app/hall_detail/screens/guest_counter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'booking_confirmation_screen.dart';
import 'booking_summary_card.dart';
import '../widgets/advance_payment_breakdown.dart';
import '../widgets/booking_price_section.dart';
import '../widgets/confirm_booking_button.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/phone_textfield.dart';
import '../widgets/special_request_field.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> hall;

  const BookingScreen({super.key, required this.hall});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int guests = 100;
  DateTime? bookingDate;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  String selectedPackage = "Standard Package";
  List<String> selectedExtras = [];

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

  int get foodPrice {
    return guests * packagePrices[selectedPackage]!;
  }

  int get extrasPrice {
    int total = 0;

    for (var extra in selectedExtras) {
      total += extraPrices[extra] ?? 0;
    }

    return total;
  }

  int get totalPrice {
    return getHallBasePrice() + foodPrice + extrasPrice;
  }

  int get advancePercentage {
    return int.tryParse('${widget.hall['advancePercentage'] ?? 20}') ?? 20;
  }

  int get advanceAmount {
    return (totalPrice * advancePercentage / 100).round();
  }

  int get remainingBalance {
    return totalPrice - advanceAmount;
  }

  void confirmBooking() {
    if (bookingDate == null) {
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
          bookingDate: bookingDate!,
          guests: guests,
          selectedPackage: selectedPackage,
          selectedExtras: selectedExtras,
          totalPrice: totalPrice,
          advancePercentage: advancePercentage,
          advanceAmount: advanceAmount,
          remainingBalance: remainingBalance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              selectedDate: bookingDate,
              onDateChanged: (date) => setState(() => bookingDate = date),
            ),

            const SizedBox(height: 24),

            GuestCounter(
              guests: guests,
              onIncrement: () {
                setState(() {
                  guests += 50;
                });
              },
              onDecrement: () {
                if (guests > 50) {
                  setState(() {
                    guests -= 50;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            FoodSelectionSection(
              selectedPackage: selectedPackage,
              selectedExtras: selectedExtras,
              onPackageChanged: (value) {
                setState(() {
                  selectedPackage = value!;
                });
              },
              onExtraChanged: (extra, isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedExtras.add(extra);
                  } else {
                    selectedExtras.remove(extra);
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            BookingPriceSection(
              hallBasePrice: getHallBasePrice(),
              foodPrice: foodPrice,
              extrasPrice: extrasPrice,
              totalPrice: totalPrice,
            ),

            const SizedBox(height: 16),

            AdvancePaymentBreakdown(
              totalPrice: totalPrice,
              advancePercentage: advancePercentage,
              advanceAmount: advanceAmount,
              remainingBalance: remainingBalance,
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

            ConfirmBookingButton(onPressed: confirmBooking),

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
