import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/admin_client.dart';
import 'package:marriage_hall_app/controllers/admin/admin_users_controller.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/admin/admin_user.dart';

enum UpdateUserRoleStatus { idle, loading, success, error }

class UpdateUserRoleState {
  final UpdateUserRoleStatus status;
  final String? errorMessage;

  const UpdateUserRoleState({
    this.status = UpdateUserRoleStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == UpdateUserRoleStatus.loading;
}

/// Drives `PATCH /api/admin/users/{id}/role`. On success the users list
/// is invalidated so every open admin view refetches.
class UpdateUserRoleController extends Notifier<UpdateUserRoleState> {
  @override
  UpdateUserRoleState build() => const UpdateUserRoleState();

  /// [role] is the backend string (`Admin` / `HallOwner` / `Customer`).
  /// Returns the updated user, or null on failure with the error in
  /// [state]. Re-entrant calls while one is in flight are ignored.
  Future<AdminUser?> submit(int userId, String role) async {
    if (state.isLoading) return null;
    state = const UpdateUserRoleState(status: UpdateUserRoleStatus.loading);

    try {
      final user = await ref
          .read(adminClientProvider)
          .updateUserRole(userId, role);
      ref.invalidate(adminUsersProvider);
      state = const UpdateUserRoleState(status: UpdateUserRoleStatus.success);
      return user;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => 'Only an admin can change user roles.',
        404 => 'User not found.',
        _ => e.message,
      };
      state = UpdateUserRoleState(
        status: UpdateUserRoleStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const UpdateUserRoleState(
        status: UpdateUserRoleStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by user id so acting on different users never shares state.
final updateUserRoleControllerProvider = NotifierProvider.autoDispose
    .family<UpdateUserRoleController, UpdateUserRoleState, int>(
      (userId) => UpdateUserRoleController(),
    );
