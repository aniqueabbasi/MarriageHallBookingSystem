import 'package:marriage_hall_app/models/user_role.dart';

/// `UserDto` from the admin endpoints — one registered user of any role.
///
/// [role] is kept as the backend's raw string (`Customer` / `HallOwner` /
/// `Admin`) since that's what the role-change endpoint speaks; use
/// [userRole] when the parsed enum is needed.
class AdminUser {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  UserRole? get userRole => UserRoleX.fromApiRole(role);

  AdminUser copyWith({String? role}) => AdminUser(
    id: id,
    fullName: fullName,
    email: email,
    phoneNumber: phoneNumber,
    role: role ?? this.role,
  );

  /// Tolerates both the login dto's field names (`fullName`,
  /// `phoneNumber`) and the shorter `name`/`phone` variants.
  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as int,
    fullName: (json['fullName'] ?? json['name']) as String? ?? '',
    email: json['email'] as String? ?? '',
    phoneNumber: (json['phoneNumber'] ?? json['phone']) as String?,
    role: json['role'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'role': role,
  };
}
