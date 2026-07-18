/// Body for `POST /api/payments` — customer submits a payment against
/// their own booking. [method] must be one of the values in
/// [PaymentMethods.all].
class CreatePaymentRequest {
  final int bookingId;
  final double amount;
  final String method;
  final String? transactionId;

  const CreatePaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.method,
    this.transactionId,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'amount': amount,
    'method': method,
    if (transactionId != null && transactionId!.isNotEmpty)
      'transactionId': transactionId,
  };
}

class PaymentMethods {
  PaymentMethods._();

  static const all = [
    'Cash',
    'CreditCard',
    'DebitCard',
    'BankTransfer',
    'JazzCash',
    'EasyPaisa',
  ];

  /// Human-readable label for a backend method value.
  static String label(String method) => switch (method) {
    'CreditCard' => 'Credit Card',
    'DebitCard' => 'Debit Card',
    'BankTransfer' => 'Bank Transfer',
    _ => method,
  };
}
