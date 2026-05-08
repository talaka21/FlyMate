import '../data_sources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<BookingResponse> createBooking(BookingRequest request);
  Future<BookingResponse> getMyBookings();
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;

  BookingRepositoryImpl({required BookingRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<BookingResponse> createBooking(BookingRequest request) {
    return _remote.createBooking(request);
  }

  @override
  Future<BookingResponse> getMyBookings() {
    return _remote.getMyBookings();
  }
}
