import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/bookings_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/booking/create_booking_request.dart';

enum BookingSubmitStatus { idle, loading, success, error }

class BookingSubmitState {
  final BookingSubmitStatus status;
  final String? errorMessage;
  final Booking? booking;

  const BookingSubmitState({
    this.status = BookingSubmitStatus.idle,
    this.errorMessage,
    this.booking,
  });

  bool get isLoading => status == BookingSubmitStatus.loading;
}

class BookingSubmitController extends Notifier<BookingSubmitState> {
  @override
  BookingSubmitState build() => const BookingSubmitState();

  Future<Booking?> submit(CreateBookingRequest request) async {
    state = const BookingSubmitState(status: BookingSubmitStatus.loading);

    try {
      final booking = await ref.read(bookingsClientProvider).create(request);
      state = BookingSubmitState(
        status: BookingSubmitStatus.success,
        booking: booking,
      );
      return booking;
    } on ApiException catch (e) {
      state = BookingSubmitState(
        status: BookingSubmitStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (_) {
      state = const BookingSubmitState(
        status: BookingSubmitStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by hall id, same lifecycle rationale as [BookingFormController].
final bookingSubmitControllerProvider = NotifierProvider.autoDispose
    .family<BookingSubmitController, BookingSubmitState, int>(
      (hallId) => BookingSubmitController(),
    );
