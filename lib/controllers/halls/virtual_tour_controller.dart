import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/halls/create_virtual_tour_request.dart';
import 'package:marriage_hall_app/models/halls/virtual_tour_info.dart';

enum VirtualTourActionStatus { idle, loading, success, error }

class VirtualTourActionState {
  final VirtualTourActionStatus status;
  final String? errorMessage;

  const VirtualTourActionState({
    this.status = VirtualTourActionStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == VirtualTourActionStatus.loading;
}

/// Keyed by hall id. Handles both add and delete for that hall's virtual
/// tours — the owner-facing UI only ever has one such action in flight at
/// a time, so a single busy flag is enough.
class VirtualTourController extends Notifier<VirtualTourActionState> {
  @override
  VirtualTourActionState build() => const VirtualTourActionState();

  Future<VirtualTourInfo?> addTour(
    int hallId,
    CreateVirtualTourRequest request,
  ) async {
    state = const VirtualTourActionState(status: VirtualTourActionStatus.loading);
    try {
      final tour = await ref
          .read(hallsClientProvider)
          .addVirtualTour(hallId, request);
      state = const VirtualTourActionState(status: VirtualTourActionStatus.success);
      return tour;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to edit this hall.",
        404 => "This hall no longer exists.",
        _ => e.message,
      };
      state = VirtualTourActionState(
        status: VirtualTourActionStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const VirtualTourActionState(
        status: VirtualTourActionStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }

  Future<bool> deleteTour(int hallId, int tourId) async {
    state = const VirtualTourActionState(status: VirtualTourActionStatus.loading);
    try {
      await ref.read(hallsClientProvider).deleteVirtualTour(hallId, tourId);
      state = const VirtualTourActionState(status: VirtualTourActionStatus.success);
      return true;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to edit this hall.",
        404 => "This virtual tour no longer exists.",
        _ => e.message,
      };
      state = VirtualTourActionState(
        status: VirtualTourActionStatus.error,
        errorMessage: message,
      );
      return false;
    } catch (_) {
      state = const VirtualTourActionState(
        status: VirtualTourActionStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final virtualTourControllerProvider = NotifierProvider.autoDispose
    .family<VirtualTourController, VirtualTourActionState, int>(
      (hallId) => VirtualTourController(),
    );
