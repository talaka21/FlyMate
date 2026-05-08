import 'package:flutter/material.dart';
import 'package:fly_mate/features/flight_search/presentation/screens/search_results_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/flight_search/data/data_sources/flight_remote_data_source.dart';
import 'package:fly_mate/features/flight_search/data/models/flight_model.dart';
import 'package:fly_mate/features/flight_search/logic/flight_search_cubit.dart';
// ─── Data Models ───────────────────────────────────────────────────

class Airport {
  final String code;
  final String name;
  final String city;
  final String country;

  const Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.country,
  });
}

const List<Airport> kSyrianAirports = [
  Airport(
    code: 'DAM',
    name: 'Damascus International Airport',
    city: 'Damascus',
    country: 'Syria',
  ),
  Airport(
    code: 'ALP',
    name: 'Aleppo International Airport',
    city: 'Aleppo',
    country: 'Syria',
  ),
  Airport(
    code: 'LTK',
    name: 'Bassel Al-Assad International Airport',
    city: 'Latakia',
    country: 'Syria',
  ),
  Airport(
    code: 'DEZ',
    name: 'Deir ez-Zor Airport',
    city: 'Deir ez-Zor',
    country: 'Syria',
  ),
];

const List<Airport> kDestinations = [
  Airport(
    code: 'DXB',
    name: 'Dubai International Airport',
    city: 'Dubai',
    country: 'UAE',
  ),
  Airport(
    code: 'IST',
    name: 'Istanbul Airport',
    city: 'Istanbul',
    country: 'Turkey',
  ),
  Airport(
    code: 'DOH',
    name: 'Hamad International Airport',
    city: 'Doha',
    country: 'Qatar',
  ),
  Airport(
    code: 'CAI',
    name: 'Cairo International Airport',
    city: 'Cairo',
    country: 'Egypt',
  ),
  Airport(
    code: 'BEY',
    name: 'Beirut Rafic Hariri Airport',
    city: 'Beirut',
    country: 'Lebanon',
  ),
  Airport(
    code: 'AMM',
    name: 'Queen Alia International Airport',
    city: 'Amman',
    country: 'Jordan',
  ),
  Airport(
    code: 'RUH',
    name: 'King Khalid International Airport',
    city: 'Riyadh',
    country: 'Saudi Arabia',
  ),
  Airport(
    code: 'JED',
    name: 'King Abdulaziz International Airport',
    city: 'Jeddah',
    country: 'Saudi Arabia',
  ),
  Airport(
    code: 'KWI',
    name: 'Kuwait International Airport',
    city: 'Kuwait City',
    country: 'Kuwait',
  ),
  Airport(
    code: 'BAH',
    name: 'Bahrain International Airport',
    city: 'Manama',
    country: 'Bahrain',
  ),
  Airport(code: 'LHR', name: 'Heathrow Airport', city: 'London', country: 'UK'),
  Airport(
    code: 'CDG',
    name: 'Charles de Gaulle Airport',
    city: 'Paris',
    country: 'France',
  ),
  Airport(
    code: 'FRA',
    name: 'Frankfurt Airport',
    city: 'Frankfurt',
    country: 'Germany',
  ),
];

// ─── Main Widget ───────────────────────────────────────────────────

class HeroCardWidget extends StatefulWidget {
  const HeroCardWidget({super.key});

  @override
  State<HeroCardWidget> createState() => _HeroCardWidgetState();
}

class _HeroCardWidgetState extends State<HeroCardWidget> {
  String selectedTripType = 'One Way';
  String selectedClass = 'Business';

  int adultCount = 1;
  int childCount = 0;
  int infantCount = 0;

  Airport selectedOrigin = kSyrianAirports.first;
  Airport? selectedDestination;

  final List<String> tripTypes = ['One Way', 'Round Trip', 'Multi-City'];
  final List<String> cabinClasses = ['Economy', 'Business', 'First'];

  String get _guestSummary {
    final parts = <String>[];
    if (adultCount > 0)
      parts.add('$adultCount Adult${adultCount > 1 ? 's' : ''}');
    if (childCount > 0)
      parts.add('$childCount Child${childCount > 1 ? 'ren' : ''}');
    if (infantCount > 0)
      parts.add('$infantCount Infant${infantCount > 1 ? 's' : ''}');
    return parts.isEmpty ? '0 Guests' : parts.join(', ');
  }

  // ── Sheets ─────────────────────────────────────────────────────

