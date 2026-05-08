import 'package:flutter/material.dart';

class TrailPainter extends CustomPainter {
  final List<TrailParticle> trail;
  TrailPainter(this.trail);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in trail) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity.clamp(0.0, 0.6))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(TrailPainter old) => true;

  @override
  bool hitTest(Offset position) => false;
}

class TrailParticle {
  double x, y, opacity, radius;
  TrailParticle({
    required this.x,
    required this.y,
    required this.opacity,
    required this.radius,
  });
}
