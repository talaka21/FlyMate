import 'package:flutter/material.dart';

enum FilterType { all, direct, cheap, fast }

class FilterRowWidget extends StatelessWidget {
  final FilterType current;
  final ValueChanged<FilterType> onChanged;

  const FilterRowWidget({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      (FilterType.all, 'All'),
      (FilterType.direct, 'Non-stop only'),
      (FilterType.cheap, 'Cheapest first'),
      (FilterType.fast, 'Fastest first'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final active = current == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(f.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF1565C0) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFCCCCCC),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? Colors.white : const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
