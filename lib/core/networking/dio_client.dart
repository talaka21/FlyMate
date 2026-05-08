import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static late final Dio dio;

  static void init({FlutterSecureStorage? storage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8000/api',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      _AuthInterceptor(storage ?? const FlutterSecureStorage()),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
}

/// Automatically attaches Bearer token from secure storage to every request.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
