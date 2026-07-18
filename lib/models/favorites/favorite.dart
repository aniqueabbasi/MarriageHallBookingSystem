import 'package:marriage_hall_app/api/api_config.dart';

/// `FavoriteResponseDto` — a hall the customer has favorited, with enough
/// denormalized hall data to render a card even if the hall no longer
/// appears in the public list (e.g. it was deactivated).
class Favorite {
  final int id;
  final int hallId;
  final String hallName;
  final String city;
  final double pricePerDay;
  final String? primaryImageUrl;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.hallId,
    required this.hallName,
    required this.city,
    required this.pricePerDay,
    required this.primaryImageUrl,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    id: json['id'] as int,
    hallId: json['hallId'] as int,
    hallName: json['hallName'] as String? ?? '',
    city: json['city'] as String? ?? '',
    pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,
    primaryImageUrl: ApiConfig.resolveUrl(json['primaryImageUrl'] as String?),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
