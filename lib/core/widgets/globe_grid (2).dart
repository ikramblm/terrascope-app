import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A decorative globe — outline, meridians, and parallels — drawn
/// procedurally so headers get a real "world/geography" motif instead of
/// a flat generic icon, with zero image assets to bundle or download.
class GlobeGrid extends StatelessWidget {
  const GlobeGrid({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.4,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GlobeGridPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _GlobeGridPainter extends CustomPainter {
  _GlobeGridPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer sphere outline.
    canvas.drawCircle(center, radius, paint);

    // Meridians: vertical ellipses of decreasing width, evoking a globe's
    // curvature (a flat vertical line would read as a slice, not a sphere).
    for (final widthFraction in [0.72, 0.36]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * widthFraction,
          height: radius * 2,
        ),
        paint,
      );
    }

    // Parallels: horizontal lines, foreshortened toward the poles.
    for (final latFraction in [-0.55, 0.0, 0.55]) {
      final y = center.dy + radius * latFraction;
      final chord = math.sqrt(
        math.max(
          0.0,
          radius * radius - (radius * latFraction) * (radius * latFraction),
        ),
      );
      canvas.drawLine(
        Offset(center.dx - chord, y),
        Offset(center.dx + chord, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlobeGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
