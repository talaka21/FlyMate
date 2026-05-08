import 'package:flutter/material.dart';

class BaggagePage extends StatefulWidget {
  const BaggagePage({super.key});

  @override
  State<BaggagePage> createState() => _BaggagePageState();
}

class _BaggagePageState extends State<BaggagePage> {
  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  int _selectedClass = 0;
  final _classes = ['Economy', 'Business', 'First'];

  final _allowances = [
    _ClassAllowance(
      className: 'Economy',
      carryOn: '7 kg / 1 bag',
      checked: '23 kg / 1 bag',
      personal: '1 personal item',
      extraFee: '\$40 per extra bag',
      overweightFee: '\$15 per extra kg',
      icon: Icons.weekend_outlined,
      color: Color(0xFF1D5BBF),
    ),
    _ClassAllowance(
      className: 'Business',
      carryOn: '10 kg / 2 bags',
      checked: '32 kg / 2 bags',
      personal: '1 personal item',
      extraFee: '\$30 per extra bag',
      overweightFee: '\$10 per extra kg',
      icon: Icons.business_center_outlined,
      color: Color(0xFF7C3AED),
    ),
    _ClassAllowance(
      className: 'First',
      carryOn: '12 kg / 2 bags',
      checked: '32 kg / 3 bags',
      personal: '1 personal item',
      extraFee: 'Complimentary',
      overweightFee: 'Complimentary',
      icon: Icons.star_outline_rounded,
      color: Color(0xFFF59E0B),
    ),
  ];

  final _tips = const [
    _BaggageTip(
      icon: Icons.lock_outline_rounded,
      title: 'Lock your bags',
      body: 'Use TSA-approved locks to secure your checked luggage.',
    ),
    _BaggageTip(
      icon: Icons.label_outline_rounded,
      title: 'Tag everything',
      body: 'Attach a luggage tag with your name and contact info.',
    ),
    _BaggageTip(
      icon: Icons.compress_rounded,
      title: 'Pack light',
      body: 'Roll clothes instead of folding to save space and reduce weight.',
    ),
    _BaggageTip(
      icon: Icons.camera_alt_outlined,
      title: 'Photo your bag',
      body: 'Take a photo before check-in to help identify it if lost.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final allowance = _allowances[_selectedClass];

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClassSelector(),
                      const SizedBox(height: 20),
                      _buildAllowanceCard(allowance),
                      const SizedBox(height: 20),
                      _buildFeesCard(allowance),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Packing Tips'),
                      const SizedBox(height: 12),
                      _buildTips(),
                      const SizedBox(height: 24),
                      _buildProhibitedCard(),
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
                'Baggage Info',
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
            'Baggage Allowance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Know your limits before you pack',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: List.generate(_classes.length, (i) {
          final selected = _selectedClass == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedClass = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _classes[i],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAllowanceCard(_ClassAllowance a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, color: a.color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.className,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  Text(
                    'Baggage allowance',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _allowanceRow(
            Icons.backpack_outlined,
            'Carry-On',
            a.carryOn,
            const Color(0xFF1D5BBF),
          ),
          const SizedBox(height: 12),
          _allowanceRow(
            Icons.luggage_outlined,
            'Checked Bag',
            a.checked,
            const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),
          _allowanceRow(
            Icons.shopping_bag_outlined,
            'Personal Item',
            a.personal,
            const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _allowanceRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
      ],
    );
  }

  Widget _buildFeesCard(_ClassAllowance a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extra Fees',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 16),
          _feeRow('Additional bag', a.extraFee, Icons.add_circle_outline),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF0F4FF)),
          ),
          _feeRow('Overweight (per kg)', a.overweightFee, Icons.scale_outlined),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, IconData icon) {
    final isFree = value == 'Complimentary';
    return Row(
      children: [
        Icon(icon, color: _primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isFree
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isFree
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _dark,
      ),
    );
  }

  Widget _buildTips() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: _tips.map((t) => _TipCard(tip: t)).toList(),
    );
  }

  Widget _buildProhibitedCard() {
    const items = [
      'Flammable liquids & gases',
      'Explosives & fireworks',
      'Sharp objects in carry-on',
      'Liquids over 100ml (carry-on)',
      'Lithium batteries (checked)',
      'Aerosols over 500ml',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.block_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text(
                'Prohibited Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tip Card ──────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final _BaggageTip tip;
  const _TipCard({required this.tip});

  static const _primary = Color(0xFF1D5BBF);
  static const _dark = Color(0xFF1A3A6E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tip.icon, color: _primary, size: 20),
          const SizedBox(height: 8),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              tip.body,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────

class _ClassAllowance {
  final String className;
  final String carryOn;
  final String checked;
  final String personal;
  final String extraFee;
  final String overweightFee;
  final IconData icon;
  final Color color;

  const _ClassAllowance({
    required this.className,
    required this.carryOn,
    required this.checked,
    required this.personal,
    required this.extraFee,
    required this.overweightFee,
    required this.icon,
    required this.color,
  });
}

class _BaggageTip {
  final IconData icon;
  final String title;
  final String body;

  const _BaggageTip({
    required this.icon,
    required this.title,
    required this.body,
  });
}
