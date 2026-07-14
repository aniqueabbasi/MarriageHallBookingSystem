import 'package:marriage_hall_app/models/user_role.dart';

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final UserRole role;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'role': role.apiRole,
  };
}
