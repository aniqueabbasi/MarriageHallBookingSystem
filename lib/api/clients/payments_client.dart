import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/payments/create_payment_request.dart';
import 'package:marriage_hall_app/models/payments/payment.dart';

final paymentsClientProvider = Provider<PaymentsClient>(
  (ref) => PaymentsClient(ref.watch(apiClientProvider)),
);

class PaymentsClient {
  final ApiClient _client;

  PaymentsClient(this._client);

  /// Customer submits a payment against their own booking. Always created
  /// as `Pending` — it doesn't count toward `amountPaid` until the hall
  /// owner verifies it as `Completed`.
  Future<Payment> create(CreatePaymentRequest request) async {
    final json = await _client.post('/api/payments', request.toJson());
    return Payment.fromJson(json);
  }

  /// Payment history for a booking — visible to the booking's customer,
  /// the hall's owner, or an admin.
  Future<List<Payment>> listForBooking(int bookingId) async {
    final response = await _client.getList('/api/payments/booking/$bookingId');
    return response.map(Payment.fromJson).toList();
  }

  /// Owner/admin verifies a payment. [status] is one of `Pending`,
  /// `Completed`, `Failed`, `Refunded`; the server stamps `paidAt` itself
  /// when a payment becomes `Completed`.
  Future<Payment> updateStatus(int id, String status) async {
    final json = await _client.patch('/api/payments/$id/status', {
      'status': status,
    });
    return Payment.fromJson(json);
  }
}
