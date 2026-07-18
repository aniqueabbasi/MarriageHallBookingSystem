import 'package:image_picker/image_picker.dart';

import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';
import 'package:marriage_hall_app/models/halls/create_food_package_request.dart';

/// Backend now takes this as `multipart/form-data` — at least one image is
/// required, food packages/extra services (optional) go up as JSON-string
/// form fields since this is the only way to set them at creation time.
class CreateHallRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final int capacity;
  final double pricePerDay;
  final List<XFile> images;
  final List<CreateFoodPackageRequest> foodPackages;
  final List<CreateExtraServiceRequest> extraServices;

  const CreateHallRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
    required this.images,
    this.foodPackages = const [],
    this.extraServices = const [],
  });
}
