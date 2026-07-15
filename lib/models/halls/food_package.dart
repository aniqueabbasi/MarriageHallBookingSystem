class FoodPackage {
  final int id;
  final String name;
  final String description;
  final double pricePerHead;

  const FoodPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHead,
  });

  factory FoodPackage.fromJson(Map<String, dynamic> json) => FoodPackage(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    pricePerHead: (json['pricePerHead'] as num).toDouble(),
  );
}
