import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';

enum FoodPackageActionStatus { idle, loading, success, error }

class FoodPackageActionState {
  final FoodPackageActionStatus status;
  final String? errorMessage;

  const FoodPackageActionState({
    this.status = FoodPackageActionStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == FoodPackageActionStatus.loading;
}

/// Keyed by hall id. Adding a food package is now folded into a full-hall
/// update (see [UpdateHallController]) since the standalone add endpoint
/// was removed — this controller only handles delete.
class FoodPackageController extends Notifier<FoodPackageActionState> {
  @override
  FoodPackageActionState build() => const FoodPackageActionState();

  Future<bool> deletePackage(int hallId, int packageId) async {
    state = const FoodPackageActionState(status: FoodPackageActionStatus.loading);
    try {
      await ref.read(hallsClientProvider).deleteFoodPackage(hallId, packageId);
      state = const FoodPackageActionState(status: FoodPackageActionStatus.success);
      return true;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to edit this hall.",
        404 => "This food package no longer exists.",
        _ => e.message,
      };
      state = FoodPackageActionState(
        status: FoodPackageActionStatus.error,
        errorMessage: message,
      );
      return false;
    } catch (_) {
      state = const FoodPackageActionState(
        status: FoodPackageActionStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final foodPackageControllerProvider = NotifierProvider.autoDispose
    .family<FoodPackageController, FoodPackageActionState, int>(
      (hallId) => FoodPackageController(),
    );
