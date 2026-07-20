import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_client.dart';
import 'package:marriage_hall_app/models/auth/login_request.dart';
import 'package:marriage_hall_app/models/auth/login_response.dart';
import 'package:marriage_hall_app/models/auth/register_request.dart';

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

  /// Always succeeds with a neutral message server-side (whether or not
  /// the email exists) to avoid account enumeration. Resending within the
  /// 60s cooldown is silently ignored by the server.
  Future<void> forgotPassword(String email) {
    return _client.post('/api/auth/forgot-password', {'email': email});
  }

  /// Exchanges a valid 6-digit OTP for a short-lived reset token. 401 on
  /// wrong/expired OTP; OTPs lock after 5 failed attempts.
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final json = await _client.post('/api/auth/verify-reset-otp', {
      'email': email,
      'otp': otp,
    });
    return json['resetToken'] as String? ?? '';
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) {
    return _client.post('/api/auth/reset-password', {
      'email': email,
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }
}
