import 'package:flutter/material.dart';
import 'ruselt_flight_search_model.dart';

class FlightResult {
  final int id;
  final String airline;
  final String code;
  final String logoUrl; // ✅ أضف
  final String dep;
  final String arr;
  final int durMin;
  final String durLabel;
  final String stops;
  final int stopsN;
  final int price;
  final Color logoColor;
  final Color logoBg;
  final int availableSeats;
  final String flightStatus;
  final String fromCode;
  final String toCode;
  final String seatClass;
  final int adultCount;
  final int childCount;
  final int infantCount;

  const FlightResult({
    required this.id,
    required this.airline,
    required this.code,
    required this.logoUrl, // ✅ أضف
    required this.dep,
    required this.arr,
    required this.durMin,
    required this.durLabel,
    required this.stops,
    required this.stopsN,
    required this.price,
    required this.logoColor,
    required this.logoBg,
    required this.availableSeats,
    required this.flightStatus,
    required this.fromCode,
    required this.toCode,
    required this.seatClass,
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
  });

  static FlightResult fromModel(
    ResultFlightSearchModel m,
    int id,
    String flightClass, {
    int adultCount = 1,
    int childCount = 0,
    int infantCount = 0,
  }) {
    final dep =
        '${m.departureAt.hour.toString().padLeft(2, '0')}:${m.departureAt.minute.toString().padLeft(2, '0')}';
    final arr =
        '${m.arrivalAt.hour.toString().padLeft(2, '0')}:${m.arrivalAt.minute.toString().padLeft(2, '0')}';
    // Calculate duration from time-of-day only — avoids wrong date from API
    int durMin =
        (m.arrivalAt.hour * 60 + m.arrivalAt.minute) -
        (m.departureAt.hour * 60 + m.departureAt.minute);
    if (durMin < 0) durMin += 24 * 60; // overnight flight
    final h = durMin ~/ 60;
    final min = durMin % 60;

    // ✅ عرّفهم قبل الـ return
    const logoMap = {
      'FZ': 'https://logo.clearbit.com/flydubai.com',
      'EK': 'https://logo.clearbit.com/emirates.com',
      'G9': 'https://logo.clearbit.com/airarabia.com',
      'SV': 'https://logo.clearbit.com/saudia.com',
      'QR': 'https://logo.clearbit.com/qatarairways.com',
      'TK': 'https://logo.clearbit.com/turkishairlines.com',
    };

    const colorMap = {
      'FZ': (Color(0xFF185FA5), Color(0xFFE6F1FB)), // flydubai — blue
      'EK': (Color(0xFF993C1D), Color(0xFFFAECE7)), // Emirates — dark red
      'G9': (Color(0xFF854F0B), Color(0xFFFAEEDA)), // Air Arabia — brown/orange
      'SV': (Color(0xFF006C35), Color(0xFFE8F5E9)), // Saudia — green
      'QR': (Color(0xFF5D0000), Color(0xFFF9EBEA)), // Qatar Airways — maroon
      'TK': (Color(0xFFC0392B), Color(0xFFFDEDEC)), // Turkish Airlines — red
      'RJ': (Color(0xFF9B2335), Color(0xFFF9EBEA)), // Royal Jordanian — red
      'J9': (Color(0xFF007A9A), Color(0xFFE1F4FB)), // Jazeera Airways — teal
      'RB': (Color(0xFF1A4731), Color(0xFFE8F5E9)), // Syrian Airlines — green
      'F3': (Color(0xFFE55A00), Color(0xFFFFF3E0)), // flyadeal — orange
    };

    final colors =
        colorMap[m.airlineCode] ??
        (const Color(0xFF185FA5), const Color(0xFFE6F1FB));

    return FlightResult(
      id: id,
      airline: m.airlineName,
      code: m.airlineCode,
      logoUrl: logoMap[m.airlineCode] ?? '',
      dep: dep,
      arr: arr,
      durMin: durMin,
      durLabel: '${h}h ${min}m',
      stops: 'Non-stop',
      stopsN: 0,
      price: m.getPriceForClass(flightClass).toInt(),
      // price: m.mockPrice,
      availableSeats: m.seatsForClass(flightClass),
      flightStatus: m.status,
      logoColor: colors.$1,
      logoBg: colors.$2,
      fromCode: m.origin,
      toCode: m.destination,
      seatClass: flightClass,
      adultCount: adultCount,
      childCount: childCount,
      infantCount: infantCount,
    );
  }
}

class DayPrice {
  final String dayLabel;
  final int date;
  final int? price;
  bool selected;

  DayPrice({
    required this.dayLabel,
    required this.date,
    this.price,
    this.selected = false,
  });
}

final List<DayPrice> kWeek = [
  DayPrice(dayLabel: 'Sat', date: 22, price: 390),
  DayPrice(dayLabel: 'Sun', date: 23, price: 310),
  DayPrice(dayLabel: 'Mon', date: 24, price: 480),
  DayPrice(dayLabel: 'Tue', date: 25, price: 480, selected: true),
  DayPrice(dayLabel: 'Wed', date: 26),
  DayPrice(dayLabel: 'Thu', date: 27, price: 420),
  DayPrice(dayLabel: 'Fri', date: 28, price: 550),
];
