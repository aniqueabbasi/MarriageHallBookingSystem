class CreateFoodPackageRequest {
  final String name;
  final String description;
  final double pricePerHead;

  const CreateFoodPackageRequest({
    required this.name,
    required this.description,
    required this.pricePerHead,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'pricePerHead': pricePerHead,
  };
}
