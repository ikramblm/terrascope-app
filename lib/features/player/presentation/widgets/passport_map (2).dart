import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../games/guess_outline/data/country_outline_repository.dart';
import '../../../games/guess_outline/providers/country_outline_providers.dart';

/// Traces one outline ring into [path], breaking it into a fresh
/// subpath wherever consecutive points jump more than 180° in raw
/// longitude — a handful of countries (Russia, Fiji) have rings that
/// cross the antimeridian (±180°), and without this, connecting those
/// two points straight across the map draws a long spurious line clear
/// across the whole width instead of two separate landmasses.
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

/// A real, positioned world map — every outlined country drawn at its
/// true relative location via a shared equirectangular projection
/// (`x = longitude, y = -latitude`, one scale for all of them), gold
/// where [discoveredCca3s] contains it, obsidian where not.
///
/// Replaces the earlier scattered mosaic (each country auto-fit to its
/// own tile, no geographic placement). Only the ~166 of 195 countries
/// this app has outline data for can render at all — the rest are
/// honestly absent rather than drawn from invented boundaries.
class PassportMap extends ConsumerWidget {
  const PassportMap({super.key, required this.discoveredCca3s});

  final Set<String> discoveredCca3s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outlinesAsync = ref.watch(countryOutlinesProvider);
    final outlines = outlinesAsync.asData?.value;
    if (outlines == null || outlines.isEmpty) {
      return const SizedBox(height: 160);
    }

    final bounds = _GeoBounds.of(outlines.values);
    return AspectRatio(
      aspectRatio: bounds.lonSpan / bounds.latSpan,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          child: CustomPaint(
            painter: _PassportMapPainter(
              outlines: outlines,
              discoveredCca3s: discoveredCca3s,
              bounds: bounds,
              borderColor: theme.colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
    );
  }
}

/// The shared geographic bounding box across every outlined country —
/// computed once so every country projects through the same scale and
/// offset, unlike [CountryOutlineShape]'s per-country auto-fit.
class _GeoBounds {
  const _GeoBounds({
    required this.minLon,
    required this.maxLon,
    required this.minLat,
    required this.maxLat,
  });

  factory _GeoBounds.of(Iterable<CountryOutline> outlines) {
    var minLon = double.infinity, minLat = double.infinity;
    var maxLon = -double.infinity, maxLat = -double.infinity;
    for (final outline in outlines) {
      for (final polygon in outline) {
        for (final ring in polygon) {
          for (final point in ring) {
            if (point.dx < minLon) minLon = point.dx;
            if (point.dx > maxLon) maxLon = point.dx;
            if (point.dy < minLat) minLat = point.dy;
            if (point.dy > maxLat) maxLat = point.dy;
          }
        }
      }
    }
    return _GeoBounds(
      minLon: minLon,
      maxLon: maxLon,
      minLat: minLat,
      maxLat: maxLat,
    );
  }

  final double minLon;
  final double maxLon;
  final double minLat;
  final double maxLat;

  double get lonSpan => (maxLon - minLon).clamp(0.0001, double.infinity);
  double get latSpan => (maxLat - minLat).clamp(0.0001, double.infinity);
}

class _PassportMapPainter extends CustomPainter {
  _PassportMapPainter({
    required this.outlines,
    required this.discoveredCca3s,
    required this.bounds,
    required this.borderColor,
  });

  final Map<String, CountryOutline> outlines;
  final Set<String> discoveredCca3s;
  final _GeoBounds bounds;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / bounds.lonSpan;

    Offset project(Offset geo) {
      final x = (geo.dx - bounds.minLon) * scale;
      // Latitude increases northward; canvas y increases downward.
      final y = (bounds.maxLat - geo.dy) * scale;
      return Offset(x, y);
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (final entry in outlines.entries) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final polygon in entry.value) {
        for (final ring in polygon) {
          _addRing(path, ring, project);
        }
      }
      final discovered = discoveredCca3s.contains(entry.key);
      canvas.drawPath(
        path,
        Paint()
          ..color = discovered ? AppColors.yellow : AppColors.lockedObsidian,
      );
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PassportMapPainter oldDelegate) =>
      oldDelegate.discoveredCca3s != discoveredCca3s ||
      oldDelegate.outlines != outlines;
}
