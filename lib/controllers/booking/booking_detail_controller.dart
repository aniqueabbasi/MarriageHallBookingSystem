import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/bookings_client.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';

/// Single source of truth for one booking's detail — invalidate this after
/// any status change or payment so every open view refetches.
final bookingDetailProvider = FutureProvider.autoDispose.family<Booking, int>(
  (ref, id) => ref.watch(bookingsClientProvider).getById(id),
);
