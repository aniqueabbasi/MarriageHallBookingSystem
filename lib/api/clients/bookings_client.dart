import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/booking/create_booking_request.dart';
import 'package:marriage_hall_app/models/booking/update_booking_status_request.dart';

final bookingsClientProvider = Provider<BookingsClient>(
  (ref) => BookingsClient(ref.watch(apiClientProvider)),
);

class BookingsClient {
  final ApiClient _client;

  BookingsClient(this._client);

  Future<Booking> create(CreateBookingRequest request) async {
    final json = await _client.post('/api/bookings', request.toJson());
    return Booking.fromJson(json);
  }

  /// Only viewable by the booking's customer, the hall's owner, or an
  /// admin — anyone else gets 403.
  Future<Booking> getById(int id) async {
    final json = await _client.get('/api/bookings/$id');
    return Booking.fromJson(json);
  }

  /// Every booking made by the logged-in customer, all statuses mixed —
  /// filtering/grouping by status is the UI's job. Customer role only.
  Future<List<Booking>> getMine() async {
    final response = await _client.getList('/api/bookings/mine');
    return response.map(Booking.fromJson).toList();
  }

  /// Every booking made against any hall the logged-in owner owns, across
  /// all halls and statuses. HallOwner role only.
  Future<List<Booking>> getForMyHalls() async {
    final response = await _client.getList('/api/bookings/for-my-halls');
    return response.map(Booking.fromJson).toList();
  }

  /// Confirm/reject/complete (owner) or cancel (customer or owner). The
  /// server enforces the transition table: Pending → Confirmed/Rejected/
  /// Cancelled, Confirmed → Completed/Cancelled, everything else terminal.
  Future<Booking> updateStatus(int id, UpdateBookingStatusRequest request) async {
    final json = await _client.patch('/api/bookings/$id/status', request.toJson());
    return Booking.fromJson(json);
  }
}
