class ResultFlightSearchModel {
  final int id;
  final int airlineId;
  final int originAirportId;
  final int destinationAirportId;
  final DateTime departureAt;
  final DateTime arrivalAt;
  final String aircraftType;
  final int totalSeat;
  final String status;
  final int availableSeatsFirst;
  final int availableSeatsBusinesss;
  final int availableSeatsEconomy;
  final String airlineName; // mock مؤقت
  final String airlineCode; // mock مؤقت
  // final int mockPrice; // mock مؤقت ← جديد
  final List<FlightPrice> prices;
  final String origin;
  final String destination;

  ResultFlightSearchModel({
    required this.id,
    required this.airlineId,
    required this.originAirportId,
    required this.destinationAirportId,
    required this.departureAt,
    required this.arrivalAt,
    required this.aircraftType,
    required this.totalSeat,
    required this.status,
    required this.availableSeatsFirst,
    required this.availableSeatsBusinesss,
    required this.availableSeatsEconomy,
    required this.airlineName,
    required this.airlineCode,
    required this.prices,
    required this.origin,
    required this.destination,
    // required this.mockPrice,
  });

  bool isClassAvailable(String flightClass) {
    switch (flightClass.toLowerCase()) {
      case 'first':
        return availableSeatsFirst > 0;
      case 'business':
        return availableSeatsBusinesss > 0;
      case 'economy':
        return availableSeatsEconomy > 0;
      default:
        return false;
    }
  }

  int seatsForClass(String flightClass) {
    switch (flightClass.toLowerCase()) {
      case 'first':
        return availableSeatsFirst;
      case 'business':
        return availableSeatsBusinesss;
      case 'economy':
        return availableSeatsEconomy;
      default:
        return 0;
    }
  }

  factory ResultFlightSearchModel.fromJson(Map<String, dynamic> json) {
    return ResultFlightSearchModel(
      id: json['id'] ?? 0,
      airlineId: json['airlineId'] ?? 0, // السيرفر باعت airlineId مو airline_id
      originAirportId: json['originAirportId'] ?? 0,
      destinationAirportId: json['destinationAirportId'] ?? 0,
      departureAt: DateTime.parse(
        json['departureAt'],
      ), // السيرفر باعت departureAt مو departure_at
      arrivalAt: DateTime.parse(json['arrivalAt']),
      aircraftType: json['aircraftType'] ?? '',
      totalSeat: json['totalSeat'] ?? 0,
      status: json['status'] ?? '',
      availableSeatsFirst: json['availableSeatsFirst'] ?? 0,
      availableSeatsBusinesss:
          json['availableSeatsBusiness'] ??
          0, // تأكد من الـ s الزيادة باسم المتغير عندك
      availableSeatsEconomy:
          json['availableSeatsEconomy'] ??
          0, // السيرفر ما باعت economy بالصورة بس احتياطاً خليها
      airlineName:
          json['airlineName'] ?? 'Jordanian', // السيرفر باعت airlineName
      airlineCode: json['airlineCode'] ?? 'RJ',
      prices: (json['prices'] as List? ?? [])
          .map((e) => FlightPrice.fromJson(e))
          .toList(),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
    );
  }
  double getPriceForClass(String flightClass) {
    try {
      return prices
          .firstWhere((p) => p.flightClass == flightClass.toLowerCase())
          .price;
    } catch (_) {
      return 0;
    }
  }
}

class FlightPrice {
  final String flightClass;
  final double price;

  FlightPrice({required this.flightClass, required this.price});

  factory FlightPrice.fromJson(Map<String, dynamic> json) {
    return FlightPrice(
      flightClass: json['class'],
      price: double.parse(json['base_price']),
    );
  }
}
