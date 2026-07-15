import 'package:marriage_hall_app/models/halls/extra_service.dart';
import 'package:marriage_hall_app/models/halls/food_package.dart';
import 'package:marriage_hall_app/models/halls/hall_image.dart';
import 'package:marriage_hall_app/models/halls/virtual_tour_info.dart';

/// Full detail shape returned by `GET /api/halls/{id}` — the only endpoint
/// that includes food packages / extra services, which booking depends on.
class Hall {
  final int id;
  final int ownerId;
  final String ownerName;
  final String name;
  final String description;
  final String address;
  final String city;
  final int capacity;
  final double pricePerDay;
  final bool isActive;
  final double averageRating;
  final int reviewCount;
  final List<HallImage> images;
  final List<VirtualTourInfo> virtualTours;
  final List<FoodPackage> foodPackages;
  final List<ExtraService> extraServices;

  const Hall({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
    required this.isActive,
    required this.averageRating,
    required this.reviewCount,
    required this.images,
    required this.virtualTours,
    required this.foodPackages,
    required this.extraServices,
  });

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary);
    return primary.isEmpty ? images.first.imageUrl : primary.first.imageUrl;
  }

  factory Hall.fromJson(Map<String, dynamic> json) => Hall(
    id: json['id'] as int,
    ownerId: json['ownerId'] as int,
    ownerName: json['ownerName'] as String? ?? '',
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    address: json['address'] as String? ?? '',
    city: json['city'] as String,
    capacity: json['capacity'] as int,
    pricePerDay: (json['pricePerDay'] as num).toDouble(),
    isActive: json['isActive'] as bool? ?? false,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    images: ((json['images'] as List?) ?? const [])
        .map((e) => HallImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    virtualTours: ((json['virtualTours'] as List?) ?? const [])
        .map((e) => VirtualTourInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    foodPackages: ((json['foodPackages'] as List?) ?? const [])
        .map((e) => FoodPackage.fromJson(e as Map<String, dynamic>))
        .toList(),
    extraServices: ((json['extraServices'] as List?) ?? const [])
        .map((e) => ExtraService.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
