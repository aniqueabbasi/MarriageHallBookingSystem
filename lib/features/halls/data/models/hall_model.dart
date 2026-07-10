class HallModel {
  final int id;
  final String name;
  final String city;
  final String address;
  final String imageColor;
  final int capacityMin;
  final int capacityMax;
  final int price;
  final double rating;
  final int reviews;
  final List<String> amenities;
  final String description;
  final bool isFavourite;

  HallModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.imageColor,
    required this.capacityMin,
    required this.capacityMax,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.amenities,
    required this.description,
    this.isFavourite = false,
  });
}
