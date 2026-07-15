import 'package:marriage_hall_app/models/auth/auth_user.dart';

class LoginResponse {
  final String accessToken;

  /// The backend now issues a single long-lived access token — this is
  /// kept only in case an older/other backend instance still sends it.
  /// Nothing reads it.
  final String? refreshToken;

  final DateTime expiresAt;
  final AuthUser user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}
