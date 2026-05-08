import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/routing/app_routes.dart';

import '../../data/data_sources/booking_remote_data_source.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../logic/booking_cubit.dart';
import '../../logic/booking_state.dart';
import '../../../flight_search/data/models/flight_result_model.dart';

class BookingPage extends StatelessWidget {
  final FlightResult flight;

  const BookingPage._({required this.flight});

  /// Call this from anywhere to open the booking flow.
  static void open(BuildContext context, FlightResult flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BookingCubit(
            repository: BookingRepositoryImpl(
              remote: BookingRemoteDataSource(),
            ),
          ),
          child: BookingPage._(flight: flight),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          if (state.message.contains('Session expired')) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Session Expired'),
                content: const Text(
                  'Your session has expired. Please sign in again to continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      GoRouter.of(context).go(AppRoutes.login);
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFC62828),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is BookingSuccess) {
          return _PaymentScreen(
            bookings: state.bookings,
            passengers: state.passengers,
            flight: flight,
          );
        }
        return _BookingFormScreen(
          flight: flight,
          isLoading: state is BookingLoading,
        );
      },
    );
  }
}

// ─── Per-passenger controller ─────────────────────────────────────────────────

class _PassengerCtrl {
  final PassengerType type;
  final bool isLead;
  final TextEditingController name = TextEditingController();
  final TextEditingController passport = TextEditingController();
  final TextEditingController email = TextEditingController();

  _PassengerCtrl({required this.type, this.isLead = false});

  void dispose() {
    name.dispose();
    passport.dispose();
    email.dispose();
  }

  PassengerInfo toInfo() => PassengerInfo(
    type: type,
    name: name.text.trim(),
    passportNumber: type != PassengerType.infant ? passport.text.trim() : '',
    email: isLead ? email.text.trim() : '',
  );
}

// ─── Booking Form ─────────────────────────────────────────────────────────────

class _BookingFormScreen extends StatefulWidget {
  final FlightResult flight;
  final bool isLoading;

  const _BookingFormScreen({required this.flight, required this.isLoading});

  @override
  State<_BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<_BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<_PassengerCtrl> _ctrls;

