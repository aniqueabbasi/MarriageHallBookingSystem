class Booking {
  final int id;
  final int hallId;
  final String hallName;
  final int userId;
  final String customerName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final int guestCount;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final double amountPaid;
  final String foodPackageName;
  final List<String> extraServiceNames;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.hallId,
    required this.hallName,
    required this.userId,
    required this.customerName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.guestCount,
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    required this.amountPaid,
    required this.foodPackageName,
    required this.extraServiceNames,
    required this.createdAt,
  });

  /// `startTime`/`endTime` come back as Swashbuckle's `TimeOnly` rendering
  /// (e.g. `"14:00:00.379Z"`, per-request, the trailing `Z` isn't a real
  /// timezone) — lenient extraction of just `HH:mm` for display.
  static String formatTimeOfDay(String raw) {
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(raw);
    return match == null ? raw : '${match.group(1)}:${match.group(2)}';
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as int,
    hallId: json['hallId'] as int,
    hallName: json['hallName'] as String? ?? '',
    userId: json['userId'] as int,
    customerName: json['customerName'] as String? ?? '',
    eventDate: DateTime.parse(json['eventDate'] as String),
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    guestCount: json['guestCount'] as int,
    status: json['status'] as String,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    advanceAmount: (json['advanceAmount'] as num).toDouble(),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    foodPackageName: json['foodPackageName'] as String? ?? '',
    extraServiceNames: ((json['extraServiceNames'] as List?) ?? const [])
        .map((e) => e as String)
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
