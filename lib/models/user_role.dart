enum UserRole { client, hallOwner }

extension UserRoleX on UserRole {
  String get label => this == UserRole.client ? 'Client' : 'Hall Owner';

  /// Role value expected by the backend's `/api/auth/register` payload.
  String get apiRole => this == UserRole.client ? 'Customer' : 'Owner';

  /// Reverse of [apiRole] — parses the `role` string the backend returns
  /// (e.g. in the login response's `user` object) back into a [UserRole].
  static UserRole fromApiRole(String value) {
    return value == 'Customer' ? UserRole.client : UserRole.hallOwner;
  }
}
