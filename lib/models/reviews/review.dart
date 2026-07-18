/// `ReviewResponseDto` — one customer review of a hall.
class Review {
  final int id;
  final int hallId;
  final int userId;
  final String customerName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.hallId,
    required this.userId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as int,
    hallId: json['hallId'] as int,
    userId: json['userId'] as int,
    customerName: json['customerName'] as String? ?? '',
    rating: json['rating'] as int,
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
