import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/halls/create_hall_request.dart';
import 'package:marriage_hall_app/models/halls/hall.dart';
import 'package:marriage_hall_app/models/halls/hall_summary.dart';

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

  Future<Hall> create(CreateHallRequest request) async {
    final json = await _client.post('/api/halls', request.toJson());
    return Hall.fromJson(json);
  }
}
