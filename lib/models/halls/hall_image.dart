class HallImage {
  final int id;
  final String imageUrl;
  final bool isPrimary;

  const HallImage({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });

  factory HallImage.fromJson(Map<String, dynamic> json) => HallImage(
    id: json['id'] as int,
    imageUrl: json['imageUrl'] as String,
    isPrimary: json['isPrimary'] as bool? ?? false,
  );
}
