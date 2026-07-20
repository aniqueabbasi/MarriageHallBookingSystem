import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/admin_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/user_role.dart';

/// Every booking across the platform. Admin-session-only, same scoping
/// rationale as [adminUsersProvider].
final adminBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final auth = ref.watch(
    authControllerProvider.select((s) => (s.session, s.effectiveRole)),
  );
  if (auth.$1 != SessionStatus.authenticated || auth.$2 != UserRole.admin) {
    return const [];
  }
  return ref.watch(adminClientProvider).getAllBookings();
});
