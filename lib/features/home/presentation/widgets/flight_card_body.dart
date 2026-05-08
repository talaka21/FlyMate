import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';
import 'package:fly_mate/features/home/presentation/widgets/route_stop_widget.dart';

class FlightCardBody extends StatelessWidget {
  final Flight flight;

  const FlightCardBody({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Departure stop
          Expanded(
            child: RouteStop(
              time: flight.departureTime,
              label: flight.departure,
              isLeft: true,
            ),
          ),

          // Centre: dotted line + plane icon + duration
          Expanded(
            child: Column(
              children: [
                // Line with plane icon
                Row(
                  children: [
                    // Left dot
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Left line segment
                    Expanded(
                      child: Divider(
                        color: colorScheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                    // Plane icon
                    Icon(
                      Icons.flight_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    // Right line segment
                    Expanded(
                      child: Divider(
                        color: colorScheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                    // Right dot
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Duration label
                Text(
                  _duration(flight.departureTime, flight.arrivalTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // Arrival stop
          Expanded(
            child: RouteStop(
              time: flight.arrivalTime,
              label: flight.arrival,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  String _duration(String dep, String arr) {
    final depParts = dep.split(':');
    final arrParts = arr.split(':');
    if (depParts.length != 2 || arrParts.length != 2) return 'Direct';
    int dur = (int.parse(arrParts[0]) * 60 + int.parse(arrParts[1])) -
        (int.parse(depParts[0]) * 60 + int.parse(depParts[1]));
    if (dur < 0) dur += 24 * 60;
    return 'Direct · ${dur ~/ 60}h ${dur % 60}m';
  }
}
