enum UserRole { client, hallOwner, admin }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.client => 'Client',
    UserRole.hallOwner => 'Hall Owner',
    UserRole.admin => 'Admin',
  };

  /// Role value expected by the backend (`/api/auth/register`,
  /// `/api/admin/users/{id}/role`).
  String get apiRole => switch (this) {
    UserRole.client => 'Customer',
    UserRole.hallOwner => 'HallOwner',
    UserRole.admin => 'Admin',
  };

  /// Reverse of [apiRole] — parses the `role` string the backend returns.
  /// Returns null for unknown values; deliberately no fallback, since
  /// mis-mapping a role routes the user to the wrong dashboard where every
  /// API call 403s.
  static UserRole? fromApiRole(String value) => switch (value) {
    'Customer' => UserRole.client,
    'HallOwner' => UserRole.hallOwner,
    'Admin' => UserRole.admin,
    _ => null,
  };
}
