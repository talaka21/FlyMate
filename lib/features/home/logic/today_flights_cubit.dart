import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/home/data/data_sources/today_flights_data_source.dart';
import 'today_flights_state.dart';

class TodayFlightsCubit extends Cubit<TodayFlightsState> {
  final TodayFlightsDataSource _dataSource;

  TodayFlightsCubit(this._dataSource) : super(TodayFlightsInitial());

  Future<void> load() async {
    emit(TodayFlightsLoading());
    try {
      final flights = await _dataSource.fetchTodayFlights();
      emit(TodayFlightsLoaded(flights));
    } catch (e) {
      emit(TodayFlightsError(e.toString()));
    }
  }
}