  @override
  void initState() {
    super.initState();
    final f = widget.flight;
    _ctrls = [
      // Adults — first one is lead (has email field)
      for (int i = 0; i < f.adultCount; i++)
        _PassengerCtrl(type: PassengerType.adult, isLead: i == 0),
      // Children
      for (int i = 0; i < f.childCount; i++)
        _PassengerCtrl(type: PassengerType.child),
      // Infants
      for (int i = 0; i < f.infantCount; i++)
        _PassengerCtrl(type: PassengerType.infant),
    ];
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final flight = widget.flight;
    context.read<BookingCubit>().createBooking(
      BookingRequest(
        flightId: flight.id,
        bookingTypeId: 1,
        seatClass: flight.seatClass,
        adultCount: flight.adultCount,
        childCount: flight.childCount,
        infantCount: flight.infantCount,
        passengers: _ctrls.map((c) => c.toInfo()).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Confirm Your Flight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FlightSummaryCard(flight: flight),
              const SizedBox(height: 20),
              // ── Adults ──
              if (flight.adultCount > 0) ...[
                _PassengerSectionHeader(
                  icon: Icons.person_rounded,
                  label: 'Adults',
                  count: flight.adultCount,
                  color: flight.logoColor,
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < flight.adultCount; i++) ...[
                  _PassengerFormCard(
                    ctrl: _ctrls[i],
                    index: i + 1,
                    brandColor: flight.logoColor,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              // ── Children ──
              if (flight.childCount > 0) ...[
                const SizedBox(height: 6),
                _PassengerSectionHeader(
                  icon: Icons.child_care_rounded,
                  label: 'Children',
                  count: flight.childCount,
                  color: const Color(0xFF0277BD),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < flight.childCount; i++) ...[
                  _PassengerFormCard(
                    ctrl: _ctrls[flight.adultCount + i],
                    index: i + 1,
                    brandColor: const Color(0xFF0277BD),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              // ── Infants ──
              if (flight.infantCount > 0) ...[
                const SizedBox(height: 6),
                _PassengerSectionHeader(
                  icon: Icons.baby_changing_station_rounded,
                  label: 'Infants',
                  count: flight.infantCount,
                  color: const Color(0xFF6A1B9A),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < flight.infantCount; i++) ...[
                  _PassengerFormCard(
                    ctrl: _ctrls[flight.adultCount + flight.childCount + i],
                    index: i + 1,
                    brandColor: const Color(0xFF6A1B9A),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ConfirmButton(
        isLoading: widget.isLoading,
        color: flight.logoColor,
        onTap: _submit,
      ),
    );
  }
}

// ─── Section header (Adults / Children / Infants) ─────────────────────────────

class _PassengerSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _PassengerSectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(
        '$label  ·  $count ${count == 1 ? 'passenger' : 'passengers'}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );
}

// ─── Single passenger form card ───────────────────────────────────────────────

class _PassengerFormCard extends StatelessWidget {
  final _PassengerCtrl ctrl;
  final int index;
  final Color brandColor;

  const _PassengerFormCard({
    required this.ctrl,
    required this.index,
    required this.brandColor,
  });

  String get _typeLabel {
    switch (ctrl.type) {
      case PassengerType.adult:
        return ctrl.isLead ? 'Passenger $index · Lead' : 'Passenger $index';
      case PassengerType.child:
        return 'Child $index  (2–11 yrs)';
      case PassengerType.infant:
        return 'Infant $index  (under 2)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInfant = ctrl.type == PassengerType.infant;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: ctrl.isLead
            ? Border.all(color: brandColor.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Text(
              _typeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: brandColor,
              ),
            ),
          ),
          // Name field — all passenger types
          _BookingField(
            controller: ctrl.name,
            label: 'Full Name',
            hint: 'As shown on passport',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          // Passport — adults and children only
          if (!isInfant) ...[
            const _FieldDivider(),
            _BookingField(
              controller: ctrl.passport,
              label: 'Passport Number',
              hint: 'e.g. AB1234567',
              icon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Passport is required'
                  : null,
            ),
          ],
          // Email — lead adult only
          if (ctrl.isLead) ...[
            const _FieldDivider(),
            _BookingField(
              controller: ctrl.email,
              label: 'Email Address',
              hint: 'Ticket confirmation sent here',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Flight summary mini-card ─────────────────────────────────────────────────

class _FlightSummaryCard extends StatelessWidget {
  final FlightResult flight;
  const _FlightSummaryCard({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: flight.logoColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            flight.airline,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '\$${flight.price}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: flight.logoColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _SummaryTime(time: flight.dep, code: flight.fromCode),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  flight.durLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: flight.logoColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1.5,
                                        color: const Color(0xFFDDDDDD),
                                      ),
                                    ),
                                    Icon(
                                      Icons.flight,
                                      size: 14,
                                      color: flight.logoColor,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1.5,
                                        color: const Color(0xFFDDDDDD),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _SummaryTime(time: flight.arr, code: flight.toCode),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            label: flight.seatClass.toUpperCase(),
                            color: flight.logoColor,
                            bg: flight.logoBg,
                          ),
                          const SizedBox(width: 6),
                          _InfoChip(
                            label: flight.stops,
                            color: const Color(0xFF2E7D32),
                            bg: const Color(0xFFE8F5E9),
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

class _SummaryTime extends StatelessWidget {
  final String time, code;
  const _SummaryTime({required this.time, required this.code});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        time,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A2E),
          height: 1,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        code,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _InfoChip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

// ─── Form helpers ─────────────────────────────────────────────────────────────

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    indent: 48,
    color: Color(0xFFF2F2F2),
  );
}

class _BookingField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _BookingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFAAAAAA)),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCCCCCC),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Confirm button ───────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.isLoading,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(
      16,
      12,
      16,
      12 + MediaQuery.of(context).padding.bottom,
    ),
    child: GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isLoading ? color.withValues(alpha: 0.6) : color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    ),
  );
}

// ─── Boarding Pass Screen ─────────────────────────────────────────────────────

class _BoardingPassScreen extends StatefulWidget {
  final List<BookingData> bookings; // one per seated passenger (adult + child)
  final List<PassengerInfo> passengers;
  final Color brandColor;

  const _BoardingPassScreen({
    required this.bookings,
    required this.passengers,
    required this.brandColor,
  });

  @override
  State<_BoardingPassScreen> createState() => _BoardingPassScreenState();
}

class _BoardingPassScreenState extends State<_BoardingPassScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _downloadPasses() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final doc = pw.Document();

      for (int i = 0; i < widget.passengers.length; i++) {
        final passenger = widget.passengers[i];
        final booking = _bookingForIndex(i);
        final passColor = _colorForType(passenger.type);
        final pdfColor = PdfColor(passColor.r, passColor.g, passColor.b);
        final badge = passenger.type == PassengerType.child
            ? 'CHILD'
            : passenger.type == PassengerType.infant
                ? 'INFANT'
                : '';
        final seatValue =
            passenger.type == PassengerType.infant ? 'LAP' : booking.seatNumber;
        final bcbpData =
            'M1${passenger.name.toUpperCase().replaceAll(' ', '/')} '
            '${booking.boardingCode} '
            '${booking.fromCode}${booking.toCode}${booking.flightNumber}';

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (pw.Context ctx) => pw.Center(
              child: pw.Container(
                width: 400,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: pdfColor, width: 1.5),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    // Header
                    pw.Container(
                      color: pdfColor,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            booking.airlineName,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.Row(
                            children: [
                              if (badge.isNotEmpty) ...[
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                    borderRadius:
                                        pw.BorderRadius.circular(8),
                                  ),
                                  child: pw.Text(
                                    badge,
                                    style: pw.TextStyle(
                                      color: pdfColor,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                              ],
                              pw.Text(
                                booking.flightNumber,
                                style: const pw.TextStyle(
                                    color: PdfColors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Route
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                booking.fromCode,
                                style: pw.TextStyle(
                                    fontSize: 26,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                booking.from,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey),
                              ),
                            ],
                          ),
                          pw.Text(
                            '-------',
                            style: pw.TextStyle(
                                color: pdfColor,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                booking.toCode,
                                style: pw.TextStyle(
                                    fontSize: 26,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                booking.to,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    // Details
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: pw.Column(
                        children: [
                          _pdfRow('Passenger', passenger.name),
                          pw.SizedBox(height: 6),
                          _pdfRow(
                            'Departure',
                            booking.departureAt.length >= 16
                                ? booking.departureAt
                                    .substring(0, 16)
                                    .replaceAll('T', '  ')
                                : booking.departureAt,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            children: [
                              pw.Expanded(
                                  child: _pdfRow('Seat', seatValue)),
                              pw.Expanded(
                                  child: _pdfRow('Class', booking.seatClass)),
                              pw.Expanded(
                                  child: _pdfRow('Gate', booking.gate)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey300),
                    // Barcode
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Column(
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.pdf417(),
                            data: bcbpData,
                            width: 320,
                            height: 80,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            booking.boardingCode,
                            style: pw.TextStyle(
                              fontSize: 12,
                              letterSpacing: 3,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Scan at the gate',
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'boarding_pass_${widget.bookings.first.boardingCode}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate PDF: $e'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  /// Returns the BookingData for passenger at [index].
  /// Non-infants each get their own entry (different seat).
  /// Infants ride LAP so reuse the first booking for flight info.
  BookingData _bookingForIndex(int index) {
    int seatIndex = 0;
    for (int i = 0; i < index; i++) {
      if (widget.passengers[i].type != PassengerType.infant) seatIndex++;
    }
    if (widget.passengers[index].type == PassengerType.infant) {
      return widget.bookings.first;
    }
    return seatIndex < widget.bookings.length
        ? widget.bookings[seatIndex]
        : widget.bookings.first;
  }

  Color _colorForType(PassengerType type) {
    switch (type) {
      case PassengerType.adult:
        return widget.brandColor;
      case PassengerType.child:
        return const Color(0xFF0277BD);
      case PassengerType.infant:
        return const Color(0xFF6A1B9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.bookings.first;
    final passengers = widget.passengers;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          passengers.length == 1
              ? 'Boarding Pass'
              : 'Boarding Pass ${_currentPage + 1} / ${passengers.length}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Success header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Boarding Code: ${booking.boardingCode}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── PageView of boarding passes ──
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: passengers.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final passenger = passengers[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SingleBoardingPass(
                    booking: _bookingForIndex(index),
                    passenger: passenger,
                    passColor: _colorForType(passenger.type),
                  ),
                );
              },
            ),
          ),

          // ── Page indicator dots ──
          if (passengers.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(passengers.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _colorForType(passengers[index].type)
                        : const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],

          // ── Download button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GestureDetector(
              onTap: _isGeneratingPdf ? null : _downloadPasses,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.brandColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: _isGeneratingPdf
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.brandColor,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 18,
                            color: widget.brandColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Download Passes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: widget.brandColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // ── Done button ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.home),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: widget.brandColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Boarding Pass card ────────────────────────────────────────────────

class _SingleBoardingPass extends StatelessWidget {
  final BookingData booking;
  final PassengerInfo passenger;
  final Color passColor;

  const _SingleBoardingPass({
    required this.booking,
    required this.passenger,
    required this.passColor,
  });

  String get _typeBadge {
    switch (passenger.type) {
      case PassengerType.adult:
        return '';
      case PassengerType.child:
        return 'CHILD';
      case PassengerType.infant:
        return 'INFANT';
    }
  }

  bool get _isInfant => passenger.type == PassengerType.infant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Airline header with optional type badge
                Container(
                  color: passColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.airlineName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          if (_typeBadge.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _typeBadge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            booking.flightNumber,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Route
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _PassColumn(top: booking.fromCode, bottom: booking.from, topLarge: true),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.flight, color: passColor, size: 18),
                            const SizedBox(height: 4),
                            Container(height: 1, color: const Color(0xFFEEEEEE)),
                          ],
                        ),
                      ),
                      _PassColumn(
                        top: booking.toCode,
                        bottom: booking.to,
                        topLarge: true,
                        alignEnd: true,
                      ),
                    ],
                  ),
                ),

                // Times
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PassColumn(
                        top: booking.departureAt.length >= 16
                            ? booking.departureAt.substring(11, 16)
                            : booking.departureAt,
                        bottom: 'Departure',
                      ),
                      _PassColumn(
                        top: booking.arrivalAt.length >= 16
                            ? booking.arrivalAt.substring(11, 16)
                            : booking.arrivalAt,
                        bottom: 'Arrival',
                        alignEnd: true,
                      ),
                    ],
                  ),
                ),

                _DashedDivider(color: passColor),

                // Passenger details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PassRow(label: 'Passenger', value: passenger.name),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _PassRow(
                              label: 'Seat',
                              value: _isInfant ? 'LAP' : booking.seatNumber,
                            ),
                          ),
                          Expanded(
                            child: _PassRow(label: 'Class', value: booking.seatClass),
                          ),
                          Expanded(
                            child: _PassRow(label: 'Gate', value: booking.gate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _PassRow(
                        label: 'Total Price',
                        value: '\$${booking.totalPrice}',
                        valueColor: passColor,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),

                _DashedDivider(color: passColor),

                // Barcode
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Scan at the gate',
                        style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                      ),
                      const SizedBox(height: 12),
                      _QrWidget(
                        svgBytes: booking.qrSvgBytes,
                        boardingCode: booking.boardingCode,
                        passengerName: passenger.name,
                        fromCode: booking.fromCode,
                        toCode: booking.toCode,
                        flightNumber: booking.flightNumber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── PDF helper ───────────────────────────────────────────────────────────────

pw.Widget _pdfRow(String label, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        value,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}

// ─── Boarding pass sub-widgets ────────────────────────────────────────────────

class _PassColumn extends StatelessWidget {
  final String top, bottom;
  final bool topLarge, alignEnd;

  const _PassColumn({
    required this.top,
    required this.bottom,
    this.topLarge = false,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        top,
        style: TextStyle(
          fontSize: topLarge ? 22 : 15,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1A2E),
          letterSpacing: topLarge ? 1 : 0,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        bottom,
        style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
      ),
    ],
  );
}

class _PassRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool valueBold;

  const _PassRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
          color: valueColor ?? const Color(0xFF1A1A2E),
        ),
      ),
    ],
  );
}

class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _Notch(color: color, left: true),
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final count = (constraints.maxWidth / 8).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: 4,
                      height: 1,
                      color: const Color(0xFFDDDDDD),
                    ),
                  ),
                );
              },
            ),
          ),
          _Notch(color: color, left: false),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  final Color color;
  final bool left;
  const _Notch({required this.color, required this.left});

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.horizontal(
        left: left ? Radius.zero : const Radius.circular(8),
        right: left ? const Radius.circular(8) : Radius.zero,
      ),
      border: Border.all(color: const Color(0xFFEEEEEE)),
    ),
  );
}

class _QrWidget extends StatelessWidget {
  final Uint8List? svgBytes;
  final String boardingCode;
  final String passengerName;
  final String fromCode;
  final String toCode;
  final String flightNumber;

  const _QrWidget({
    required this.svgBytes,
    required this.boardingCode,
    required this.passengerName,
    required this.fromCode,
    required this.toCode,
    required this.flightNumber,
  });

  /// Builds a simplified BCBP-style data string for the barcode.
  String get _bcbpData {
    final name = passengerName.toUpperCase().replaceAll(' ', '/');
    return 'M1$name $boardingCode $fromCode$toCode$flightNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: BarcodeWidget(
            barcode: Barcode.pdf417(),
            data: _bcbpData,
            width: 240,
            height: 80,
            color: const Color(0xFF1A1A2E),
            backgroundColor: Colors.white,
            errorBuilder: (context, error) => Text(boardingCode),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          boardingCode,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

// ─── Payment Screen ───────────────────────────────────────────────────────────

enum _PayMethod { syriatelCash, paypal }

class _PaymentScreen extends StatefulWidget {
  final List<BookingData> bookings;
  final List<PassengerInfo> passengers;
  final FlightResult flight;

  const _PaymentScreen({
    required this.bookings,
    required this.passengers,
    required this.flight,
  });

  @override
  State<_PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<_PaymentScreen> {
  _PayMethod? _method;
  bool _isPaying = false;
  bool _showSuccess = false;
  bool _paid = false;

  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _pinObscured = true;
  bool _passObscured = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  double get _total {
    if (widget.bookings.isEmpty) return widget.flight.price.toDouble();
    final sum = widget.bookings.fold<double>(
      0,
      (s, b) => s + (double.tryParse(b.totalPrice) ?? 0),
    );
    return sum > 0 ? sum : widget.flight.price.toDouble();
  }

  Future<void> _pay() async {
    if (_method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Please select a payment method',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE53935),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    setState(() {
      _isPaying = false;
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_paid) {
      return _BoardingPassScreen(
        bookings: widget.bookings,
        passengers: widget.passengers,
        brandColor: widget.flight.logoColor,
      );
    }

    if (_showSuccess) {
      return _PaySuccessScreen(
        total: _total,
        method: _method!,
        onContinue: () => setState(() => _paid = true),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: Column(
        children: [
          // ── Premium dark header ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1729), Color(0xFF1A2C52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            'Secure Checkout',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24A448).withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF24A448).withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 10,
                                color: Color(0xFF24A448),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'SSL Secured',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF24A448),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount + route display
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount Due',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.flight.airline,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Route pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.flight.fromCode,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    widget.flight.dep,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.flight.durLabel,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Icon(
                                      Icons.flight_rounded,
                                      size: 18,
                                      color: Color(0xFF24A448),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.flight.toCode,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    widget.flight.arr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),
          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PaySummaryCard(flight: widget.flight, total: _total),
                    const SizedBox(height: 24),
                    _PaySectionLabel(
                      icon: Icons.payment_rounded,
                      label: 'Payment Method',
                    ),
                    const SizedBox(height: 12),
                    _PayMethodCard(
                      method: _PayMethod.syriatelCash,
                      selected: _method == _PayMethod.syriatelCash,
                      onTap:
                          () =>
                              setState(() => _method = _PayMethod.syriatelCash),
                    ),
                    const SizedBox(height: 10),
                    _PayMethodCard(
                      method: _PayMethod.paypal,
                      selected: _method == _PayMethod.paypal,
                      onTap:
                          () => setState(() => _method = _PayMethod.paypal),
                    ),
                    if (_method != null) ...[
                      const SizedBox(height: 24),
                      if (_method == _PayMethod.syriatelCash)
                        _SyriatelForm(
                          phoneCtrl: _phoneCtrl,
                          pinCtrl: _pinCtrl,
                          pinObscured: _pinObscured,
                          onTogglePin:
                              () =>
                                  setState(
                                    () => _pinObscured = !_pinObscured,
                                  ),
                        )
                      else
                        _PaypalForm(
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          passObscured: _passObscured,
                          onTogglePass:
                              () =>
                                  setState(
                                    () => _passObscured = !_passObscured,
                                  ),
                        ),
                    ],
                    const SizedBox(height: 28),
                    // Security badges row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SecurityBadge(
                          icon: Icons.verified_user_rounded,
                          label: '256-bit SSL',
                          color: const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 10),
                        _SecurityBadge(
                          icon: Icons.shield_rounded,
                          label: 'Encrypted',
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        _SecurityBadge(
                          icon: Icons.privacy_tip_rounded,
                          label: 'PCI DSS',
                          color: const Color(0xFF6A1B9A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PayNowButton(
        isLoading: _isPaying,
        total: _total,
        onTap: _pay,
      ),
    );
  }
}

// ─── Section label helper ─────────────────────────────────────────────────────

class _PaySectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaySectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2C52),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F1729),
          letterSpacing: 0.1,
        ),
      ),
    ],
  );
}

// ─── Security badge ───────────────────────────────────────────────────────────

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SecurityBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

// ─── Payment summary card ─────────────────────────────────────────────────────

class _PaySummaryCard extends StatelessWidget {
  final FlightResult flight;
  final double total;

