import 'package:dio/dio.dart';
import 'package:fly_mate/core/networking/dio_client.dart';
import 'package:fly_mate/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.dio;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromApiResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/register/passenger',
        data: {
          'name': fullName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return UserModel.fromApiResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Parses Laravel error responses (422 validation, 401 unauthorized, etc.)
  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      // Laravel 422 validation errors: { "errors": { "email": ["msg"] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstList = errors.values.first;
          if (firstList is List && firstList.isNotEmpty) {
            return firstList.first.toString();
          }
        }
      }
      // General Laravel error: { "message": "..." }
      if (data['message'] is String) return data['message'] as String;
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid credentials. Please try again.';
      case 404:
        return 'Endpoint not found. Please contact support.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
