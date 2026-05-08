import 'package:fly_mate/features/home/data/models/flight_display_model.dart';

abstract class TodayFlightsState {}

class TodayFlightsInitial extends TodayFlightsState {}

class TodayFlightsLoading extends TodayFlightsState {}

class TodayFlightsLoaded extends TodayFlightsState {
  final List<Flight> flights;
  TodayFlightsLoaded(this.flights);
}

class TodayFlightsError extends TodayFlightsState {
  final String message;
  TodayFlightsError(this.message);
}
