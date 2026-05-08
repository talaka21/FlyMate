import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Airline {
  final String code;
  final String name;
  final String sub;
  final Color bgColor;
  final Color textColor;
  final String logoPath;
  final List<Map<String, String>> stats;
  final List<Map<String, String>> flights;
  final List<String> services;

  const Airline({
    required this.code,
    required this.name,
    required this.sub,
    required this.bgColor,
    required this.textColor,
    required this.stats,
    required this.flights,
    required this.services,
    required this.logoPath,
  });
}

final List<Airline> dummyAirlines = [
  Airline(
    code: 'SY',
    name: 'Syrian Airlines',
    logoPath: 'assets/logos/syrian-airlines.png',
    sub: 'National Carrier · Est. 1946',
    bgColor: const Color(0xFF0D3B8C),
    textColor: const Color(0xFF1A3C8F),
    stats: [
      {'v': '18', 'l': 'Destinations'},
      {'v': '23kg', 'l': 'Baggage'},
      {'v': '3.8★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Cairo', 'd': 'Daily', 'p': '\$90', 't': '1h 40m'},
      {'r': 'Damascus → Moscow', 'd': 'Tue & Fri', 'p': '\$320', 't': '4h 15m'},
      {
        'r': 'Damascus → Abu Dhabi',
        'd': 'Mon & Thu',
        'p': '\$180',
        't': '2h 30m',
      },
    ],
    services: [
      '23kg Baggage',
      'Free Meal',
      'First Class Available',
      'Airport Check-in',
    ],
  ),
  Airline(
    code: 'EK',
    name: 'Emirates',
    logoPath: 'assets/logos/emirates.png',
    sub: 'Dubai · Largest ME Carrier',
    bgColor: const Color(0xFFD71920),
    textColor: const Color(0xFFCC0000),
    stats: [
      {'v': '230+', 'l': 'Destinations'},
      {'v': '35kg', 'l': 'Business Bag'},
      {'v': '4.8★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Dubai', 'd': 'Daily', 'p': '\$210', 't': '2h 45m'},
      {'r': 'Damascus → London via DXB', 'd': 'Daily', 'p': '\$680', 't': '9h'},
      {
        'r': 'Damascus → New York via DXB',
        'd': 'Daily',
        'p': '\$1,100',
        't': '16h',
      },
    ],
    services: [
      '30kg Baggage',
      'ICE Entertainment',
      'Onboard Wi-Fi',
      'Lounge Access',
    ],
  ),
  Airline(
    code: 'RJ',
    name: 'Royal Jordanian',
    logoPath: 'assets/logos/royal-jordanian.png',
    sub: "Amman · Jordan's Official Carrier",
    bgColor: const Color(0xFFE52D2D),
    textColor: const Color(0xFF9B1C1C),
    stats: [
      {'v': '61', 'l': 'Destinations'},
      {'v': '23kg', 'l': 'Baggage'},
      {'v': '4.1★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Amman', 'd': 'Daily', 'p': '\$110', 't': '1h'},
      {
        'r': 'Damascus → Frankfurt via AMM',
        'd': 'Daily',
        'p': '\$580',
        't': '7h',
      },
      {
        'r': 'Damascus → London via AMM',
        'd': 'Daily',
        'p': '\$620',
        't': '8h 30m',
      },
    ],
    services: [
      '23kg Baggage',
      'Royal Plus Program',
      'First Class Available',
      'Onboard Meals',
    ],
  ),
  Airline(
    code: 'TK',
    name: 'Turkish Airlines',
    logoPath: 'assets/logos/turkish-airlines.png',
    sub: 'Istanbul · Star Alliance Member',
    bgColor: const Color(0xFFCD0511),
    textColor: const Color(0xFF1A3060),
    stats: [
      {'v': '340+', 'l': 'Destinations'},
      {'v': '30kg', 'l': 'Baggage'},
      {'v': '4.5★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Istanbul', 'd': 'Daily', 'p': '\$240', 't': '2h'},
      {
        'r': 'Damascus → London via IST',
        'd': 'Daily',
        'p': '\$620',
        't': '8h 30m',
      },
      {
        'r': 'Damascus → New York via IST',
        'd': 'Daily',
        'p': '\$980',
        't': '14h',
      },
    ],
    services: [
      '30kg Baggage',
      'Miles & Smiles',
      'Lounge Access',
      'Wi-Fi Available',
    ],
  ),
  Airline(
    code: 'QR',
    name: 'Qatar Airways',
    logoPath: 'assets/logos/qatar-airways.png',
    sub: 'Doha · World\'s Best Airline',
    bgColor: const Color(0xFF5C0A3A),
    textColor: const Color(0xFF8B1A4A),
    stats: [
      {'v': '170+', 'l': 'Destinations'},
      {'v': '30kg', 'l': 'Baggage'},
      {'v': '4.9★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Doha', 'd': 'Daily', 'p': '\$190', 't': '2h 15m'},
      {'r': 'Damascus → London via DOH', 'd': 'Daily', 'p': '\$650', 't': '9h'},
      {
        'r': 'Damascus → Bangkok via DOH',
        'd': 'Daily',
        'p': '\$720',
        't': '11h',
      },
    ],
    services: [
      '30kg Baggage',
      'Qmiles Program',
      'Oryx Entertainment',
      'Lounge Access',
    ],
  ),
  // Airline(
  //   code: 'QH',
  //   name: 'Qatar Holidays',
  //   logoPath: 'assets/logos/qatar-airways-holidays.png',
  //   sub: 'Doha · Holiday Packages',
  //   bgColor: const Color(0xFFEEF5FF),
  //   textColor: const Color(0xFF1A4A8B),
  //   stats: [
  //     {'v': '50+', 'l': 'Packages'},
  //     {'v': '30kg', 'l': 'Baggage'},
  //     {'v': '4.6★', 'l': 'Rating'},
  //   ],
  //   flights: [
  //     {
  //       'r': 'Damascus → Doha (Holiday)',
  //       'd': 'Daily',
  //       'p': '\$350',
  //       't': '2h 15m',
  //     },
  //     {
  //       'r': 'Damascus → Maldives via DOH',
  //       'd': 'Sat & Wed',
  //       'p': '\$950',
  //       't': '9h',
  //     },
  //   ],
  //   services: [
  //     '30kg Baggage',
  //     'Hotel Included',
  //     'Transfer Service',
  //     'Tour Guide',
  //   ],
  // ),
  Airline(
    code: 'J9',
    name: 'Jazeera Airways',
    logoPath: 'assets/logos/jazeera-airways.png',
    sub: 'Kuwait · Low Cost Carrier',
    bgColor: const Color(0xFF0077C8),
    textColor: const Color(0xFF0F6E3A),
    stats: [
      {'v': '30+', 'l': 'Destinations'},
      {'v': '20kg', 'l': 'Baggage'},
      {'v': '3.9★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Kuwait', 'd': 'Daily', 'p': '\$130', 't': '2h'},
      {
        'r': 'Damascus → Dubai via KWI',
        'd': 'Mon & Thu',
        'p': '\$280',
        't': '4h',
      },
    ],
    services: [
      '20kg Baggage',
      'JazeераPlus Program',
      'Onboard Snacks',
      'Online Check-in',
    ],
  ),
  Airline(
    code: 'F3',
    name: 'Flyadeal',
    logoPath: 'assets/logos/flyadeal.png',
    sub: 'Jeddah · Saudi Low Cost',
    bgColor: const Color(0xFF5B2D8E),
    textColor: const Color(0xFFD45A00),
    stats: [
      {'v': '25+', 'l': 'Destinations'},
      {'v': '23kg', 'l': 'Baggage'},
      {'v': '3.7★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Jeddah', 'd': 'Daily', 'p': '\$160', 't': '2h 15m'},
      {'r': 'Damascus → Riyadh', 'd': 'Daily', 'p': '\$170', 't': '2h 30m'},
    ],
    services: [
      '23kg Baggage',
      'Budget Friendly',
      'Online Check-in',
      'Onboard Purchase',
    ],
  ),
  Airline(
    code: 'FC',
    name: 'FlyCham',
    logoPath: 'assets/logos/flyCham.png',
    sub: 'Damascus · Syrian Private',
    bgColor: const Color(0xFF1B4F72),
    textColor: const Color(0xFF0A7A50),
    stats: [
      {'v': '12', 'l': 'Destinations'},
      {'v': '20kg', 'l': 'Baggage'},
      {'v': '3.5★', 'l': 'Rating'},
    ],
    flights: [
      {'r': 'Damascus → Cairo', 'd': 'Tue & Sat', 'p': '\$110', 't': '1h 40m'},
      {'r': 'Damascus → Beirut', 'd': 'Daily', 'p': '\$70', 't': '45m'},
    ],
    services: ['20kg Baggage', 'Onboard Meals', 'Airport Check-in'],
  ),
];

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────

