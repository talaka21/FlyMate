import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';

class FlightCardFooter extends StatelessWidget {
  final Flight flight;

  const FlightCardFooter({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (String gateOnly, String timeInfo) = _footerData(flight);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 13,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              timeInfo,
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          Icon(
            Icons.door_sliding_outlined,
            size: 13,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            gateOnly,
            style: TextStyle(
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _footerData(Flight f) {
    final aircraft =
        f.aircraftType.isNotEmpty ? f.aircraftType : f.flightNumber;
    final timeInfo = switch (f.status) {
      FlightStatus.boarding => 'Boarding now',
      FlightStatus.delayed => 'Delayed · Departs ${f.departureTime}',
      FlightStatus.landed => 'Arrived on schedule',
      FlightStatus.onTime => 'On time · Departs ${f.departureTime}',
    };
    return (aircraft, timeInfo);
  }
}
