import 'package:flutter/material.dart';
import '../../data/models/flight_result_model.dart';
import '../../../booking/presentation/pages/booking_page.dart';

class FlightCardWidget extends StatelessWidget {
  final FlightResult flight;
  final bool showBest;

  const FlightCardWidget({
    super.key,
    required this.flight,
    this.showBest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      // padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showBest ? const Color(0xFF2E7D32) : const Color(0xFFEEEEEE),
          width: showBest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Airline brand color bar
              Container(width: 5, color: flight.logoColor),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: logo + airline name + status + price ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo badge
                          _AirlineLogo(
                            code: flight.code,
                            brandColor: flight.logoColor,
                            bgColor: flight.logoBg,
                          ),
                          const SizedBox(width: 8),
                          // Airline name + status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        flight.airline,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (showBest) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          '★ Best Value',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _StatusChip(status: flight.flightStatus),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${flight.price}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: flight.logoColor,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'per person',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF2F2F2),
                      ),
                      const SizedBox(height: 8),

                      // ── Flight route ──
                      Row(
                        children: [
                          _TimeBlock(
                            time: flight.dep,
                            airport: flight.fromCode,
                          ),
                          Expanded(
                            child: _FlightLine(
                              duration: flight.durLabel,
                              stops: flight.stops,
                              isDirect: flight.stopsN == 0,
                              color: flight.logoColor,
                            ),
                          ),
                          _TimeBlock(time: flight.arr, airport: flight.toCode),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ── Bottom row: seats + book button ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SeatsIndicator(
                            seats: flight.availableSeats,
                            color: flight.logoColor,
                          ),
                          _BookButton(
                            onTap: () => BookingPage.open(context, flight),
                            color: flight.logoColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Airline flight status chip ──────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  ({Color text, Color bg}) get _colors {
    switch (status.toLowerCase()) {
      case 'on time':
        return (text: const Color(0xFF2E7D32), bg: const Color(0xFFE8F5E9));
      case 'delayed':
        return (text: const Color(0xFFBF360C), bg: const Color(0xFFFFF3E0));
      case 'cancelled':
        return (text: const Color(0xFFC62828), bg: const Color(0xFFFFEBEE));
      default:
        return (text: const Color(0xFF1565C0), bg: const Color(0xFFE3F2FD));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c.text,
        ),
      ),
    );
  }
}

// ── Departure / Arrival time block ──────────────────────────────────────────
class _TimeBlock extends StatelessWidget {
  final String time, airport;
  const _TimeBlock({required this.time, required this.airport});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        time,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A2E),
          height: 1,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        airport,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
          letterSpacing: 0.8,
        ),
      ),
    ],
  );
}

// ── Flight line with plane icon ──────────────────────────────────────────────
class _FlightLine extends StatelessWidget {
  final String duration, stops;
  final bool isDirect;
  final Color color;

  const _FlightLine({
    required this.duration,
    required this.stops,
    required this.isDirect,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      children: [
        Text(
          duration,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(height: 1.5, color: const Color(0xFFDDDDDD)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.flight, size: 16, color: color),
            ),
            Expanded(
              child: Container(height: 1.5, color: const Color(0xFFDDDDDD)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: isDirect ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            stops,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDirect
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFBF360C),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Available seats indicator ────────────────────────────────────────────────
class _SeatsIndicator extends StatelessWidget {
  final int seats;
  final Color color;
  const _SeatsIndicator({required this.seats, required this.color});

  @override
  Widget build(BuildContext context) {
    final isLow = seats <= 5;
    return Row(
      children: [
        Icon(
          Icons.event_seat_rounded,
          size: 13,
          color: isLow ? const Color(0xFFBF360C) : const Color(0xFFAAAAAA),
        ),
        const SizedBox(width: 4),
        Text(
          isLow ? 'Only $seats seats left!' : '$seats seats available',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isLow ? FontWeight.w700 : FontWeight.bold,
            color: isLow ? const Color(0xFFBF360C) : const Color(0xFFAAAAAA),
          ),
        ),
      ],
    );
  }
}

// ── Airline logo (asset image or code fallback) ──────────────────────────────
class _AirlineLogo extends StatelessWidget {
  final String code;
  final Color brandColor;
  final Color bgColor;

  const _AirlineLogo({
    required this.code,
    required this.brandColor,
    required this.bgColor,
  });

  static const _logoAssets = {
    'EK': 'assets/logos/emirates.png',
    'QR': 'assets/logos/qatar-airways.png',
    'TK': 'assets/logos/turkish-airlines.png',
    'RJ': 'assets/logos/royal-jordanian.png',
    'J9': 'assets/logos/jazeera-airways.png',
    'RB': 'assets/logos/syrian-airlines.png',
    'F3': 'assets/logos/flyadeal.png',
  };

  @override
  Widget build(BuildContext context) {
    final assetPath = _logoAssets[code];

    if (assetPath != null) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: brandColor.withValues(alpha: 0.15)),
        ),
        // padding: const EdgeInsets.all(3),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _codeFallback(),
        ),
      );
    }

    return _codeFallback();
  }

  Widget _codeFallback() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: brandColor,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: Text(
      code,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ── Book Now button ───────────────────────────────────────────────────────────
class _BookButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const _BookButton({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Book Now',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
        ],
      ),
    ),
  );
}