  void _showTripTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionsSheet(
        title: 'Trip Type',
        options: tripTypes,
        selected: selectedTripType,
        onSelect: (val) => setState(() => selectedTripType = val),
      ),
    );
  }

  void _showClassSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionsSheet(
        title: 'Cabin Class',
        options: cabinClasses,
        selected: selectedClass,
        onSelect: (val) => setState(() => selectedClass = val),
      ),
    );
  }

  void _showGuestsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // ✅ هون الإصلاح — بتحدث الاثنين مع بعض
          void update(VoidCallback fn) {
            fn(); // نفذ التغيير مرة وحدة
            setSheetState(() {}); // حدث الـ sheet
            setState(() {}); // حدث الـ card
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Passengers',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the number of travelers',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),

                _PassengerRow(
                  icon: Icons.person,
                  title: 'Adult',
                  subtitle: '12+ years',
                  count: adultCount,
                  onDecrement: adultCount > 0
                      ? () => update(() => adultCount--)
                      : null,
                  onIncrement: adultCount < 9
                      ? () => update(() => adultCount++)
                      : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                _PassengerRow(
                  icon: Icons.child_care,
                  title: 'Child',
                  subtitle: '2–11 years',
                  count: childCount,
                  onDecrement: childCount > 0
                      ? () => update(() => childCount--)
                      : null,
                  onIncrement: childCount < 9
                      ? () => update(() => childCount++)
                      : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                _PassengerRow(
                  icon: Icons.baby_changing_station,
                  title: 'Infant',
                  subtitle: 'Under 2 years',
                  count: infantCount,
                  onDecrement: infantCount > 0
                      ? () => update(() => infantCount--)
                      : null,
                  onIncrement: infantCount < adultCount
                      ? () => update(() => infantCount++)
                      : null,
                ),

                if (infantCount >= adultCount && adultCount > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Each infant must be accompanied by one adult',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D5BBF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOriginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AirportPickerSheet(
        title: 'Departure Airport',
        airports: kSyrianAirports,
        selected: selectedOrigin,
        onSelect: (airport) => setState(() => selectedOrigin = airport),
      ),
    );
  }

  void _showDestinationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AirportPickerSheet(
        title: 'Where to?',
        airports: kDestinations,
        selected: selectedDestination,
        onSelect: (airport) => setState(() => selectedDestination = airport),
        searchable: true,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Use full available width — no fixed width constraint
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A6E), Color(0xFF1D5BBF), Color(0xFF2979E8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FLY FROM',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Find Your Perfect Flight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flight_takeoff,
                                color: Colors.white,
                                size: 11,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'SYR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Origin / Destination card ────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Origin — full row is tappable
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showOriginSheet,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                              splashColor: Colors.white.withOpacity(0.08),
                              highlightColor: Colors.white.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    _AirportIcon(icon: Icons.flight_takeoff),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'FROM',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.55,
                                              ),
                                              fontSize: 9,
                                              letterSpacing: 0.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            selectedOrigin.city,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${selectedOrigin.code} · ${selectedOrigin.name}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 10,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Divider row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const SizedBox(width: 34),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Destination — full row is tappable
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showDestinationSheet,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                              splashColor: Colors.white.withOpacity(0.08),
                              highlightColor: Colors.white.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    _AirportIcon(icon: Icons.flight_land),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TO',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.55,
                                              ),
                                              fontSize: 9,
                                              letterSpacing: 0.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            selectedDestination?.city ??
                                                'Where to?',
                                            style: TextStyle(
                                              color: selectedDestination != null
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.4,
                                                    ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            selectedDestination != null
                                                ? '${selectedDestination!.code} · ${selectedDestination!.name}'
                                                : 'Tap to select destination',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ),
                                              fontSize: 10,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Options row ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _OptionChip(
                            label: 'Trip',
                            value: selectedTripType,
                            onTap: _showTripTypeSheet,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _OptionChip(
                            label: 'Class',
                            value: selectedClass,
                            onTap: _showClassSheet,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _OptionChip(
                            label: 'Guests',
                            value: _guestSummary,
                            onTap: _showGuestsSheet,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Search button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            // TODO: navigate to search results
                            if (selectedDestination == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a destination'),
                                ),
                              );
                              return;
                            }
                            final searchRequest = FlightSearchRequest(
                              fromCode: selectedOrigin.code,
                              toCode: selectedDestination!.code,
                              date: DateTime.now(),
                              flightClass: selectedClass,
                              adults: adultCount,
                              children: childCount, // ✅
                              infants: infantCount, // ✅
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) =>
                                      FlightsCubit(FlightRemoteDataSource()),
                                  child: SearchResultsPage(
                                    searchRequest: searchRequest,
                                  ),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Search Flights',
                                  style: TextStyle(
                                    color: Color(0xFF1A3A6E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1D5BBF),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Airport Icon Helper ───────────────────────────────────────────

class _AirportIcon extends StatelessWidget {
  final IconData icon;
  const _AirportIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }
}

// ─── Passenger Row ─────────────────────────────────────────────────

class _PassengerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _PassengerRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEEF4FF),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1D5BBF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        _CounterButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 12),
        SizedBox(
          width: 22,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        _CounterButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

// ─── Airport Picker Sheet ──────────────────────────────────────────

class _AirportPickerSheet extends StatefulWidget {
  final String title;
  final List<Airport> airports;
  final Airport? selected;
  final ValueChanged<Airport> onSelect;
  final bool searchable;

  const _AirportPickerSheet({
    required this.title,
    required this.airports,
    required this.selected,
    required this.onSelect,
    this.searchable = false,
  });

  @override
  State<_AirportPickerSheet> createState() => _AirportPickerSheetState();
}

class _AirportPickerSheetState extends State<_AirportPickerSheet> {
  String _query = '';

  List<Airport> get _filtered {
    if (_query.isEmpty) return widget.airports;
    final q = _query.toLowerCase();
    return widget.airports
        .where(
          (a) =>
              a.city.toLowerCase().contains(q) ||
              a.code.toLowerCase().contains(q) ||
              a.country.toLowerCase().contains(q) ||
              a.name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          if (widget.searchable) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search city or airport code…',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final airport = _filtered[i];
                final isSelected = widget.selected?.code == airport.code;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF4FF)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        airport.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF1D5BBF)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    airport.city,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1D5BBF) : null,
                    ),
                  ),
                  subtitle: Text(
                    '${airport.name} · ${airport.country}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF1D5BBF),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    widget.onSelect(airport);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Options Sheet ─────────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(opt, style: const TextStyle(fontSize: 15)),
              trailing: selected == opt
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1D5BBF),
                      size: 20,
                    )
                  : null,
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option Chip ───────────────────────────────────────────────────

class _OptionChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 8,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.6),
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Counter Button ────────────────────────────────────────────────

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? const Color(0xFF1D5BBF) : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? const Color(0xFF1D5BBF) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
