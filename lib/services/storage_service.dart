import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:marriage_hall_app/constants/storage_keys.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

/// Encrypted local storage (Keychain on iOS, Keystore-backed
/// EncryptedSharedPreferences on Android) — used for values that must
/// survive app restarts but shouldn't sit in plaintext, e.g. auth tokens.
class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String accessToken) =>
      _storage.write(key: StorageKeys.accessToken, value: accessToken);

  Future<String?> getToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> saveUserRole(String apiRole) =>
      _storage.write(key: StorageKeys.userRole, value: apiRole);

  Future<String?> getUserRole() => _storage.read(key: StorageKeys.userRole);

  /// Clears the whole persisted session (token + role) — there's no case
  /// where one should survive without the other.
  Future<void> clearToken() => Future.wait([
    _storage.delete(key: StorageKeys.accessToken),
    _storage.delete(key: StorageKeys.userRole),
  ]);
}
