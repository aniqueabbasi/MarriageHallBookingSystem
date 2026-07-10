enum UserRole { client, hallOwner }

extension UserRoleX on UserRole {
  String get label => this == UserRole.client ? 'Client' : 'Hall Owner';
}
