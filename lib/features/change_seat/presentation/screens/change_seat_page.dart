import 'package:flutter/material.dart';

class ChangeSeatPage extends StatefulWidget {
  const ChangeSeatPage({super.key});

  @override
  State<ChangeSeatPage> createState() => _ChangeSeatPageState();
}

class _ChangeSeatPageState extends State<ChangeSeatPage> {
  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  static const _columns = ['A', 'B', 'C', '', 'D', 'E', 'F'];
  static const _rows = 30;

  String? _selected;

  // Occupied seats (demo)
  final _occupied = const {
    '1A',
    '1B',
    '1C',
    '1D',
    '1E',
    '1F',
    '2A',
    '2B',
    '2C',
    '2D',
    '2E',
    '2F',
    '3A',
    '3B',
    '3C',
    '3D',
    '3E',
    '3F',
    '5B',
    '5C',
    '5E',
    '7A',
    '7F',
    '8B',
    '8D',
    '9C',
    '9E',
    '10A',
    '12C',
    '12D',
    '13B',
    '13E',
    '14A',
    '14F',
    '15C',
    '16B',
    '16D',
    '17A',
    '17F',
    '18C',
    '18E',
    '19B',
    '19D',
    '20A',
    '20C',
    '20F',
    '21B',
    '21E',
    '22D',
    '23A',
    '23C',
    '24B',
    '24E',
    '25F',
    '26A',
    '26D',
    '27C',
    '27E',
    '28B',
    '28F',
    '29A',
    '29D',
    '30C',
  };

  // Extra legroom rows
  final _extraLegroom = {4, 11};

  bool get _hasSelection => _selected != null;

  void _confirmSeat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Seat Change',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        content: Text(
          'Change your seat to $_selected?',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seat $_selected confirmed!'),
                  backgroundColor: _primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 12),
              _buildLegend(),
              const SizedBox(height: 8),
              _buildColumnLabels(),
              Expanded(child: _buildSeatMap()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Change Seat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RB 204 · 14 May',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'DAM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.flight, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'DXB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                _hasSelection ? 'Selected: $_selected' : 'Current: 14C',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(
            const Color(0xFFEEF4FF),
            const Color(0xFF1D5BBF),
            'Available',
          ),
          _legendItem(
            const Color(0xFFE8F5E9),
            const Color(0xFF22C55E),
            'Selected',
          ),
          _legendItem(Colors.grey.shade200, Colors.grey.shade400, 'Occupied'),
          _legendItem(
            const Color(0xFFFFF8E1),
            const Color(0xFFF59E0B),
            'Extra Legroom',
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color bg, Color border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildColumnLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const SizedBox(width: 28),
          ..._columns.map(
            (col) => SizedBox(
              width: col.isEmpty ? 16 : 36,
              child: Center(
                child: col.isEmpty
                    ? const SizedBox()
                    : Text(
                        col,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9EB3CC),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      itemCount: _rows,
      itemBuilder: (_, i) {
        final row = i + 1;
        final isExtraLegroom = _extraLegroom.contains(row);
        return Column(
          children: [
            if (isExtraLegroom) ...[
              const SizedBox(height: 4),
              _buildExtraLegroomLabel(),
              const SizedBox(height: 4),
            ],
            _buildSeatRow(row),
          ],
        );
      },
    );
  }

  Widget _buildExtraLegroomLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
        ),
      ),
      child: const Center(
        child: Text(
          'Extra Legroom',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFFF59E0B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatRow(int row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$row',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9EB3CC),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ..._columns.map((col) {
            if (col.isEmpty) return const SizedBox(width: 16);
            final seatId = '$row$col';
            final isOccupied = _occupied.contains(seatId);
            final isSelected = _selected == seatId;
            final isExtraLegroom = _extraLegroom.contains(row);
            return _SeatButton(
              seatId: seatId,
              isOccupied: isOccupied,
              isSelected: isSelected,
              isExtraLegroom: isExtraLegroom,
              onTap: isOccupied
                  ? null
                  : () =>
                        setState(() => _selected = isSelected ? null : seatId),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_hasSelection) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NEW SEAT',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9EB3CC),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    _selected!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _hasSelection ? _confirmSeat : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _hasSelection ? 'Confirm Seat $_selected' : 'Select a seat',
                style: TextStyle(
                  color: _hasSelection ? Colors.white : Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seat Button ───────────────────────────────────────────────────────

class _SeatButton extends StatelessWidget {
  final String seatId;
  final bool isOccupied;
  final bool isSelected;
  final bool isExtraLegroom;
  final VoidCallback? onTap;

  const _SeatButton({
    required this.seatId,
    required this.isOccupied,
    required this.isSelected,
    required this.isExtraLegroom,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;

    if (isSelected) {
      bg = const Color(0xFF22C55E);
      border = const Color(0xFF16A34A);
    } else if (isOccupied) {
      bg = Colors.grey.shade200;
      border = Colors.grey.shade300;
    } else if (isExtraLegroom) {
      bg = const Color(0xFFFFF8E1);
      border = const Color(0xFFF59E0B);
    } else {
      bg = const Color(0xFFEEF4FF);
      border = const Color(0xFF1D5BBF);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 1.2),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : isOccupied
            ? const Icon(Icons.close, color: Colors.grey, size: 12)
            : null,
      ),
    );
  }
}
