import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/bookings_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';

/// Incoming bookings across every hall the logged-in owner owns — the feed
/// the owner confirms/rejects from. Session-scoped like [myBookingsProvider].
final ownerBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final session = ref.watch(authControllerProvider.select((s) => s.session));
  if (session != SessionStatus.authenticated) return const [];
  return ref.watch(bookingsClientProvider).getForMyHalls();
});
