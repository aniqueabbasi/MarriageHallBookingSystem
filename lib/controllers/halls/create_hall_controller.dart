import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/halls_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/halls/create_hall_request.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';

enum CreateHallStatus { idle, loading, success, error }

class CreateHallState {
  final CreateHallStatus status;
  final String? errorMessage;
  final Hall? hall;

  const CreateHallState({
    this.status = CreateHallStatus.idle,
    this.errorMessage,
    this.hall,
  });

  bool get isLoading => status == CreateHallStatus.loading;
}

class CreateHallController extends Notifier<CreateHallState> {
  @override
  CreateHallState build() => const CreateHallState();

  Future<Hall?> submit(CreateHallRequest request) async {
    state = const CreateHallState(status: CreateHallStatus.loading);

    try {
      final hall = await ref.read(hallsClientProvider).create(request);
      state = CreateHallState(status: CreateHallStatus.success, hall: hall);
      return hall;
    } on ApiException catch (e) {
      state = CreateHallState(
        status: CreateHallStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (_) {
      state = const CreateHallState(
        status: CreateHallStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Scoped to a single Add-Hall screen visit — autoDispose, no family needed
/// since only one hall is ever being created at a time.
final createHallControllerProvider =
    NotifierProvider.autoDispose<CreateHallController, CreateHallState>(
      CreateHallController.new,
    );
