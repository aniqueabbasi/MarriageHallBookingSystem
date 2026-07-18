import 'package:marriage_hall_app/models/halls/create_extra_service_request.dart';

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

  /// Used to rebuild the "existing items" half of a full-replace update —
  /// the update endpoint takes the create shape (no id), not this one.
  CreateExtraServiceRequest toCreateRequest() =>
      CreateExtraServiceRequest(name: name, description: description, price: price);
}
