import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userDetailKey = 'user_detail';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // In-memory cache to prevent concurrent read issues on hot restart
  static String? _cachedToken;
  static int? _cachedUserId;
  static String? _cachedUserName;
  static String? _cachedUserDetail;
  static String? _cachedUserRole;
  static String? _cachedUserEmail;

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveSession({
    required String token,
    required int userId,
    required String name,
    required String detail,
    required String role,
    String? email,
  }) async {
    _cachedToken = token;
    _cachedUserId = userId;
    _cachedUserName = name;
    _cachedUserDetail = detail;
    _cachedUserRole = role;
    if (email != null) _cachedUserEmail = email;

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userDetailKey, value: detail);
    await _storage.write(key: _userRoleKey, value: role);
    if (email != null) {
      await _storage.write(key: _userEmailKey, value: email);
    }
  }

  Future<int?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final value = await _storage.read(key: _userIdKey);
    _cachedUserId = value == null ? null : int.tryParse(value);
    return _cachedUserId;
  }

  Future<String?> getUserName() async {
    if (_cachedUserName != null) return _cachedUserName;
    _cachedUserName = await _storage.read(key: _userNameKey);
    return _cachedUserName;
  }

  Future<String?> getUserDetail() async {
    if (_cachedUserDetail != null) return _cachedUserDetail;
    _cachedUserDetail = await _storage.read(key: _userDetailKey);
    return _cachedUserDetail;
  }

  Future<String?> getUserRole() async {
    if (_cachedUserRole != null) return _cachedUserRole;
    _cachedUserRole = await _storage.read(key: _userRoleKey);
    return _cachedUserRole;
  }

  Future<String?> getUserEmail() async {
    if (_cachedUserEmail != null) return _cachedUserEmail;
    _cachedUserEmail = await _storage.read(key: _userEmailKey);
    return _cachedUserEmail;
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUserId = null;
    _cachedUserName = null;
    _cachedUserDetail = null;
    _cachedUserRole = null;
    _cachedUserEmail = null;

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userDetailKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _userEmailKey);
  }
}
