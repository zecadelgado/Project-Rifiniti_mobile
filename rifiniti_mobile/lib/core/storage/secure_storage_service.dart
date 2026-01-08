import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for SecureStorageService.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Service for secure storage of sensitive data like tokens.
class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================

  /// Save authentication token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Delete authentication token.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if token exists.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Delete refresh token.
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // ============================================================
  // USER DATA
  // ============================================================

  /// Save user data after login.
  Future<void> saveUserData({
    required int userId,
    required String email,
    required String name,
    String? role,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId.toString()),
      _storage.write(key: _userEmailKey, value: email),
      _storage.write(key: _userNameKey, value: name),
      if (role != null) _storage.write(key: _userRoleKey, value: role),
    ]);
  }

  /// Get user ID.
  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  /// Get user email.
  Future<String?> getUserEmail() async {
    return _storage.read(key: _userEmailKey);
  }

  /// Get user name.
  Future<String?> getUserName() async {
    return _storage.read(key: _userNameKey);
  }

  /// Get user role.
  Future<String?> getUserRole() async {
    return _storage.read(key: _userRoleKey);
  }

  /// Delete all user data.
  Future<void> deleteUserData() async {
    await Future.wait([
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userRoleKey),
    ]);
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  /// Clear all secure storage data.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear authentication data (tokens + user data).
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteUserData(),
    ]);
  }
}
