import 'package:marriage_hall_app/models/user_role.dart';

class AuthUser {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    role: UserRoleX.fromApiRole(json['role'] as String),
  );
}
