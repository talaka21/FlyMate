import 'package:flutter/material.dart';

enum _FlightStatus { onTime, delayed, cancelled, landed }

class FlightStatusPage extends StatefulWidget {
  const FlightStatusPage({super.key});

  @override
  State<FlightStatusPage> createState() => _FlightStatusPageState();
}

class _FlightStatusPageState extends State<FlightStatusPage> {
  final _flightController = TextEditingController();
  bool _searched = false;
  bool _loading = false;

  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  // Demo data
  final _demoFlights = const [
    _FlightInfo(
      flightNumber: 'RB 204',
      airline: 'Syrian Air',
      origin: 'DAM',
      originCity: 'Damascus',
      destination: 'DXB',
      destCity: 'Dubai',
      departureTime: '09:45',
      arrivalTime: '13:25',
      gate: 'B12',
      terminal: '2',
      status: _FlightStatus.onTime,
      progress: 0.62,
    ),
    _FlightInfo(
      flightNumber: 'FZ 881',
      airline: 'flydubai',
      origin: 'DAM',
      originCity: 'Damascus',
      destination: 'IST',
      destCity: 'Istanbul',
      departureTime: '14:10',
      arrivalTime: '16:45',
      gate: 'A5',
      terminal: '1',
      status: _FlightStatus.delayed,
      delayMinutes: 35,
      progress: 0.0,
    ),
  ];

  _FlightInfo? _result;

  @override
  void dispose() {
    _flightController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_flightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a flight number')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final query = _flightController.text.trim().toUpperCase().replaceAll(' ', '');
    _result = _demoFlights.firstWhere(
      (f) => f.flightNumber.replaceAll(' ', '') == query,
      orElse: () => _demoFlights.first,
    );

    setState(() {
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF3FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      if (_searched && _result != null) _buildStatusCard(_result!),
                      if (!_searched) _buildSuggestions(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_dark, _primary, Color(0xFF2979E8)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Flight Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Track your flight',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time updates on departure, arrival & delays',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE8F8)),
              ),
              child: TextField(
                controller: _flightController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. RB 204',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0,
                  ),
                  prefixIcon: const Icon(Icons.flight_rounded, color: _primary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _loading ? null : _search,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(_FlightInfo flight) {
    final statusColor = _statusColor(flight.status);
    final statusLabel = _statusLabel(flight.status, flight.delayMinutes);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcon(flight.status), color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Flight number & airline
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            flight.flightNumber,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          flight.airline,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Route row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildRoutePoint(
                          code: flight.origin,
                          city: flight.originCity,
                          time: flight.departureTime,
                          isLeft: true,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.flight, color: _primary, size: 20),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: flight.progress,
                                  backgroundColor: const Color(0xFFDDE8F8),
                                  color: _primary,
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildRoutePoint(
                          code: flight.destination,
                          city: flight.destCity,
                          time: flight.arrivalTime,
                          isLeft: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEF4FF)),
                    const SizedBox(height: 16),

                    // Details row
                    Row(
                      children: [
                        _buildInfoTile(Icons.meeting_room_outlined, 'Gate', flight.gate),
                        _buildInfoTile(Icons.layers_outlined, 'Terminal', flight.terminal),
                        _buildInfoTile(
                          Icons.access_time_rounded,
                          'Departs',
                          flight.status == _FlightStatus.delayed
                              ? _addDelay(flight.departureTime, flight.delayMinutes ?? 0)
                              : flight.departureTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => setState(() {
            _searched = false;
            _flightController.clear();
          }),
          icon: const Icon(Icons.search, size: 16),
          label: const Text('Search another flight'),
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
      ],
    );
  }

  Widget _buildRoutePoint({
    required String code,
    required String city,
    required String time,
    required bool isLeft,
  }) {
    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            code,
            style: const TextStyle(
              color: _dark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            city,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: _primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9EB3CC),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular flights today',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        const SizedBox(height: 12),
        ..._demoFlights.map((f) => _buildSuggestionTile(f)),
      ],
    );
  }

  Widget _buildSuggestionTile(_FlightInfo flight) {
    final statusColor = _statusColor(flight.status);
    return GestureDetector(
      onTap: () {
        _flightController.text = flight.flightNumber;
        setState(() {
          _result = flight;
          _searched = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                flight.flightNumber,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${flight.originCity} → ${flight.destCity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabel(flight.status, flight.delayMinutes),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(_FlightStatus s) {
    switch (s) {
      case _FlightStatus.onTime:
        return const Color(0xFF22C55E);
      case _FlightStatus.delayed:
        return const Color(0xFFF59E0B);
      case _FlightStatus.cancelled:
        return const Color(0xFFEF4444);
      case _FlightStatus.landed:
        return const Color(0xFF6366F1);
    }
  }

  IconData _statusIcon(_FlightStatus s) {
    switch (s) {
      case _FlightStatus.onTime:
        return Icons.check_circle_rounded;
      case _FlightStatus.delayed:
        return Icons.schedule_rounded;
      case _FlightStatus.cancelled:
        return Icons.cancel_rounded;
      case _FlightStatus.landed:
        return Icons.flight_land_rounded;
    }
  }

  String _statusLabel(_FlightStatus s, int? delay) {
    switch (s) {
      case _FlightStatus.onTime:
        return 'On Time';
      case _FlightStatus.delayed:
        return 'Delayed ${delay != null ? "+${delay}m" : ""}';
      case _FlightStatus.cancelled:
        return 'Cancelled';
      case _FlightStatus.landed:
        return 'Landed';
    }
  }

  String _addDelay(String time, int minutes) {
    final parts = time.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]) + minutes;
    final newH = (h + m ~/ 60) % 24;
    final newM = m % 60;
    return '${newH.toString().padLeft(2, '0')}:${newM.toString().padLeft(2, '0')}';
  }
}

class _FlightInfo {
  final String flightNumber;
  final String airline;
  final String origin;
  final String originCity;
  final String destination;
  final String destCity;
  final String departureTime;
  final String arrivalTime;
  final String gate;
  final String terminal;
  final _FlightStatus status;
  final double progress;
  final int? delayMinutes;

  const _FlightInfo({
    required this.flightNumber,
    required this.airline,
    required this.origin,
    required this.originCity,
    required this.destination,
    required this.destCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.gate,
    required this.terminal,
    required this.status,
    required this.progress,
    this.delayMinutes,
  });
}
