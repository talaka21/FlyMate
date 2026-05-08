import 'package:flutter/material.dart';
import '../../data/models/flight_result_model.dart';

class WeekCalendarWidget extends StatelessWidget {
  final List<DayPrice> week;
  final ValueChanged<int> onDayTap;

  const WeekCalendarWidget({
    super.key,
    required this.week,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final prices = week
        .where((d) => d.price != null)
        .map((d) => d.price!)
        .toList();
    final minP = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: week.map((d) {
                if (d.price == null) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 4,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                  );
                }
                final pct = maxP == minP
                    ? 1.0
                    : (d.price! - minP) / (maxP - minP);
                final h = 4 + pct * 32;
                final col = d.price == minP
                    ? const Color(0xFF639922)
                    : d.price == maxP
                    ? const Color(0xFFD85A30)
                    : const Color(0xFFB5D4F4);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height: h,
                      decoration: BoxDecoration(
                        color: col,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: week.map((d) {
              final isMin = d.price != null && d.price == minP;
              Color bg = Colors.white;
              Color borderCol = const Color(0xFFE0E0E0);
              double borderW = 0.5;
              Color priceCol = const Color(0xFF333333);

              if (d.selected) {
                bg = const Color(0xFFE6F1FB);
                borderCol = const Color(0xFF1565C0);
                borderW = 2;
                priceCol = const Color(0xFF0C447C);
              } else if (isMin) {
                bg = const Color(0xFFEAF3DE);
                borderCol = const Color(0xFF3B6D11);
                priceCol = const Color(0xFF27500A);
              } else if (d.price == null) {
                bg = const Color(0xFFF5F5F5);
              }

              return Expanded(
                child: GestureDetector(
                  onTap: d.price != null ? () => onDayTap(d.date) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCol, width: borderW),
                    ),
                    child: Column(
                      children: [
                        Text(
                          d.dayLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.date}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d.price != null ? '\$${d.price}' : '—',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: d.price != null
                                ? priceCol
                                : const Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(color: const Color(0xFFC0DD97), label: 'Cheapest'),
              const SizedBox(width: 12),
              _LegendDot(
                color: const Color(0xFFE6F1FB),
                borderColor: const Color(0xFF1565C0),
                label: 'Selected',
              ),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFFF5F5F5), label: 'No flights'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendDot({
    required this.color,
    this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
      ),
    ],
  );
}
