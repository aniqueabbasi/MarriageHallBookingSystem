import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/halls/create_hall_request.dart';
import 'package:marriage_hall_app/models/halls/create_virtual_tour_request.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';
import 'package:marriage_hall_app/models/halls/update_hall_request.dart';
import 'package:marriage_hall_app/models/halls/virtual_tour_info.dart';

final hallsClientProvider = Provider<HallsClient>(
  (ref) => HallsClient(ref.watch(apiClientProvider)),
);

class HallsClient {
  final ApiClient _client;

  HallsClient(this._client);

  Future<List<HallSummary>> list() async {
    final response = await _client.getList('/api/halls');
    return response.map((e) => HallSummary.fromJson(e)).toList();
  }

  /// Halls owned by the logged-in owner — identified from the JWT
  /// server-side, no params needed.
  Future<List<HallSummary>> getMyHalls() async {
    final response = await _client.getList('/api/halls/mine');
    return response.map((e) => HallSummary.fromJson(e)).toList();
  }

  Future<Hall> detail(int id) async {
    final json = await _client.get('/api/halls/$id');
    return Hall.fromJson(json);
  }

  /// `multipart/form-data` — at least one image required. Food
  /// packages/extra services (optional) go up as JSON-string fields since
  /// this is the only way to set them at creation time now.
  Future<Hall> create(CreateHallRequest request) async {
    final formData = FormData.fromMap({
      'Name': request.name,
      'Description': request.description,
      'Address': request.address,
      'City': request.city,
      'Capacity': request.capacity.toString(),
      'PricePerDay': request.pricePerDay.toString(),
      if (request.foodPackages.isNotEmpty)
        'FoodPackages': jsonEncode(
          request.foodPackages.map((p) => p.toJson()).toList(),
        ),
      if (request.extraServices.isNotEmpty)
        'ExtraServices': jsonEncode(
          request.extraServices.map((s) => s.toJson()).toList(),
        ),
      'Images': [
        for (final image in request.images)
          await MultipartFile.fromFile(image.path, filename: image.name),
      ],
    });

    final json = await _client.postForm('/api/halls', formData);
    return Hall.fromJson(json);
  }

  /// `multipart/form-data`. [UpdateHallRequest.newImages] is additive (and
  /// safe to omit — confirmed live that omitting `Images` leaves existing
  /// ones untouched). `FoodPackages`/`ExtraServices` are always sent in
  /// full, even when unchanged: omitting either clears it to empty
  /// server-side despite what the backend's docs claim, so every call
  /// must explicitly carry the hall's complete current set for whichever
  /// one isn't being actively modified.
  Future<Hall> updateHall(int id, UpdateHallRequest request) async {
    final formData = FormData.fromMap({
      'Name': request.name,
      'Description': request.description,
      'Address': request.address,
      'City': request.city,
      'Capacity': request.capacity.toString(),
      'PricePerDay': request.pricePerDay.toString(),
      'IsActive': request.isActive.toString(),
      'FoodPackages': jsonEncode(
        request.foodPackages.map((p) => p.toJson()).toList(),
      ),
      'ExtraServices': jsonEncode(
        request.extraServices.map((s) => s.toJson()).toList(),
      ),
      if (request.newImages.isNotEmpty)
        'Images': [
          for (final image in request.newImages)
            await MultipartFile.fromFile(image.path, filename: image.name),
        ],
    });

    final json = await _client.putForm('/api/halls/$id', formData);
    return Hall.fromJson(json);
  }

  /// Hard delete — the server rejects this with 409 if the hall has any
  /// bookings, in which case it should be deactivated instead.
  Future<void> deleteHall(int id) async {
    await _client.delete('/api/halls/$id');
  }

  /// Soft delete server-side. Swagger documents 200 but the server actually
  /// replies 204 with no body — don't parse a response here.
  Future<void> deleteFoodPackage(int hallId, int packageId) async {
    await _client.delete('/api/halls/$hallId/food-packages/$packageId');
  }

  /// Soft delete server-side. Swagger documents 200 but the server actually
  /// replies 204 with no body — don't parse a response here.
  Future<void> deleteExtraService(int hallId, int serviceId) async {
    await _client.delete('/api/halls/$hallId/extra-services/$serviceId');
  }

  Future<VirtualTourInfo> addVirtualTour(
    int hallId,
    CreateVirtualTourRequest request,
  ) async {
    final json = await _client.post(
      '/api/halls/$hallId/virtual-tours',
      request.toJson(),
    );
    return VirtualTourInfo.fromJson(json);
  }

  /// Soft delete server-side. Swagger documents 200 but the server actually
  /// replies 204 with no body — don't parse a response here.
  Future<void> deleteVirtualTour(int hallId, int tourId) async {
    await _client.delete('/api/halls/$hallId/virtual-tours/$tourId');
  }
}
