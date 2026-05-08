import 'package:fly_mate/features/flight_search/data/models/flight_result_model.dart';

abstract class FlightsState {}

class FlightsInitial extends FlightsState {}

class FlightsLoading extends FlightsState {}

class FlightsLoaded extends FlightsState {
  final List<FlightResult> flights;
  final List<DayPrice> weekPrices;
  FlightsLoaded(this.flights, this.weekPrices);
}

class FlightsError extends FlightsState {
  final String message;
  FlightsError(this.message);
}
