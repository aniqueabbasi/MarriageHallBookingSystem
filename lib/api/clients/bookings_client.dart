import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/booking/create_booking_request.dart';

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
}
