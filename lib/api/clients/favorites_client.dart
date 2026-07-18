import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/favorites/favorite.dart';

final favoritesClientProvider = Provider<FavoritesClient>(
  (ref) => FavoritesClient(ref.watch(apiClientProvider)),
);

/// All three endpoints require the Customer role. Add/remove are keyed by
/// the hall's id, not the favorite row's own id.
class FavoritesClient {
  final ApiClient _client;

  FavoritesClient(this._client);

  Future<List<Favorite>> list() async {
    final response = await _client.getList('/api/favorites');
    return response.map(Favorite.fromJson).toList();
  }

  /// 409 if already favorited, 404 if the hall doesn't exist.
  Future<Favorite> add(int hallId) async {
    final json = await _client.post('/api/favorites/$hallId', const {});
    return Favorite.fromJson(json);
  }

  /// 204 on success, 404 if the hall isn't currently favorited.
  Future<void> remove(int hallId) async {
    await _client.delete('/api/favorites/$hallId');
  }
}
