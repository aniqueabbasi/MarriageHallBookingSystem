/// `PaymentResponseDto` — a single payment made against a booking.
///
/// [status] is one of `Pending`, `Completed`, `Failed`, `Refunded`. Only
/// `Completed` payments count toward a booking's `amountPaid`, so a freshly
/// submitted payment (always `Pending`) is "awaiting verification" until the
/// hall owner marks it completed.
class Payment {
  final int id;
  final int bookingId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionId,
    required this.paidAt,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as int,
    bookingId: json['bookingId'] as int,
    amount: (json['amount'] as num).toDouble(),
    method: json['method'] as String,
    status: json['status'] as String,
    transactionId: json['transactionId'] as String?,
    paidAt: json['paidAt'] == null
        ? null
        : DateTime.parse(json['paidAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
