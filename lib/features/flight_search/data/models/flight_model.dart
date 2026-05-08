// ignore_for_file: public_member_api_docs, sort_constructors_first
class FlightSearchRequest {
  final String fromCode;
  final String toCode;
  final DateTime date;
  final String flightClass;
  final int adults;
  final int children; // ✅ جديد
  final int infants; // ✅ جديد

  const FlightSearchRequest({
    required this.fromCode,
    required this.toCode,
    required this.date,
    required this.flightClass,
    required this.adults,
    this.children = 0, // ✅
    this.infants = 0, // ✅
  });

  int get totalPassengers => adults + children + infants; // ✅

  FlightSearchRequest copyWith({
    String? fromCode,
    String? toCode,
    DateTime? date,
    String? flightClass,
    int? adults,
    int? children,
    int? infants,
  }) {
    return FlightSearchRequest(
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      date: date ?? this.date,
      flightClass: flightClass ?? this.flightClass,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
    );
  }
}