  const _PaySummaryCard({required this.flight, required this.total});

  @override
  Widget build(BuildContext context) {
    final int totalPax =
        flight.adultCount + flight.childCount + flight.infantCount;
    final double basePrice = flight.price.toDouble();
    final double taxes = total - basePrice > 0 ? total - basePrice : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1729).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1729), Color(0xFF1A2C52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24A448),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    flight.seatClass.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Flight route section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                _PayRouteTime(
                  time: flight.dep,
                  code: flight.fromCode,
                  align: CrossAxisAlignment.start,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        flight.durLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24A448),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF24A448),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.flight_rounded,
                              size: 14,
                              color: Color(0xFF24A448),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _PayRouteTime(
                  time: flight.arr,
                  code: flight.toCode,
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
          // Dashed divider (ticket tear)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                _TicketNotch(isLeft: true),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) => Row(
                      children: List.generate(
                        (c.maxWidth / 10).floor(),
                        (i) => Expanded(
                          child: Container(
                            height: 1.5,
                            color: i.isEven
                                ? const Color(0xFFDDDDDD)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _TicketNotch(isLeft: false),
              ],
            ),
          ),
          // Price breakdown
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                _PriceRow(
                  label:
                      'Base fare × $totalPax passenger${totalPax > 1 ? 's' : ''}',
                  value: '\$${basePrice.toStringAsFixed(2)}',
                  isLight: true,
                ),
                if (taxes > 0) ...[
                  const SizedBox(height: 6),
                  _PriceRow(
                    label: 'Taxes & fees',
                    value: '+\$${taxes.toStringAsFixed(2)}',
                    isLight: true,
                  ),
                ],
                const SizedBox(height: 10),
                Container(height: 1, color: const Color(0xFFF0F0F0)),
                const SizedBox(height: 10),
                _PriceRow(
                  label: 'Total',
                  value: '\$${total.toStringAsFixed(2)}',
                  isLight: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRouteTime extends StatelessWidget {
  final String time, code;
  final CrossAxisAlignment align;

  const _PayRouteTime({
    required this.time,
    required this.code,
    required this.align,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: align,
    children: [
      Text(
        time,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F1729),
          height: 1,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        code,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

class _TicketNotch extends StatelessWidget {
  final bool isLeft;
  const _TicketNotch({required this.isLeft});

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3F8),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isLight;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isLight ? 12 : 14,
          fontWeight: isLight ? FontWeight.w500 : FontWeight.w700,
          color: isLight ? const Color(0xFF888888) : const Color(0xFF0F1729),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: isLight ? 12 : 15,
          fontWeight: isLight ? FontWeight.w600 : FontWeight.w800,
          color: isLight ? const Color(0xFF555555) : const Color(0xFF24A448),
        ),
      ),
    ],
  );
}

// ─── Payment method card ──────────────────────────────────────────────────────

class _PayMethodCard extends StatelessWidget {
  final _PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _PayMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSyriatel = method == _PayMethod.syriatelCash;
    final brandColor =
        isSyriatel ? const Color(0xFFD32F2F) : const Color(0xFF0070BA);
    final gradientColors = isSyriatel
        ? [const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
        : [const Color(0xFF0070BA), const Color(0xFF003087)];
    final bgColor =
        isSyriatel ? const Color(0xFFFFF5F5) : const Color(0xFFF0F6FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? brandColor : const Color(0xFFE8E8E8),
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? brandColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            // Brand logo container
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : bgColor,
                borderRadius: BorderRadius.circular(13),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: brandColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: isSyriatel
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SC',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.white : brandColor,
                            height: 1,
                          ),
                        ),
                        Text(
                          'CASH',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? Colors.white.withValues(alpha: 0.85)
                                : brandColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Pay\nPal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : brandColor,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSyriatel ? 'Syriatel Cash' : 'PayPal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F1729),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isSyriatel
                        ? 'Syrian mobile wallet payment'
                        : 'International secure payment',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: brandColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.transparent : const Color(0xFFCCCCCC),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: brandColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Syriatel Cash form ───────────────────────────────────────────────────────

class _SyriatelForm extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController pinCtrl;
  final bool pinObscured;
  final VoidCallback onTogglePin;

  const _SyriatelForm({
    required this.phoneCtrl,
    required this.pinCtrl,
    required this.pinObscured,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaySectionLabel(
          icon: Icons.phone_iphone_rounded,
          label: 'Syriatel Cash Details',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _PayField(
                controller: phoneCtrl,
                label: 'Phone Number',
                hint: '09XX XXX XXX',
                icon: Icons.phone_outlined,
                accentColor: const Color(0xFFD32F2F),
                keyboardType: TextInputType.phone,
                isLast: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final cleaned = v.trim().replaceAll(' ', '');
                  if (!RegExp(r'^09\d{8}$').hasMatch(cleaned) &&
                      !RegExp(r'^\+963\d{9}$').hasMatch(cleaned)) {
                    return 'Enter a valid Syrian number (09XXXXXXXX)';
                  }
                  return null;
                },
              ),
              _PayObscuredField(
                controller: pinCtrl,
                label: 'Syriatel Cash PIN',
                hint: '• • • • • •',
                icon: Icons.pin_outlined,
                accentColor: const Color(0xFFD32F2F),
                obscured: pinObscured,
                onToggle: onTogglePin,
                keyboardType: TextInputType.number,
                isLast: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'PIN is required';
                  if (v.trim().length < 4) {
                    return 'PIN must be at least 4 digits';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PayInfoNote(
          color: const Color(0xFFD32F2F),
          bg: const Color(0xFFFFF5F5),
          icon: Icons.info_rounded,
          text: 'Amount will be deducted from your Syriatel Cash wallet balance',
          borderColor: const Color(0xFFFFCDD2),
        ),
      ],
    );
  }
}

// ─── PayPal form ──────────────────────────────────────────────────────────────

class _PaypalForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool passObscured;
  final VoidCallback onTogglePass;

  const _PaypalForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.passObscured,
    required this.onTogglePass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaySectionLabel(
          icon: Icons.account_balance_wallet_rounded,
          label: 'PayPal Account',
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _PayField(
                controller: emailCtrl,
                label: 'PayPal Email',
                hint: 'your@email.com',
                icon: Icons.alternate_email_rounded,
                accentColor: const Color(0xFF0070BA),
                keyboardType: TextInputType.emailAddress,
                isLast: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              _PayObscuredField(
                controller: passCtrl,
                label: 'PayPal Password',
                hint: '• • • • • • • •',
                icon: Icons.lock_outline_rounded,
                accentColor: const Color(0xFF0070BA),
                obscured: passObscured,
                onToggle: onTogglePass,
                keyboardType: TextInputType.visiblePassword,
                isLast: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Password is required';
                  }
                  if (v.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PayInfoNote(
          color: const Color(0xFF0070BA),
          bg: const Color(0xFFF0F6FF),
          icon: Icons.security_rounded,
          text:
              'Your credentials are end-to-end encrypted via PayPal\'s secure gateway',
          borderColor: const Color(0xFFBBD6F5),
        ),
      ],
    );
  }
}

// ─── Styled pay field ─────────────────────────────────────────────────────────

class _PayField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final Color accentColor;
  final TextInputType keyboardType;
  final bool isLast;
  final String? Function(String?)? validator;

  const _PayField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accentColor,
    required this.isLast,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F1729),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF0F1729).withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  floatingLabelStyle: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Padding(
          padding: const EdgeInsets.only(left: 62),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
    ],
  );
}

