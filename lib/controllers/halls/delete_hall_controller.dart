import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';

enum DeleteHallStatus { idle, loading, success, error, conflict }

class DeleteHallState {
  final DeleteHallStatus status;
  final String? message;
  final int? statusCode;

  const DeleteHallState({
    this.status = DeleteHallStatus.idle,
    this.message,
    this.statusCode,
  });

  bool get isLoading => status == DeleteHallStatus.loading;
}

class DeleteHallController extends Notifier<DeleteHallState> {
  @override
  DeleteHallState build() => const DeleteHallState();

  /// Returns the resulting state directly (in addition to setting [state])
  /// since the caller needs to branch on success/conflict/error right away.
  Future<DeleteHallState> submit(int hallId) async {
    state = const DeleteHallState(status: DeleteHallStatus.loading);

    try {
      await ref.read(hallsClientProvider).deleteHall(hallId);
      state = const DeleteHallState(status: DeleteHallStatus.success);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // Not a failure — the server is telling us to deactivate instead.
        state = DeleteHallState(
          status: DeleteHallStatus.conflict,
          message: e.message,
          statusCode: e.statusCode,
        );
      } else {
        final message = switch (e.statusCode) {
          403 => "You don't have permission to delete this hall.",
          404 => "This hall was already removed.",
          _ => e.message,
        };
        state = DeleteHallState(
          status: DeleteHallStatus.error,
          message: message,
          statusCode: e.statusCode,
        );
      }
    } catch (_) {
      state = const DeleteHallState(
        status: DeleteHallStatus.error,
        message: 'Something went wrong. Please try again.',
      );
    }

    return state;
  }
}

/// Keyed by hall id so deleting different halls never shares stale state.
final deleteHallControllerProvider = NotifierProvider.autoDispose
    .family<DeleteHallController, DeleteHallState, int>(
      (hallId) => DeleteHallController(),
    );
