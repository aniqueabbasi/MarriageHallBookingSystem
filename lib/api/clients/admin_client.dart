import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';
import 'package:marriage_hall_app/models/booking/booking.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';

final adminClientProvider = Provider<AdminClient>(
  (ref) => AdminClient(ref.watch(apiClientProvider)),
);

/// All four endpoints require an Admin-role JWT — anyone else gets 403.
class AdminClient {
  final ApiClient _client;

  AdminClient(this._client);

  Future<List<AdminUser>> getAllUsers() async {
    final response = await _client.getList('/api/admin/users');
    return response.map(AdminUser.fromJson).toList();
  }

  /// [role] is the backend string (`Admin` / `HallOwner` / `Customer`),
  /// sent as a bare JSON string body — see [ApiClient.patchRaw].
  Future<AdminUser> updateUserRole(int userId, String role) async {
    final json = await _client.patchRaw('/api/admin/users/$userId/role', role);
    return AdminUser.fromJson(
      json is Map<String, dynamic> ? json : const {},
    );
  }

  /// Every hall on the platform, including inactive ones (the public
  /// listing hides those). Same dto shape as the public list.
  Future<List<HallSummary>> getAllHalls() async {
    final response = await _client.getList('/api/admin/halls');
    return response.map((e) => HallSummary.fromJson(e)).toList();
  }

  /// Every booking across the whole platform.
  Future<List<Booking>> getAllBookings() async {
    final response = await _client.getList('/api/admin/bookings');
    return response.map(Booking.fromJson).toList();
  }
}
