import 'package:flutter/material.dart';

import '../../data/country_outline_repository.dart';

/// Traces one outline ring into [path], breaking it into a fresh
/// subpath wherever consecutive points jump more than 180° in raw
/// longitude — Russia's ring crosses the antimeridian (±180°), and
/// without this, connecting those two points draws a long spurious
/// line straight across the shape instead of leaving it as two parts.
void _addRing(Path path, List<Offset> ring, Offset Function(Offset) project) {
  if (ring.isEmpty) return;
  var prevLon = ring.first.dx;
  final first = project(ring.first);
  path.moveTo(first.dx, first.dy);
  for (final point in ring.skip(1)) {
    if ((point.dx - prevLon).abs() > 180) {
      path.close();
      final p = project(point);
      path.moveTo(p.dx, p.dy);
    } else {
      final p = project(point);
      path.lineTo(p.dx, p.dy);
    }
    prevLon = point.dx;
  }
  path.close();
}

/// Renders a country's silhouette — fit to the available box, aspect
/// ratio preserved, latitude flipped so north is up. Deliberately a flat
/// single-color fill: no borders, no neighboring countries, nothing that
/// would give the answer away beyond the shape itself.
class CountryOutlineShape extends StatelessWidget {
  const CountryOutlineShape({
    super.key,
    required this.outline,
    required this.color,
    this.glowColor,
    this.size = 220,
  });

  final CountryOutline outline;
  final Color color;
  final Color? glowColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CountryOutlinePainter(
          outline: outline,
          color: color,
          glowColor: glowColor,
        ),
      ),
    );
  }
}

class _CountryOutlinePainter extends CustomPainter {
  _CountryOutlinePainter({
    required this.outline,
    required this.color,
    this.glowColor,
  });

  final CountryOutline outline;
  final Color color;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (outline.isEmpty) return;

    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final polygon in outline) {
      for (final ring in polygon) {
        for (final point in ring) {
          if (point.dx < minX) minX = point.dx;
          if (point.dx > maxX) maxX = point.dx;
          if (point.dy < minY) minY = point.dy;
          if (point.dy > maxY) maxY = point.dy;
        }
      }
    }

    final lonSpan = (maxX - minX).clamp(0.0001, double.infinity);
    final latSpan = (maxY - minY).clamp(0.0001, double.infinity);
    // Proportional to the canvas (12px at the default 220px size) rather
    // than a fixed constant — a fixed 12px padding left zero drawable
    // area on a small icon-sized canvas (e.g. 24px).
    final padding = size.shortestSide * (12.0 / 220.0);
    final availableW = size.width - padding * 2;
    final availableH = size.height - padding * 2;
    final scale = (availableW / lonSpan < availableH / latSpan)
        ? availableW / lonSpan
        : availableH / latSpan;

    final drawnW = lonSpan * scale;
    final drawnH = latSpan * scale;
    final offsetX = (size.width - drawnW) / 2;
    final offsetY = (size.height - drawnH) / 2;

    Offset project(Offset geo) {
      final x = offsetX + (geo.dx - minX) * scale;
      // Latitude increases northward; canvas y increases downward.
      final y = offsetY + (maxY - geo.dy) * scale;
      return Offset(x, y);
    }

    final path = Path()..fillType = PathFillType.evenOdd;
    for (final polygon in outline) {
      for (final ring in polygon) {
        _addRing(path, ring, project);
      }
    }

    final glow = glowColor;
    if (glow != null) {
      final glowPaint = Paint()
        ..color = glow.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawPath(path, glowPaint);
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CountryOutlinePainter oldDelegate) =>
      oldDelegate.outline != outline ||
      oldDelegate.color != color ||
      oldDelegate.glowColor != glowColor;
}
