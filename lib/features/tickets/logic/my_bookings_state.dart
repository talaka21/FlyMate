import 'package:fly_mate/features/booking/data/models/booking_model.dart';

abstract class MyBookingsState {}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsLoaded extends MyBookingsState {
  final List<BookingData> bookings;
  MyBookingsLoaded(this.bookings);
}

class MyBookingsError extends MyBookingsState {
  final String message;
  MyBookingsError(this.message);
}
