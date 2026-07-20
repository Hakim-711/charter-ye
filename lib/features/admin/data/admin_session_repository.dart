import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AdminSessionRepository {
  Future<String?> loadAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> clear();
}

class SecureStorageAdminSessionRepository implements AdminSessionRepository {
  SecureStorageAdminSessionRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const _accessTokenKey = 'charter_admin_access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> loadAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      final trimmed = token?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return null;
      }
      return trimmed;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token.trim());
    } catch (_) {
      // Ignore storage failures.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (_) {
      // Ignore storage failures.
    }
  }
}
