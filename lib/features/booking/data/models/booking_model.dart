import 'dart:convert';
import 'dart:typed_data';

enum PassengerType { adult, child, infant }

class PassengerInfo {
  final PassengerType type;
  final String name;
  final String passportNumber; // empty string for infants
  final String email; // only lead adult fills this

  const PassengerInfo({
    required this.type,
    required this.name,
    this.passportNumber = '',
    this.email = '',
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    if (passportNumber.isNotEmpty) 'passport_number': passportNumber,
    if (email.isNotEmpty) 'email': email,
  };
}

class BookingRequest {
  final int flightId;
  final int bookingTypeId;
  final String seatClass;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final List<String> seats;
  final List<PassengerInfo> passengers; // all passengers in order

  const BookingRequest({
    required this.flightId,
    required this.bookingTypeId,
    required this.seatClass,
    required this.adultCount,
    required this.passengers,
    this.childCount = 0,
    this.infantCount = 0,
    this.seats = const [],
  });

  PassengerInfo get _lead => passengers.first;

  /// Sends the primary passenger fields the server currently expects,
  /// plus counts and a passengers array for when the server is updated.
  Map<String, dynamic> toJson() => {
    'flight_id': flightId,
    'booking_type_id': bookingTypeId,
    'seat_class': seatClass.toLowerCase(),
    'adult_count': adultCount,
    'child_count': childCount,
    'infant_count': infantCount,
    // auto-generate seat numbers until a seat-picker UI is added
    'seats': List.generate(adultCount + childCount, (i) => i + 1),
    'passengers': adultCount + childCount + infantCount,
    'passenger_name': _lead.name,
    'passport_number': _lead.passportNumber,
    'email': _lead.email,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class BookingResponse {
  final String status;
  final String message;
  final List<BookingData> data;

  const BookingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => BookingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class BookingData {
  final int bookingId;
  final String? reference;
  final String boardingCode;
  final String status;
  final String totalPrice;
  final String airlineName;
  final String passengerName;
  final String flightNumber;
  final String? aircraftType;
  final String departureAt;
  final String arrivalAt;
  final String from;
  final String fromCode;
  final String to;
  final String toCode;
  final String seatNumber;
  final String seatClass;
  final String gate;
  final String qrCodeBase64;

  const BookingData({
    required this.bookingId,
    this.reference,
    required this.boardingCode,
    required this.status,
    required this.totalPrice,
    required this.airlineName,
    required this.passengerName,
    required this.flightNumber,
    this.aircraftType,
    required this.departureAt,
    required this.arrivalAt,
    required this.from,
    required this.fromCode,
    required this.to,
    required this.toCode,
    required this.seatNumber,
    required this.seatClass,
    required this.gate,
    required this.qrCodeBase64,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: json['booking_id'] as int? ?? 0,
      reference: json['reference'] as String?,
      boardingCode: json['boarding_code'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPrice: json['total_price'] as String? ?? '0.00',
      airlineName: json['airline_name'] as String? ?? '',
      passengerName: json['passenger_name'] as String? ?? '',
      flightNumber: json['flight_number'] as String? ?? '',
      aircraftType: json['aircraft_type'] as String?,
      departureAt: json['departure_at'] as String? ?? '',
      arrivalAt: json['arrival_at'] as String? ?? '',
      from: json['from'] as String? ?? '',
      fromCode: json['from_code'] as String? ?? '',
      to: json['to'] as String? ?? '',
      toCode: json['to_code'] as String? ?? '',
      seatNumber: json['seat_number'] as String? ?? '',
      seatClass: json['class'] as String? ?? '',
      gate: json['gate'] as String? ?? 'TBA',
      qrCodeBase64: json['qr_code_base64'] as String? ?? '',
    );
  }

  /// Decodes the SVG QR code from the base64 string.
  /// Use with flutter_svg: SvgPicture.memory(booking.qrSvgBytes!)
  Uint8List? get qrSvgBytes {
    if (qrCodeBase64.isEmpty) return null;
    // Strip "data:image/svg+xml;base64," prefix if present
    final raw = qrCodeBase64.contains(',')
        ? qrCodeBase64.split(',').last
        : qrCodeBase64;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}
