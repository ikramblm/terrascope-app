import 'package:flutter/material.dart';

import '../../../../games/guess_outline/data/country_outline_repository.dart';

/// Fixed world projection bounds — cropped south of Antarctica (no
/// country sits there, and including it would waste most of the map's
/// vertical space and distort the aspect ratio) rather than derived
/// from the outline dataset per render.
const double _worldMinLon = -180;
const double _worldMaxLon = 180;
const double _worldMinLat = -60;
const double _worldMaxLat = 85;
const double _lonSpan = _worldMaxLon - _worldMinLon;
const double _latSpan = _worldMaxLat - _worldMinLat;

/// Traces one outline ring into [path], breaking it into a fresh
/// subpath wherever consecutive points jump more than 180° in raw
/// longitude — a handful of countries (Russia, Fiji) have rings that
/// cross the antimeridian (±180°), and without this, connecting those
/// two points straight across the map draws a long spurious line
/// clear across the whole width instead of two separate landmasses.
void _addRing(
  Path path,
  List<Offset> ring,
  Offset Function(double lon, double lat) project,
) {
  if (ring.isEmpty) return;
  var prevLon = ring.first.dx;
  final first = project(ring.first.dx, ring.first.dy);
  path.moveTo(first.dx, first.dy);
  for (final point in ring.skip(1)) {
    if ((point.dx - prevLon).abs() > 180) {
      path.close();
      final p = project(point.dx, point.dy);
      path.moveTo(p.dx, p.dy);
    } else {
      final p = project(point.dx, point.dy);
      path.lineTo(p.dx, p.dy);
    }
    prevLon = point.dx;
  }
  path.close();
}

/// A tappable world map: every outlined country renders as one neutral
/// "land" silhouette — no borders, no per-country color, nothing that
/// would give a guess away — so there's a real geographic reference
/// (continent shapes) without revealing exact country boundaries. Once
/// a guess has been made this round, the real target location, the
/// tapped location, and a line between them are drawn too.
class WorldTapMap extends StatelessWidget {
  const WorldTapMap({
    super.key,
    required this.outlines,
    required this.onGuess,
    this.enabled = true,
    this.guessLon,
    this.guessLat,
    this.actualLon,
    this.actualLat,
    this.isCorrect,
  });

  final Map<String, CountryOutline> outlines;
  final void Function(double lon, double lat) onGuess;
  final bool enabled;
  final double? guessLon;
  final double? guessLat;
  final double? actualLon;
  final double? actualLat;

  /// Whether the most recent guess counted as correct — null before any
  /// guess this round. Drives the pin colors: both pins render green
  /// together on a correct guess instead of the usual red-guess /
  /// green-actual pairing.
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: _WorldTapMapPainter._ocean,
        // AspectRatio has to sit OUTSIDE InteractiveViewer, not inside
        // it: InteractiveViewer's child fills whatever box it's given,
        // so an AspectRatio nested inside it receives a fully tight box
        // and can't actually enforce a ratio — the map just stretches
        // to match the container instead. Computing the
        // correctly-proportioned box first and handing InteractiveViewer
        // exactly that box is what keeps the map's real shape — filling
        // this same box, never a separate popup — whether it's zoomed
        // in or not.
        child: Center(
          child: AspectRatio(
            aspectRatio: _lonSpan / _latSpan,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return GestureDetector(
                    key: const Key('world_tap_map'),
                    onTapUp: enabled
                        ? (details) {
                            final local = details.localPosition;
                            final lon =
                                (_worldMinLon +
                                        local.dx / size.width * _lonSpan)
                                    .clamp(_worldMinLon, _worldMaxLon);
                            final lat =
                                (_worldMaxLat -
                                        local.dy / size.height * _latSpan)
                                    .clamp(_worldMinLat, _worldMaxLat);
                            onGuess(lon, lat);
                          }
                        : null,
                    child: CustomPaint(
                      size: size,
                      painter: _WorldTapMapPainter(
                        outlines: outlines,
                        guessLon: guessLon,
                        guessLat: guessLat,
                        actualLon: actualLon,
                        actualLat: actualLat,
                        isCorrect: isCorrect,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldTapMapPainter extends CustomPainter {
  _WorldTapMapPainter({
    required this.outlines,
    this.guessLon,
    this.guessLat,
    this.actualLon,
    this.actualLat,
    this.isCorrect,
  });

  final Map<String, CountryOutline> outlines;
  final double? guessLon;
  final double? guessLat;
  final double? actualLon;
  final double? actualLat;
  final bool? isCorrect;

  static const _ocean = Color(0xFFBFE3F5);
  static const _land = Color(0xFFE8DCB8);
  static const _border = Color(0xFF9C7A45);
  static const _correctColor = Color(0xFF22C55E);
  static const _wrongColor = Color(0xFFFF6B6B);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _ocean);

    final scaleX = size.width / _lonSpan;
    final scaleY = size.height / _latSpan;

    Offset project(double lon, double lat) {
      final x = (lon - _worldMinLon) * scaleX;
      final y = (_worldMaxLat - lat) * scaleY;
      return Offset(x, y);
    }

    final landPaint = Paint()..color = _land;
    // A visible stroke per country, on top of the shared land fill, is
    // what makes this read as "a map with borders" instead of one flat
    // continent-shaped blob — scaled with the canvas so it stays a
    // sensible width whether the player is zoomed out or in close.
    final borderPaint = Paint()
      ..color = _border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (final outline in outlines.values) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final polygon in outline) {
        for (final ring in polygon) {
          _addRing(path, ring, project);
        }
      }
      canvas.drawPath(path, landPaint);
      canvas.drawPath(path, borderPaint);
    }

    final aLon = actualLon;
    final aLat = actualLat;
    if (aLon != null && aLat != null) {
      final actual = project(aLon, aLat);
      final gLon = guessLon;
      final gLat = guessLat;
      if (gLon != null && gLat != null) {
        final guess = project(gLon, gLat);
        // Both pins turn green together on a correct guess instead of
        // the usual red-guess / green-actual pairing — a right answer
        // should read as unambiguously right.
        final guessColor = isCorrect == true ? _correctColor : _wrongColor;
        canvas.drawLine(
          guess,
          actual,
          Paint()
            ..color = guessColor
            ..strokeWidth = 2,
        );
        _drawPin(canvas, guess, guessColor);
      }
      _drawPin(canvas, actual, _correctColor);
    }
  }

  void _drawPin(Canvas canvas, Offset at, Color color) {
    canvas.drawCircle(at, 9, Paint()..color = Colors.white);
    canvas.drawCircle(at, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WorldTapMapPainter oldDelegate) =>
      oldDelegate.guessLon != guessLon ||
      oldDelegate.guessLat != guessLat ||
      oldDelegate.actualLon != actualLon ||
      oldDelegate.actualLat != actualLat ||
      oldDelegate.isCorrect != isCorrect ||
      oldDelegate.outlines != outlines;
}