class AirlineScreen extends StatelessWidget {
  const AirlineScreen({super.key});

  static const _primaryBlue = Color(0xFF1A3C8F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SizedBox(
        height: 300,
        child: Column(
          children: [
            _buildTopCard(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildAirlinesSection(context),
                    // const SizedBox(height: 20),
                    // _buildPopularDestinations(),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context) {
    return Container(
      color: _primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FLY FROM DAMASCUS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Icon(Icons.menu, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _searchField(
                  icon: Icons.flight_takeoff,
                  label: 'FROM',
                  value: 'Damascus · DAM',
                  filled: true,
                ),
                const SizedBox(height: 8),
                _searchField(
                  icon: Icons.flight_land,
                  label: 'TO',
                  value: 'Where to?',
                  filled: false,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _optChip('TRIP', 'One Way'),
                    const SizedBox(width: 8),
                    _optChip('CLASS', 'Business'),
                    const SizedBox(width: 8),
                    _optChip('GUESTS', '1 Adult'),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Search Flights →',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField({
    required IconData icon,
    required String label,
    required String value,
    required bool filled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFF5F7FF) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: filled ? _primaryBlue : Colors.grey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: filled ? FontWeight.w500 : FontWeight.w400,
                  color: filled ? const Color(0xFF1A1A2E) : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDDE2F5), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirlinesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Airlines at Damascus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF1A3C8F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dummyAirlines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final airline = dummyAirlines[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AirlineProfileScreen(airline: airline),
                    ),
                  );
                },
                child: Container(
                  width: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.08),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: airline.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            airline.code,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: airline.textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        airline.code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        airline.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// AIRLINE PROFILE SCREEN
// ─────────────────────────────────────────────

class AirlineProfileScreen extends StatelessWidget {
  final Airline airline;
  const AirlineProfileScreen({super.key, required this.airline});

  // static const _primaryBlue = Color(0xFF1A3C8F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _buildHeader(context, airline.bgColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Flights from Damascus',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...airline.flights.map(_buildFlightCard),
                  const SizedBox(height: 14),
                  _buildServices(),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: airline.bgColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Book with this airline →',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color headerBackgroundColor) {
    return Container(
      color: headerBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 14,
                ),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: airline.name == "Syrian Airlines"
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Image.asset(airline.logoPath)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airline.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      airline.sub,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: airline.stats.asMap().entries.map((entry) {
        final i = entry.key;
        final stat = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: i < airline.stats.length - 1 ? 10 : 0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: airline.bgColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  stat['v']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['l']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlightCard(Map<String, String> flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight['r']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  flight['d']!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                flight['p']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3C8F),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                flight['t']!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: airline.services.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            // لون رمادي باهت جداً يعطي إيحاء بالنظافة ولا يتضارب مع أي لون شركة
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12), // زوايا أكثر نعومة
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // دالة بسيطة لترجيع أيقونة بناءً على النص
              _getServiceIcon(s),
              const SizedBox(width: 6),
              Text(
                s,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900], // نص غامق وواضح
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _getServiceIcon(String service) {
    IconData iconData;
    if (service.contains('Baggage'))
      iconData = Icons.luggage_outlined;
    else if (service.contains('Meal'))
      iconData = Icons.restaurant_outlined;
    else if (service.contains('Wi-Fi'))
      iconData = Icons.wifi;
    else if (service.contains('Lounge'))
      iconData = Icons.chair_outlined;
    else
      iconData = Icons.check_circle_outline; // أيقونة افتراضية

    return Icon(iconData, size: 20, color: airline.bgColor);
  }
}

class AirlinesList extends StatelessWidget {
  final List<dynamic> airlines;

  const AirlinesList({super.key, required this.airlines});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: airlines.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return AirlineCard(airline: airlines[index]);
        },
      ),
    );
  }
}

class AirlineCard extends StatelessWidget {
  final dynamic airline;

  const AirlineCard({super.key, required this.airline});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AirlineProfileScreen(airline: airline),
          ),
        );
      },
      child: Container(
        width: 130, // تثبيت العرض لكل الحالات
        height: 180, // تثبيت الطول لكل الحالات
        decoration: BoxDecoration(
          color: airline.bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: airline.name == 'Syrian Airlines'
            ? Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    height: 90,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(airline.logoPath, fit: BoxFit.contain),
                    ),
                  ),
                  // النص
                  Positioned(
                    bottom: 35,
                    left: 0,
                    right: 0,
                    child: Text(
                      airline.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                // الحالة العادية لباقي الشركات
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(airline.logoPath, fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Text(
                      airline.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
