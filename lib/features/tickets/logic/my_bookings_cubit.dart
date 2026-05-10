import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/booking/data/repositories/booking_repository.dart';
import 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final BookingRepository _repository;

  MyBookingsCubit(this._repository) : super(MyBookingsInitial());

  Future<void> load() async {
    emit(MyBookingsLoading());
    try {
      final response = await _repository.getMyBookings();
      emit(MyBookingsLoaded(response.data));
    } on DioException catch (e) {
      emit(MyBookingsError(_parseDio(e)));
    } catch (e) {
      emit(MyBookingsError(e.toString()));
    }
  }

  String _parseDio(DioException e) {
    if (e.response?.statusCode == 401)
      return 'Session expired. Please sign in again.';
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
