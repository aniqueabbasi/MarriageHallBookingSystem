/// `UserDto` as returned by `GET /api/users/me` — the logged-in user's
/// own profile, whatever their role.
class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? city;
  final String role;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int,
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String?,
    city: json['city'] as String?,
    role: json['role'] as String? ?? '',
  );
}

/// Body for `PUT /api/users/me`. Role and password can't be changed here
/// by design.
class UpdateProfileRequest {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? city;

  const UpdateProfileRequest({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.city,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'city': city,
  };
}
