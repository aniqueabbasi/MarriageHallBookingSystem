import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/notifications/app_notification.dart';

final notificationsClientProvider = Provider<NotificationsClient>(
  (ref) => NotificationsClient(ref.watch(apiClientProvider)),
);

/// Notifications are generated entirely server-side (booking/payment
/// status changes) — this client only reads and marks them.
class NotificationsClient {
  final ApiClient _client;

  NotificationsClient(this._client);

  /// Newest first, as returned by the server.
  Future<List<AppNotification>> list() async {
    final response = await _client.getList('/api/notifications');
    return response.map(AppNotification.fromJson).toList();
  }

  /// 204 on success; 404 covers both "doesn't exist" and "not yours".
  Future<void> markRead(int id) async {
    await _client.patch('/api/notifications/$id/read', const {});
  }

  /// Marks every unread notification for the current user in one call —
  /// 204, no body.
  Future<void> markAllRead() async {
    await _client.patch('/api/notifications/read-all', const {});
  }
}
