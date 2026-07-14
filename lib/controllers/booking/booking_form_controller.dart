import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingFormState {
  final int guests;
  final DateTime? bookingDate;
  final String selectedPackage;
  final List<String> selectedExtras;

  const BookingFormState({
    this.guests = 100,
    this.bookingDate,
    this.selectedPackage = "Standard Package",
    this.selectedExtras = const [],
  });

  BookingFormState copyWith({
    int? guests,
    DateTime? bookingDate,
    String? selectedPackage,
    List<String>? selectedExtras,
  }) {
    return BookingFormState(
      guests: guests ?? this.guests,
      bookingDate: bookingDate ?? this.bookingDate,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedExtras: selectedExtras ?? this.selectedExtras,
    );
  }
}

class BookingFormController extends Notifier<BookingFormState> {
  @override
  BookingFormState build() => const BookingFormState();

  void setGuests(int value) {
    if (value >= 50) state = state.copyWith(guests: value);
  }

  void setBookingDate(DateTime date) =>
      state = state.copyWith(bookingDate: date);

  void setPackage(String package) =>
      state = state.copyWith(selectedPackage: package);

  void setExtraSelected(String extra, bool isSelected) {
    final updated = [...state.selectedExtras];
    if (isSelected) {
      if (!updated.contains(extra)) updated.add(extra);
    } else {
      updated.remove(extra);
    }
    state = state.copyWith(selectedExtras: updated);
  }
}

/// Keyed by hall id so booking a different hall always starts fresh.
final bookingFormControllerProvider = NotifierProvider.autoDispose
    .family<BookingFormController, BookingFormState, String>(
      (hallId) => BookingFormController(),
    );
