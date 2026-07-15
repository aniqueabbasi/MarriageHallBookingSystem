class ExtraService {
  final int id;
  final String name;
  final String description;
  final double price;

  const ExtraService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ExtraService.fromJson(Map<String, dynamic> json) => ExtraService(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
  );
}
