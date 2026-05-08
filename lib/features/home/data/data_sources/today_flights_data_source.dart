import 'package:dio/dio.dart';
import 'package:fly_mate/core/networking/dio_client.dart';
import 'package:fly_mate/features/flight_search/data/models/ruselt_flight_search_model.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';

class TodayFlightsDataSource {
  final Dio _dio = DioClient.dio;

  Future<List<Flight>> fetchTodayFlights() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _dio.get(
      '/flights/search',
      queryParameters: {'date': dateStr},
    );

    if (response.data['data'] != null) {
      final List data = response.data['data'];
      return data
          .map((e) => Flight.fromServerModel(ResultFlightSearchModel.fromJson(e)))
          .toList();
    }
    return [];
  }
}
