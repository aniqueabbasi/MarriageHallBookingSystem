import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/payments_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';

enum VerifyPaymentStatus { idle, loading, success, error }

class VerifyPaymentState {
  final VerifyPaymentStatus status;
  final String? errorMessage;

  const VerifyPaymentState({
    this.status = VerifyPaymentStatus.idle,
    this.errorMessage,
  });

  bool get isLoading => status == VerifyPaymentStatus.loading;
}

/// Hall owner marks a payment `Completed`/`Failed`/`Refunded`.
class VerifyPaymentController extends Notifier<VerifyPaymentState> {
  @override
  VerifyPaymentState build() => const VerifyPaymentState();

  Future<Payment?> submit(int paymentId, String status) async {
    state = const VerifyPaymentState(status: VerifyPaymentStatus.loading);

    try {
      final payment = await ref
          .read(paymentsClientProvider)
          .updateStatus(paymentId, status);
      state = const VerifyPaymentState(status: VerifyPaymentStatus.success);
      return payment;
    } on ApiException catch (e) {
      final message = switch (e.statusCode) {
        403 => "You don't have permission to verify this payment.",
        404 => 'This payment no longer exists.',
        _ => e.message,
      };
      state = VerifyPaymentState(
        status: VerifyPaymentStatus.error,
        errorMessage: message,
      );
      return null;
    } catch (_) {
      state = const VerifyPaymentState(
        status: VerifyPaymentStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

/// Keyed by payment id.
final verifyPaymentControllerProvider = NotifierProvider.autoDispose
    .family<VerifyPaymentController, VerifyPaymentState, int>(
      (paymentId) => VerifyPaymentController(),
    );
