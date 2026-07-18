import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/bookings_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';

/// The logged-in customer's bookings, all statuses mixed. Watches the auth
/// session so it refetches on login and empties on logout instead of
/// leaking one user's bookings into the next session.
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final session = ref.watch(authControllerProvider.select((s) => s.session));
  if (session != SessionStatus.authenticated) return const [];
  return ref.watch(bookingsClientProvider).getMine();
});