// ─── Styled pay obscured field ────────────────────────────────────────────────

class _PayObscuredField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final Color accentColor;
  final bool obscured;
  final VoidCallback onToggle;
  final TextInputType keyboardType;
  final bool isLast;
  final String? Function(String?)? validator;

  const _PayObscuredField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accentColor,
    required this.obscured,
    required this.onToggle,
    required this.isLast,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscured,
                validator: validator,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F1729),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF0F1729).withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  floatingLabelStyle: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: onToggle,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Padding(
          padding: const EdgeInsets.only(left: 62),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
    ],
  );
}

// ─── Info note ────────────────────────────────────────────────────────────────

class _PayInfoNote extends StatelessWidget {
  final Color color, bg;
  final Color? borderColor;
  final IconData icon;
  final String text;

  const _PayInfoNote({
    required this.color,
    required this.bg,
    required this.icon,
    required this.text,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor ?? color.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Pay Now button ───────────────────────────────────────────────────────────

class _PayNowButton extends StatelessWidget {
  final bool isLoading;
  final double total;
  final VoidCallback onTap;

  const _PayNowButton({
    required this.isLoading,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    padding: EdgeInsets.fromLTRB(
      20,
      14,
      20,
      14 + MediaQuery.of(context).padding.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLoading
                    ? [
                        const Color(0xFF24A448).withValues(alpha: 0.55),
                        const Color(0xFF1A7A34).withValues(alpha: 0.55),
                      ]
                    : const [Color(0xFF24A448), Color(0xFF157A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF24A448).withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Pay  \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 11,
              color: const Color(0xFF24A448).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 5),
            Text(
              'Secured by 256-bit SSL encryption',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF888888).withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─── Payment Success Screen ───────────────────────────────────────────────────

class _PaySuccessScreen extends StatefulWidget {
  final double total;
  final _PayMethod method;
  final VoidCallback onContinue;

  const _PaySuccessScreen({
    required this.total,
    required this.method,
    required this.onContinue,
  });

  @override
  State<_PaySuccessScreen> createState() => _PaySuccessScreenState();
}

class _PaySuccessScreenState extends State<_PaySuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _rippleCtrl;
  late final AnimationController _countCtrl;

  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _btnFade;
  late final Animation<double> _countAnim;

  late final String _txnId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _txnId =
        'FM-${now.millisecondsSinceEpoch.toString().substring(5, 12).toUpperCase()}';

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _circleScale = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );
    _checkProgress = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.38, 0.72, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
    ));
    _cardFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.70, 0.95, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.70, 0.95, curve: Curves.easeOut),
    ));
    _btnFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
    );
    _countAnim = Tween<double>(begin: 0, end: widget.total).animate(
      CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut),
    );

    _mainCtrl.forward().then((_) => _countCtrl.forward());
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _rippleCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final methodName =
        widget.method == _PayMethod.syriatelCash ? 'Syriatel Cash' : 'PayPal';
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF071120),
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero area ────────────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Radial glow
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _circleScale,
                      builder: (_, child) => Opacity(
                        opacity: _circleScale.value * 0.6,
                        child: Center(
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF24A448).withValues(
                                    alpha: 0.22,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ripple + circle
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _rippleCtrl,
                              builder: (_, child) {
                                final v = _rippleCtrl.value;
                                return Opacity(
                                  opacity: (1 - v) * 0.35,
                                  child: Transform.scale(
                                    scale: 0.5 + v * 0.9,
                                    child: Container(
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF24A448),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _rippleCtrl,
                              builder: (_, child) {
                                final v = (_rippleCtrl.value + 0.45) % 1.0;
                                return Opacity(
                                  opacity: (1 - v) * 0.2,
                                  child: Transform.scale(
                                    scale: 0.5 + v * 0.9,
                                    child: Container(
                                      width: 170,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF24A448),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ScaleTransition(
                              scale: _circleScale,
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2ECC71),
                                      Color(0xFF1A9E50),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF24A448,
                                      ).withValues(alpha: 0.55),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: AnimatedBuilder(
                                  animation: _checkProgress,
                                  builder: (_, child) => CustomPaint(
                                    painter: _CheckmarkPainter(
                                      _checkProgress.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              const Text(
                                'Payment Successful!',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimatedBuilder(
                                animation: _countAnim,
                                builder: (_, child) => Text(
                                  '\$${_countAnim.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2ECC71),
                                    letterSpacing: -1.5,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Charged via $methodName',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Transaction card ─────────────────────────────────────────────
            FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.09),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    children: [
                      _TxnRow(label: 'Transaction ID', value: _txnId),
                      const _TxnDivider(),
                      _TxnRow(label: 'Date & Time', value: '$dateStr  $timeStr'),
                      const _TxnDivider(),
                      _TxnRow(label: 'Method', value: methodName),
                      const _TxnDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF24A448).withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF24A448).withValues(
                                  alpha: 0.4,
                                ),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Color(0xFF2ECC71),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Approved',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2ECC71),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ── View Boarding Pass button ─────────────────────────────────────
            FadeTransition(
              opacity: _btnFade,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                child: GestureDetector(
                  onTap: widget.onContinue,
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF24A448), Color(0xFF157A2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF24A448).withValues(alpha: 0.45),
                          blurRadius: 22,
                          offset: const Offset(0, 7),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplane_ticket_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'View Boarding Pass',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
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
    );
  }
}

// ─── Checkmark painter ────────────────────────────────────────────────────────

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  const _CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.50)
      ..lineTo(size.width * 0.42, size.height * 0.68)
      ..lineTo(size.width * 0.78, size.height * 0.32);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    canvas.drawPath(
      metrics.first.extractPath(0, metrics.first.length * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

// ─── Transaction helpers ──────────────────────────────────────────────────────

class _TxnRow extends StatelessWidget {
  final String label, value;
  const _TxnRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );
}

class _TxnDivider extends StatelessWidget {
  const _TxnDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
  );
}
