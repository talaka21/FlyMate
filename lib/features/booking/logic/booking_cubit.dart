import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit({required BookingRepository repository})
    : _repository = repository,
      super(BookingInitial());

  Future<void> createBooking(BookingRequest request) async {
    emit(BookingLoading());
    try {
      final response = await _repository.createBooking(request);
      if (response.data.isNotEmpty) {
        emit(
          BookingSuccess(
            bookings: response.data,
            passengers: request.passengers,
          ),
        );
      } else {
        emit(BookingError(message: 'No booking data returned from server.'));
      }
    } on DioException catch (e) {
      emit(BookingError(message: _parseDioError(e)));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  void reset() => emit(BookingInitial());

  String _parseDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'Session expired. Please sign in again.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      // Laravel 422: { "errors": { "field": ["msg", ...] } }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final messages = errors.entries
              .map((entry) {
                final list = entry.value;
                final msg = list is List && list.isNotEmpty
                    ? list.first.toString()
                    : entry.value.toString();
                return msg;
              })
              .join('\n');
          return messages;
        }
      }
      if (data['message'] is String) return data['message'] as String;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Please check your connection.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code != null && code >= 500)
          return 'Server error. Please try again later.';
        return 'Request failed (HTTP $code).';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
