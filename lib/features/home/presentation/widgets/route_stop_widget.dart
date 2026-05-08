import 'package:flutter/material.dart';

class RouteStop extends StatelessWidget {
  final String time;
  final String label;
  final bool isLeft;

  const RouteStop({super.key, 
    required this.time,
    required this.label,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final crossAxis = isLeft
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}