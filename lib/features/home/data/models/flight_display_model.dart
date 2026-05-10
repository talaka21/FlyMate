import 'package:flutter/material.dart';
import 'package:fly_mate/features/flight_search/data/models/ruselt_flight_search_model.dart';

enum FlightStatus { onTime, delayed, boarding, landed }

class Flight {
  final int id;
  final String airline;
  final String flightNumber;
  final String departure;
  final String arrival;
  final String departureTime;
  final String arrivalTime;
  final FlightStatus status;
  final String logoUrl;
  final Color headerColor;
  final String durLabel;
  final String aircraftType;

  const Flight({
    this.id = 0,
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.logoUrl,
    required this.headerColor,
    this.durLabel = '',
    this.aircraftType = '',
  });

  static const _colorMap = {
    'EK': Color(0xFFCC0000),
    'QR': Color(0xFF5C0A3A),
    'TK': Color(0xFFC0001A),
    'RJ': Color(0xFFB71C1C),
    'RB': Color(0xFF0D3B8C),
    'J9': Color(0xFF0077C8),
    'F3': Color(0xFF5B2D8E),
    'FZ': Color(0xFF185FA5),
    'SV': Color(0xFF006C35),
    'G9': Color(0xFF854F0B),
    'FC': Color(0xFF1B4F72),
  };

  static const _logoMap = {
    'EK': 'https://logo.clearbit.com/emirates.com',
    'QR': 'https://logo.clearbit.com/qatarairways.com',
    'TK': 'https://logo.clearbit.com/turkishairlines.com',
    'RJ': 'https://logo.clearbit.com/rj.com',
    'RB': 'https://logo.clearbit.com/syriaair.com',
    'J9': 'https://logo.clearbit.com/jazeeraairways.com',
    'F3': 'https://logo.clearbit.com/flyadeal.com',
    'FZ': 'https://logo.clearbit.com/flydubai.com',
    'SV': 'https://logo.clearbit.com/saudia.com',
    'G9': 'https://logo.clearbit.com/airarabia.com',
  };

  static FlightStatus _mapStatus(String s) => switch (s.toLowerCase()) {
    'delayed' => FlightStatus.delayed,
    'boarding' => FlightStatus.boarding,
    'landed' || 'arrived' => FlightStatus.landed,
    _ => FlightStatus.onTime,
  };

  factory Flight.fromServerModel(ResultFlightSearchModel m) {
    int durMin =
        (m.arrivalAt.hour * 60 + m.arrivalAt.minute) -
        (m.departureAt.hour * 60 + m.departureAt.minute);
    if (durMin < 0) durMin += 24 * 60;
    final h = durMin ~/ 60;
    final min = durMin % 60;

    final dep =
        '${m.departureAt.hour.toString().padLeft(2, '0')}:${m.departureAt.minute.toString().padLeft(2, '0')}';
    final arr =
        '${m.arrivalAt.hour.toString().padLeft(2, '0')}:${m.arrivalAt.minute.toString().padLeft(2, '0')}';

    return Flight(
      id: m.id,
      airline: m.airlineName,
      flightNumber: '${m.airlineCode} ${m.id}',
      departure: m.origin,
      arrival: m.destination,
      departureTime: dep,
      arrivalTime: arr,
      status: _mapStatus(m.status),
      logoUrl: _logoMap[m.airlineCode] ?? '',
      headerColor: _colorMap[m.airlineCode] ?? const Color(0xFF1B4F72),
      durLabel: '${h}h ${min}m',
      aircraftType: m.aircraftType,
    );
  }
}
