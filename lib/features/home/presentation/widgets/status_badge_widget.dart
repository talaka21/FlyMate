import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';

class StatusBadge extends StatelessWidget {
  final FlightStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color dotColor, String label) = switch (status) {
      FlightStatus.onTime => (const Color(0xFF7EE8A2), 'On Time'),
      FlightStatus.delayed => (const Color(0xFFF09595), 'Delayed'),
      FlightStatus.boarding => (const Color(0xFFFAC775), 'Boarding'),
      FlightStatus.landed => (const Color(0xFFB4B2A9), 'Landed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}