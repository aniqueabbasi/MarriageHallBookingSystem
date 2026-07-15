class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';

  /// Persisted alongside the token purely so a restored session (app
  /// restart) knows which shell to route into — the backend no longer
  /// returns enough for us to reconstruct this any other way, since only
  /// the token survives a restart.
  static const String userRole = 'user_role';
}
