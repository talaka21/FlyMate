import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:fly_mate/features/booking/data/models/booking_model.dart';
import 'package:fly_mate/features/booking/data/repositories/booking_repository.dart';
import 'package:fly_mate/features/tickets/logic/my_bookings_cubit.dart';
import 'package:fly_mate/features/tickets/logic/my_bookings_state.dart';

class TicketsPage extends StatelessWidget {
  final bool isTab;
  const TicketsPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyBookingsCubit(
        BookingRepositoryImpl(remote: BookingRemoteDataSource()),
      )..load(),
      child: _TicketsView(isTab: isTab),
    );
  }
}

class _TicketsView extends StatelessWidget {
  final bool isTab;
  const _TicketsView({this.isTab = false});

  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
            builder: (context, state) {
              if (state is MyBookingsLoading || state is MyBookingsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MyBookingsError) {
                return _buildError(context, state.message);
              }
              if (state is MyBookingsLoaded) {
                if (state.bookings.isEmpty) return _buildEmpty(context);
                return _buildList(context, state.bookings);
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );

    if (isTab) return content;

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
        child: SafeArea(child: content),
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
          if (!isTab)
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
                  'My Tickets',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          if (!isTab) const SizedBox(height: 20),
          const Text(
            'My Bookings',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'All your confirmed flight reservations',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<BookingData> bookings) {
    return RefreshIndicator(
      onRefresh: () => context.read<MyBookingsCubit>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: bookings.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _TicketCard(booking: bookings[i]),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.airplane_ticket_outlined, size: 44, color: _primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No bookings yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _dark),
          ),
          const SizedBox(height: 8),
          Text(
            'Your confirmed tickets will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 28),
          if (!isTab)
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Search Flights', style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MyBookingsCubit>().load(),
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final BookingData booking;
  const _TicketCard({required this.booking});

  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  @override
  Widget build(BuildContext context) {
    final isConfirmed = booking.status.toLowerCase() == 'confirmed';
    final statusColor = isConfirmed ? const Color(0xFF22C55E) : Colors.grey.shade400;
    final statusLabel = isConfirmed ? 'Confirmed' : booking.status;

    final departure = _parseDateTime(booking.departureAt);
    final arrival = _parseDateTime(booking.arrivalAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Blue header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_dark, _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.airlineName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _routeCol(booking.fromCode, booking.from, departure.time),
                      const Icon(Icons.flight, color: Colors.white, size: 22),
                      _routeCol(booking.toCode, booking.to, arrival.time, right: true),
                    ],
                  ),
                ],
              ),
            ),

            // ── Notch divider ───────────────────────────────────
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  _notch(true),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  _notch(false),
                ],
              ),
            ),

            // ── Details ─────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _detail('DATE', departure.date),
                      _detail('FLIGHT', booking.flightNumber),
                      _detail('SEAT', booking.seatNumber),
                      _detail('CLASS', booking.seatClass),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDDE8F8)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_outlined, size: 13, color: _primary),
                            const SizedBox(width: 4),
                            Text(
                              booking.boardingCode,
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isConfirmed)
                        TextButton(
                          onPressed: () => _showBoardingPass(context),
                          style: TextButton.styleFrom(
                            foregroundColor: _primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: _primary),
                            ),
                          ),
                          child: const Text(
                            'View Pass',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBoardingPass(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BoardingPassSheet(booking: booking),
    );
  }

  Widget _routeCol(String code, String city, String time, {bool right = false}) {
    return Column(
      crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
        ),
        Text(
          city,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _notch(bool left) {
    return Transform.translate(
      offset: Offset(left ? -14 : 14, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFEAF3FF),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9EB3CC),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _dark),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  _ParsedDateTime _parseDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final date = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return _ParsedDateTime(date: date, time: time);
    } catch (_) {
      return _ParsedDateTime(date: raw, time: '');
    }
  }
}

class _ParsedDateTime {
  final String date;
  final String time;
  const _ParsedDateTime({required this.date, required this.time});
}

// ── Boarding Pass Bottom Sheet ────────────────────────────────────────

class _BoardingPassSheet extends StatelessWidget {
  final BookingData booking;
  const _BoardingPassSheet({required this.booking});

  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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

            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_dark, _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'BOARDING PASS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bpCol(booking.fromCode, booking.from),
                      const Icon(Icons.flight, color: Colors.white, size: 24),
                      _bpCol(booking.toCode, booking.to, right: true),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _bpDetail('PASSENGER', booking.passengerName),
                      _bpDetail('FLIGHT', booking.flightNumber),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _bpDetail('SEAT', booking.seatNumber),
                      _bpDetail('GATE', booking.gate),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _bpDetail('CLASS', booking.seatClass),
                      _bpDetail('BOARDING CODE', booking.boardingCode),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QR code area
            _buildQr(),
            const SizedBox(height: 8),
            Text(
              booking.boardingCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _dark,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Show at the boarding gate',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQr() {
    final bytes = booking.qrSvgBytes;
    if (bytes != null) {
      return Image.memory(bytes, width: 130, height: 130);
    }
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE8F8)),
      ),
      child: const Icon(Icons.qr_code_2, size: 80, color: _dark),
    );
  }

  Widget _bpCol(String code, String city, {bool right = false}) {
    return Column(
      crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
        ),
        Text(
          city,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _bpDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9EB3CC),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
