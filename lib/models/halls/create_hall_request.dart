class CreateHallRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final int capacity;
  final double pricePerDay;

  const CreateHallRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'address': address,
    'city': city,
    'capacity': capacity,
    'pricePerDay': pricePerDay,
  };
}
