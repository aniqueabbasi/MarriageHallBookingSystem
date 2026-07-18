import 'package:image_picker/image_picker.dart';

import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';
import 'package:marriage_hall_app/models/halls/create_food_package_request.dart';

/// Backend now takes this as `multipart/form-data`.
///
/// [newImages] is additive — anything here gets appended to the hall's
/// existing images, none become primary. Leave empty to add no photos.
///
/// [foodPackages]/[extraServices] are a full replace, not additive —
/// **and, contrary to the backend's own documentation, omitting the field
/// does NOT preserve the existing set: it clears it to empty.** Confirmed
/// live via direct API calls, so every update must always pass the
/// hall's complete current set for whichever of these it isn't actively
/// changing (never rely on omission to preserve).
class UpdateHallRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final int capacity;
  final double pricePerDay;
  final bool isActive;
  final List<XFile> newImages;
  final List<CreateFoodPackageRequest> foodPackages;
  final List<CreateExtraServiceRequest> extraServices;

  const UpdateHallRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
    required this.isActive,
    required this.foodPackages,
    required this.extraServices,
    this.newImages = const [],
  });
}
