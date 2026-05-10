import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/booking_model.dart';

class BookingRemoteDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  // Token key must match what AuthLocalDataSource uses
  static const _tokenKey = 'auth_token';

  BookingRemoteDataSource({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? DioClient.dio,
      _storage = storage ?? const FlutterSecureStorage();

  Future<BookingResponse> createBooking(BookingRequest request) async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty || token.startsWith('mock_')) {
      throw Exception('Session expired. Please log out and log in again.');
    }

    final response = await _dio.post(
      '/bookings',
      data: request.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingResponse> getMyBookings() async {
    final response = await _dio.get('/bookings');
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
