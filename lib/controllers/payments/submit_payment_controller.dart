import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/payments_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/payments/create_payment_request.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';

enum SubmitPaymentStatus { idle, loading, success, error }

class SubmitPaymentState {
  final SubmitPaymentStatus status;
  final String? errorMessage;

  const SubmitPaymentState({
    this.status = SubmitPaymentStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == SubmitPaymentStatus.loading;
}

/// Customer submits a payment against their booking. The created payment
/// is always `Pending` until the hall owner verifies it.
class SubmitPaymentController extends Notifier<SubmitPaymentState> {
  @override
  SubmitPaymentState build() => const SubmitPaymentState();

  Future<Payment?> submit(CreatePaymentRequest request) async {
    state = const SubmitPaymentState(status: SubmitPaymentStatus.loading);

    try {
      final payment = await ref.read(paymentsClientProvider).create(request);
      state = const SubmitPaymentState(status: SubmitPaymentStatus.success);
      return payment;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => 'You can only pay for your own bookings.',
        404 => 'This booking no longer exists.',
        _ => e.message,
      };
      state = SubmitPaymentState(
        status: SubmitPaymentStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const SubmitPaymentState(
        status: SubmitPaymentStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by booking id.
final submitPaymentControllerProvider = NotifierProvider.autoDispose
    .family<SubmitPaymentController, SubmitPaymentState, int>(
      (bookingId) => SubmitPaymentController(),
    );
