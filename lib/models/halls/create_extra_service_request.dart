class CreateExtraServiceRequest {
  final String name;
  final String description;
  final double price;

  const CreateExtraServiceRequest({
    required this.name,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
  };
}
