import '../data/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final List<BookingData> bookings; // one entry per seated passenger (adult + child)
  final List<PassengerInfo> passengers;
  BookingSuccess({required this.bookings, required this.passengers});
}

class BookingError extends BookingState {
  final String message;
  BookingError({required this.message});
}
