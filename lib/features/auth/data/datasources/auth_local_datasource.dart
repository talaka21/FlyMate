import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fly_mate/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _userKey = 'auth_user';
  static const _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    await _storage.write(key: _tokenKey, value: user.token);
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }
}
