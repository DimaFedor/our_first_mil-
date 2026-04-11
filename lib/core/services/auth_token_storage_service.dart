import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenBundle {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokenBundle({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}

class AuthTokenStorageService {
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _pendingMagicEmailKey = 'auth_pending_magic_email';

  final FlutterSecureStorage _secureStorage;

  AuthTokenStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveTokenBundle(AuthTokenBundle bundle) async {
    await _secureStorage.write(key: _accessTokenKey, value: bundle.accessToken);
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: bundle.refreshToken,
    );
    await _secureStorage.write(
      key: _expiresAtKey,
      value: bundle.expiresAt.toIso8601String(),
    );
  }

  Future<AuthTokenBundle?> readTokenBundle() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final expiresAtRaw = await _secureStorage.read(key: _expiresAtKey);
    final expiresAt = expiresAtRaw == null
        ? null
        : DateTime.tryParse(expiresAtRaw);

    if (accessToken == null || refreshToken == null || expiresAt == null) {
      return null;
    }

    return AuthTokenBundle(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Future<void> clearTokenBundle() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }

  Future<void> savePendingMagicEmail(String email) async {
    await _secureStorage.write(key: _pendingMagicEmailKey, value: email);
  }

  Future<String?> readPendingMagicEmail() async {
    return _secureStorage.read(key: _pendingMagicEmailKey);
  }

  Future<void> clearPendingMagicEmail() async {
    await _secureStorage.delete(key: _pendingMagicEmailKey);
  }
}
