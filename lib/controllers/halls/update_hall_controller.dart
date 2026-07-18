import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/models/halls/update_hall_request.dart';

enum UpdateHallStatus { idle, loading, success, error }

class UpdateHallState {
  final UpdateHallStatus status;
  final String? errorMessage;
  final Hall? hall;

  const UpdateHallState({
    this.status = UpdateHallStatus.idle,
    this.errorMessage,
    this.hall,
  });

  bool get isLoading => status == UpdateHallStatus.loading;
}

class UpdateHallController extends Notifier<UpdateHallState> {
  @override
  UpdateHallState build() => const UpdateHallState();

  Future<Hall?> submit(int hallId, UpdateHallRequest request) async {
    state = const UpdateHallState(status: UpdateHallStatus.loading);

    try {
      final hall = await ref
          .read(hallsClientProvider)
          .updateHall(hallId, request);
      state = UpdateHallState(status: UpdateHallStatus.success, hall: hall);
      return hall;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to edit this hall.",
        404 => "This hall no longer exists.",
        _ => e.message,
      };
      state = UpdateHallState(
        status: UpdateHallStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const UpdateHallState(
        status: UpdateHallStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by hall id so editing different halls never shares stale state.
final updateHallControllerProvider = NotifierProvider.autoDispose
    .family<UpdateHallController, UpdateHallState, int>(
      (hallId) => UpdateHallController(),
    );
