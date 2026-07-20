import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/admin_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';
import 'package:marriage_hall_app/models/user_role.dart';

/// Every registered user. Only fetched for an authenticated Admin session
/// (the endpoint 403s for everyone else); session-scoped like the other
/// list providers so nothing leaks across logins.
final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  final auth = ref.watch(
    authControllerProvider.select((s) => (s.session, s.effectiveRole)),
  );
  if (auth.$1 != SessionStatus.authenticated || auth.$2 != UserRole.admin) {
    return const [];
  }
  return ref.watch(adminClientProvider).getAllUsers();
});
