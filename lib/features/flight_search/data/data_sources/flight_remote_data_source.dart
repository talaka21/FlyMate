import 'package:dio/dio.dart';
import 'package:fly_mate/core/networking/dio_client.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/flight_model.dart';
import '../models/ruselt_flight_search_model.dart';

class FlightRemoteDataSource {
  final Dio dio = DioClient.dio;

  // Future<List<ResultFlightSearchModel>> fetchFlights(
  //   FlightSearchRequest req,
  // ) async {
  //   await Future.delayed(const Duration(seconds: 1));

  //   return [
  //     ResultFlightSearchModel(
  //       airlineId: 1,
  //       airlineName: 'Royal Jordanian',
  //       airlineCode: 'RJ',
  //       originAirportId: 1,
  //       destinationAirportId: 2,
  //       origin: 'AMM',
  //       destination: 'DXB',
  //       departureAt: DateTime(2026, 3, 26, 8, 0),
  //       arrivalAt: DateTime(2026, 3, 26, 11, 0),
  //       aircraftType: 'Boeing 787',
  //       totalSeat: 200,
  //       status: 'on_time',
  //       availableSeatsFirst: 5,
  //       availableSeatsBusinesss: 10,
  //       availableSeatsEconomy: 15,
  //       prices: [
  //         FlightPrice(flightClass: 'economy', price: 227),
  //         FlightPrice(flightClass: 'business', price: 577),
  //         FlightPrice(flightClass: 'first_class', price: 791),
  //       ],
  //     ),
  //     ResultFlightSearchModel(
  //       airlineId: 2,
  //       airlineName: 'Emirates',
  //       airlineCode: 'EK',
  //       originAirportId: 1,
  //       destinationAirportId: 2,
  //       origin: 'AMM',
  //       destination: 'DXB',
  //       departureAt: DateTime(2026, 3, 26, 10, 0),
  //       arrivalAt: DateTime(2026, 3, 26, 13, 30),
  //       aircraftType: 'A380',
  //       totalSeat: 300,
  //       status: 'on_time',
  //       availableSeatsFirst: 2,
  //       availableSeatsBusinesss: 5,
  //       availableSeatsEconomy: 20,
  //       prices: [
  //         FlightPrice(flightClass: 'economy', price: 300),
  //         FlightPrice(flightClass: 'business', price: 800),
  //         FlightPrice(flightClass: 'first_class', price: 1200),
  //       ],
  //     ),
  //   ];
  // }
  Future<List<ResultFlightSearchModel>> fetchFlights(
    FlightSearchRequest req,
  ) async {
    print("Full URL: ${dio.options.baseUrl}/flights/search");
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
    final response = await dio.get(
      '/flights/search', // السلاش هون بس، مشان نضمن دمج نظيف مع الـ api
      queryParameters: {
        'origin': req.fromCode,
        'destination': req.toCode,
        'date':
            "${req.date.year}-${req.date.month.toString().padLeft(2, '0')}-${req.date.day.toString().padLeft(2, '0')}",
      },
    );

    if (response.data['data'] != null) {
      final List data = response.data['data'];
      return data.map((e) => ResultFlightSearchModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
