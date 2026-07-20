import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/profile/user_profile.dart';

final usersClientProvider = Provider<UsersClient>(
  (ref) => UsersClient(ref.watch(apiClientProvider)),
);

/// The logged-in user's own profile — works for every role.
class UsersClient {
  final ApiClient _client;

  UsersClient(this._client);

  Future<UserProfile> getMe() async {
    final json = await _client.get('/api/users/me');
    return UserProfile.fromJson(json);
  }

  /// 409 if the new email belongs to another account.
  Future<UserProfile> updateMe(UpdateProfileRequest request) async {
    final json = await _client.put('/api/users/me', request.toJson());
    return UserProfile.fromJson(json);
  }
}
