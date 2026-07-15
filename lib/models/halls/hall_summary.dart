/// Lightweight shape returned by `GET /api/halls` (the browse/list view) —
/// deliberately thinner than [Hall] (`GET /api/halls/{id}`), which is the
/// only endpoint that returns food packages, extra services, full image
/// list, etc.
class HallSummary {
  final int id;
  final String name;
  final String city;
  final int capacity;
  final double pricePerDay;
  final bool isActive;
  final String? primaryImageUrl;
  final double averageRating;
  final int reviewCount;

  const HallSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
    required this.isActive,
    required this.primaryImageUrl,
    required this.averageRating,
    required this.reviewCount,
  });

  factory HallSummary.fromJson(Map<String, dynamic> json) => HallSummary(
    id: json['id'] as int,
    name: json['name'] as String,
    city: json['city'] as String,
    capacity: json['capacity'] as int,
    pricePerDay: (json['pricePerDay'] as num).toDouble(),
    isActive: json['isActive'] as bool? ?? false,
    primaryImageUrl: json['primaryImageUrl'] as String?,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
  );
}
