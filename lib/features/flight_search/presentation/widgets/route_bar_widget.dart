import 'package:flutter/material.dart';
import '../../data/models/flight_model.dart';

class RouteBarWidget extends StatelessWidget {
  final String fromCode, toCode;
  final int count;
  final FlightSearchRequest searchRequest;

  const RouteBarWidget({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.count,
    required this.searchRequest,
  });

  @override
  Widget build(BuildContext context) {
    final totalPassengers = searchRequest.totalPassengers;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$fromCode → $toCode',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InfoChip(
                      icon: Icons.person_outline,
                      label:
                          '$totalPassengers Passenger${totalPassengers > 1 ? 's' : ''}',
                    ),
                    const SizedBox(width: 6),
                    InfoChip(
                      icon: Icons.airline_seat_recline_normal_outlined,
                      label: searchRequest.flightClass,
                    ),
                    const SizedBox(width: 6),
                    InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label:
                          '${searchRequest.date.day}/${searchRequest.date.month}/${searchRequest.date.year}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count flights',
              style: const TextStyle(fontSize: 11, color: Color(0xFF0C447C)),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF888888)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}
