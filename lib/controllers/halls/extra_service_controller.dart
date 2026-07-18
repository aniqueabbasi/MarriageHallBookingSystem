import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';

enum ExtraServiceActionStatus { idle, loading, success, error }

class ExtraServiceActionState {
  final ExtraServiceActionStatus status;
  final String? errorMessage;

  const ExtraServiceActionState({
    this.status = ExtraServiceActionStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == ExtraServiceActionStatus.loading;
}

/// Keyed by hall id. Adding an extra service is now folded into a full-hall
/// update (see [UpdateHallController]) since the standalone add endpoint
/// was removed — this controller only handles delete.
class ExtraServiceController extends Notifier<ExtraServiceActionState> {
  @override
  ExtraServiceActionState build() => const ExtraServiceActionState();

  Future<bool> deleteService(int hallId, int serviceId) async {
    state = const ExtraServiceActionState(status: ExtraServiceActionStatus.loading);
    try {
      await ref.read(hallsClientProvider).deleteExtraService(hallId, serviceId);
      state = const ExtraServiceActionState(status: ExtraServiceActionStatus.success);
      return true;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to edit this hall.",
        404 => "This service no longer exists.",
        _ => e.message,
      };
      state = ExtraServiceActionState(
        status: ExtraServiceActionStatus.error,
        errorMessage: message,
      );
      return false;
    } catch (_) {
      state = const ExtraServiceActionState(
        status: ExtraServiceActionStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final extraServiceControllerProvider = NotifierProvider.autoDispose
    .family<ExtraServiceController, ExtraServiceActionState, int>(
      (hallId) => ExtraServiceController(),
    );
