import 'package:flutter/material.dart';
import 'package:fly_mate/features/home/data/models/flight_display_model.dart';
import 'package:fly_mate/features/home/presentation/widgets/flight_card_body.dart';
import 'package:fly_mate/features/home/presentation/widgets/flight_card_footer.dart';
import 'package:fly_mate/features/home/presentation/widgets/flight_card_header_widget.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          // ── 1. Coloured header with real airline logo ───────
          FlightCardHeader(flight: flight),

          // ── 2. White route body ─────────────────────────────
          FlightCardBody(flight: flight),

          // ── 3. Surface footer with gate info ───────────────
          FlightCardFooter(flight: flight),
        ],
      ),
    );
  }
}
