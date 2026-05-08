import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';
import 'package:fly_mate/features/home/presentation/widgets/status_badge_widget.dart';

class FlightCardHeader extends StatelessWidget {
  final Flight flight;

  const FlightCardHeader({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: flight.headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // ── Real airline logo in a frosted white box ────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              // color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            // padding: const EdgeInsets.all(6),
            child: flight.logoUrl.isNotEmpty
                ? Image.network(
                    flight.logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        flight.flightNumber.split(' ').first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      flight.flightNumber.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // Airline name + flight number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight.airline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  flight.flightNumber,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          StatusBadge(status: flight.status),
        ],
      ),
    );
  }
}
