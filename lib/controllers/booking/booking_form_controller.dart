import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingFormState {
  final int guests;
  final DateTime? eventDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int? foodPackageId;
  final Set<int> extraServiceIds;

  const BookingFormState({
    this.guests = 100,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.foodPackageId,
    this.extraServiceIds = const {},
  });

  BookingFormState copyWith({
    int? guests,
    DateTime? eventDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? foodPackageId,
    Set<int>? extraServiceIds,
  }) {
    return BookingFormState(
      guests: guests ?? this.guests,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      foodPackageId: foodPackageId ?? this.foodPackageId,
      extraServiceIds: extraServiceIds ?? this.extraServiceIds,
    );
  }
}

class BookingFormController extends Notifier<BookingFormState> {
  @override
  BookingFormState build() => const BookingFormState();

  void setGuests(int value) {
    if (value >= 50) state = state.copyWith(guests: value);
  }

  void setEventDate(DateTime date) =>
      state = state.copyWith(eventDate: date);

  void setStartTime(TimeOfDay time) =>
      state = state.copyWith(startTime: time);

  void setEndTime(TimeOfDay time) => state = state.copyWith(endTime: time);

  void setFoodPackage(int foodPackageId) =>
      state = state.copyWith(foodPackageId: foodPackageId);

  void toggleExtraService(int extraServiceId, bool isSelected) {
    final updated = {...state.extraServiceIds};
    if (isSelected) {
      updated.add(extraServiceId);
    } else {
      updated.remove(extraServiceId);
    }
    state = state.copyWith(extraServiceIds: updated);
  }
}

/// Keyed by hall id so booking a different hall always starts fresh.
final bookingFormControllerProvider = NotifierProvider.autoDispose
    .family<BookingFormController, BookingFormState, int>(
      (hallId) => BookingFormController(),
    );
