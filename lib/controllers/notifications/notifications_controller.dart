import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/notifications_client.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/models/notifications/app_notification.dart';

/// The current user's notifications, newest first. Mark-as-read is applied
/// optimistically (the list flips locally before the PATCH lands) since
/// the server call can't meaningfully fail in a way the user should care
/// about — a 404 just means it was already gone.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final session = ref.watch(authControllerProvider.select((s) => s.session));
    if (session != SessionStatus.authenticated) return const [];
    return ref.watch(notificationsClientProvider).list();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationsClientProvider).list(),
    );
  }

  Future<void> markRead(int id) async {
    final current = state.value;
    if (current == null) return;
    final target = current.where((n) => n.id == id).firstOrNull;
    if (target == null || target.isRead) return;

    state = AsyncData([
      for (final n in current) n.id == id ? n.copyWith(isRead: true) : n,
    ]);
    try {
      await ref.read(notificationsClientProvider).markRead(id);
    } catch (_) {
      // Leave it marked locally; the next refresh restores server truth.
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null || current.every((n) => n.isRead)) return;

    state = AsyncData([
      for (final n in current) n.isRead ? n : n.copyWith(isRead: true),
    ]);
    try {
      await ref.read(notificationsClientProvider).markAllRead();
    } catch (_) {
      // Same as markRead — refresh reconciles.
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

/// Unread count for badges.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value;
  return notifications?.where((n) => !n.isRead).length ?? 0;
});
