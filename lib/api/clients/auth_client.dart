import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/auth/login_request.dart';
import 'package:marriage_hall_app/models/auth/login_response.dart';
import 'package:marriage_hall_app/models/auth/register_request.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authClientProvider = Provider<AuthClient>(
  (ref) => AuthClient(ref.watch(apiClientProvider)),
);

class AuthClient {
  final ApiClient _client;

  AuthClient(this._client);

  Future<void> register(RegisterRequest request) {
    return _client.post('/api/auth/register', request.toJson());
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await _client.post('/api/auth/login', request.toJson());
    return LoginResponse.fromJson(json);
  }
}
