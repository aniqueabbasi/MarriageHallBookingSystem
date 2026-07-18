import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/bookings_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/booking/update_booking_status_request.dart';

enum BookingStatusUpdateStatus { idle, loading, success, error }

class BookingStatusUpdateState {
  final BookingStatusUpdateStatus status;
  final String? errorMessage;

  const BookingStatusUpdateState({
    this.status = BookingStatusUpdateStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == BookingStatusUpdateStatus.loading;
}

/// Drives `PATCH /api/bookings/{id}/status` — confirm/reject/complete for
/// owners, cancel for either side. Callers are responsible for refreshing
/// whatever booking lists/details they're showing after success.
class BookingStatusController extends Notifier<BookingStatusUpdateState> {
  @override
  BookingStatusUpdateState build() => const BookingStatusUpdateState();

  /// [advanceAmount] is required when [status] is `Confirmed`, forbidden
  /// otherwise. Returns the updated booking, or null on failure with the
  /// error reflected in [state].
  Future<Booking?> submit(
    int bookingId,
    String status, {
    double? advanceAmount,
  }) async {
    state = const BookingStatusUpdateState(
      status: BookingStatusUpdateStatus.loading,
    );

    try {
      final booking = await ref
          .read(bookingsClientProvider)
          .updateStatus(
            bookingId,
            UpdateBookingStatusRequest(
              status: status,
              advanceAmount: advanceAmount,
            ),
          );
      state = const BookingStatusUpdateState(
        status: BookingStatusUpdateStatus.success,
      );
      return booking;
    } on ApiException catch (e) {
      // 400s carry a server explanation worth showing verbatim (invalid
      // transition, bad advance amount) — only the generic codes get
      // friendlier wording.
      final message = switch (e.statusCode) {
        403 => "You don't have permission to change this booking.",
        404 => 'This booking no longer exists.',
        _ => e.message,
      };
      state = BookingStatusUpdateState(
        status: BookingStatusUpdateStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const BookingStatusUpdateState(
        status: BookingStatusUpdateStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by booking id so acting on different bookings never shares state.
final bookingStatusControllerProvider = NotifierProvider.autoDispose
    .family<BookingStatusController, BookingStatusUpdateState, int>(
      (bookingId) => BookingStatusController(),
    );
