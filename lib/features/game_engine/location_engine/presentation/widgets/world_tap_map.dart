import 'dart:math' as math;

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

/// The map's own drawing surface, at a fixed size matching the real
/// lon/lat aspect ratio — never resized to match whatever box this
/// widget is given. [FittedBox] scales it to fit that box, so a
/// mismatched container ratio always shows as letterboxing, never as
/// stretching or cropping.
const double _mapWidth = 1400;
const double _mapHeight = _mapWidth * _latSpan / _lonSpan;

/// Deep zoom so tiny countries (Luxembourg, Malta, Caribbean islands…)
/// can be tapped accurately.
const double _maxZoom = 40;

const Color _ocean = Color(0xFFBFE3F5);
const Color _land = Color(0xFFE8DCB8);
const Color _border = Color(0xFF9C7A45);
const Color _correctColor = Color(0xFF22C55E);
const Color _wrongColor = Color(0xFFEF4444);

Offset _project(double lon, double lat) => Offset(
  (lon - _worldMinLon) / _lonSpan * _mapWidth,
  (_worldMaxLat - lat) / _latSpan * _mapHeight,
);

/// Traces one outline ring into [path], breaking it into a fresh
/// subpath wherever consecutive points jump more than 180° in raw
/// longitude — a handful of countries (Russia, Fiji) have rings that
/// cross the antimeridian (±180°), and without this, connecting those
/// two points straight across the map draws a long spurious line
/// clear across the whole width instead of two separate landmasses.
void _addRing(Path path, List<Offset> ring) {
  if (ring.isEmpty) return;
  var prevLon = ring.first.dx;
  final first = _project(ring.first.dx, ring.first.dy);
  path.moveTo(first.dx, first.dy);
  for (final point in ring.skip(1)) {
    final p = _project(point.dx, point.dy);
    if ((point.dx - prevLon).abs() > 180) {
      path.close();
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
    prevLon = point.dx;
  }
  path.close();
}

Path _outlinePath(CountryOutline outline) {
  final path = Path()..fillType = PathFillType.evenOdd;
  for (final polygon in outline) {
    for (final ring in polygon) {
      _addRing(path, ring);
    }
  }
  return path;
}

/// A tappable world map. Every country is drawn as a neutral land shape
/// with a thin border — nothing that gives the answer away. After a
/// guess, the target country is filled green (correct) or red (wrong),
/// and the map zooms in on it so even the smallest countries are clearly
/// visible. Pinch to zoom up to 40× for precise taps.
class WorldTapMap extends StatefulWidget {
  const WorldTapMap({
    super.key,
    required this.outlines,
    required this.onGuess,
    this.enabled = true,
    this.guessLon,
    this.guessLat,
    this.actualLon,
    this.actualLat,
    this.highlightCca3,
    this.isCorrect,
  });

  final Map<String, CountryOutline> outlines;
  final void Function(double lon, double lat) onGuess;
  final bool enabled;
  final double? guessLon;
  final double? guessLat;

  /// The target's reference point — non-null only once the round has
  /// been answered (this is what flips the map into "reveal" mode).
  final double? actualLon;
  final double? actualLat;

  /// The target country's code, so its surface can be colored.
  final String? highlightCca3;

  /// Whether the most recent guess was correct — null before any guess.
  final bool? isCorrect;

  @override
  State<WorldTapMap> createState() => _WorldTapMapState();
}

class _WorldTapMapState extends State<WorldTapMap>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Animation<Matrix4>? _animation;

  /// Country paths are built once and reused on every frame — rebuilding
  /// ~170 complex paths per paint is what made zooming laggy on slower
  /// phones.
  late Map<String, Path> _paths;
  Size _viewSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _paths = widget.outlines.map((k, v) => MapEntry(k, _outlinePath(v)));
    _anim.addListener(() {
      final a = _animation;
      if (a != null) _controller.value = a.value;
    });
  }

  @override
  void didUpdateWidget(covariant WorldTapMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.outlines, widget.outlines)) {
      _paths = widget.outlines.map((k, v) => MapEntry(k, _outlinePath(v)));
    }
    if (oldWidget.actualLon == null && widget.actualLon != null) {
      _focusTarget();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Bounding box (in map units) of the target country. For countries
  /// whose ring wraps the antimeridian (Russia, Fiji) the full bounds
  /// would span the whole map, so the largest single part is used.
  Rect? _targetBounds() {
    final id = widget.highlightCca3;
    final path = id == null ? null : _paths[id];
    if (path == null) return null;
    final bounds = path.getBounds();
    if (bounds.width <= _mapWidth * 0.6) return bounds;
    final outline = widget.outlines[id];
    if (outline == null) return bounds;
    Rect? best;
    var bestArea = -1.0;
    for (final polygon in outline) {
      if (polygon.isEmpty) continue;
      final p = Path();
      _addRing(p, polygon.first);
      final b = p.getBounds();
      final area = b.width * b.height;
      if (b.width <= _mapWidth * 0.6 && area > bestArea) {
        best = b;
        bestArea = area;
      }
    }
    return best ?? bounds;
  }

  void _focusTarget() {
    final view = _viewSize;
    final lon = widget.actualLon;
    final lat = widget.actualLat;
    if (!mounted || view.isEmpty || lon == null || lat == null) return;

    final fit = math.min(view.width / _mapWidth, view.height / _mapHeight);
    final bounds = _targetBounds();

    final Offset center;
    double zoom;
    if (bounds == null) {
      center = _project(lon, lat);
      zoom = 14;
    } else {
      center = bounds.center;
      zoom = math.min(
        view.width / math.max(bounds.width * fit * 2.4, 1),
        view.height / math.max(bounds.height * fit * 2.4, 1),
      );
    }
    zoom = zoom.clamp(1.0, 20.0);

    final p0 = Offset(
      (view.width - _mapWidth * fit) / 2 + center.dx * fit,
      (view.height - _mapHeight * fit) / 2 + center.dy * fit,
    );
    final tx = (view.width / 2 - zoom * p0.dx).clamp(
      view.width * (1 - zoom),
      0.0,
    );
    final ty = (view.height / 2 - zoom * p0.dy).clamp(
      view.height * (1 - zoom),
      0.0,
    );
    final end = Matrix4.identity()
      ..setEntry(0, 0, zoom)
      ..setEntry(1, 1, zoom)
      ..setTranslationRaw(tx, ty, 0);

    _animation = Matrix4Tween(begin: _controller.value, end: end).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic),
    );
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final answered = widget.actualLon != null && widget.actualLat != null;
    final id = widget.highlightCca3;
    final highlightColor = widget.isCorrect == true
        ? _correctColor
        : _wrongColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: _ocean,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _viewSize = Size(constraints.maxWidth, constraints.maxHeight);
            final fit = math.min(
              constraints.maxWidth / _mapWidth,
              constraints.maxHeight / _mapHeight,
            );
            // InteractiveViewer starts at scale 1 = the whole map fitted
            // to the box, and can't zoom out past it, so the map can
            // never start or end up cropped.
            return InteractiveViewer(
              transformationController: _controller,
              minScale: 1,
              maxScale: _maxZoom,
              onInteractionStart: (_) => _anim.stop(),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _mapWidth,
                  height: _mapHeight,
                  child: GestureDetector(
                    key: const Key('world_tap_map'),
                    onTapUp: widget.enabled
                        ? (details) {
                            final local = details.localPosition;
                            final lon =
                                (_worldMinLon +
                                        local.dx / _mapWidth * _lonSpan)
                                    .clamp(_worldMinLon, _worldMaxLon);
                            final lat =
                                (_worldMaxLat -
                                        local.dy / _mapHeight * _latSpan)
                                    .clamp(_worldMinLat, _worldMaxLat);
                            widget.onGuess(lon, lat);
                          }
                        : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Static layer: its own repaint boundary, so
                        // zooming/panning never re-records the map.
                        RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(_mapWidth, _mapHeight),
                            painter: _LandPainter(_paths),
                          ),
                        ),
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size(_mapWidth, _mapHeight),
                            painter: _OverlayPainter(
                              controller: _controller,
                              fitScale: fit,
                              highlight: answered && id != null
                                  ? _paths[id]
                                  : null,
                              highlightColor: highlightColor,
                              target: answered
                                  ? _project(
                                      widget.actualLon!,
                                      widget.actualLat!,
                                    )
                                  : null,
                              guess:
                                  widget.guessLon != null &&
                                      widget.guessLat != null
                                  ? _project(
                                      widget.guessLon!,
                                      widget.guessLat!,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandPainter extends CustomPainter {
  _LandPainter(this.paths);

  final Map<String, Path> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()..color = _land;
    // strokeWidth 0 = a one-pixel hairline at any zoom level, so borders
    // stay crisp when zoomed in instead of becoming thick bars.
    final borderPaint = Paint()
      ..color = _border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0;
    for (final path in paths.values) {
      canvas.drawPath(path, landPaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LandPainter oldDelegate) =>
      !identical(oldDelegate.paths, paths);
}

/// Everything that changes during a round: the colored target country
/// and the guess marker. Sizes are divided by the current zoom so pins
/// and outlines keep a constant on-screen size.
class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.controller,
    required this.fitScale,
    required this.highlight,
    required this.highlightColor,
    required this.target,
    required this.guess,
  }) : super(repaint: controller);

  final TransformationController controller;
  final double fitScale;
  final Path? highlight;
  final Color highlightColor;
  final Offset? target;
  final Offset? guess;

  @override
  void paint(Canvas canvas, Size size) {
    // Map units per on-screen pixel at the current zoom.
    final px = 1 / (fitScale * controller.value.getMaxScaleOnAxis());

    final path = highlight;
    if (path != null) {
      canvas.drawPath(
        path,
        Paint()..color = highlightColor.withValues(alpha: 0.9),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(highlightColor, Colors.black, 0.35)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * px,
      );
    }

    final t = target;
    if (t != null && path == null) {
      // No outline for this country (micro-state / small island): mark
      // its location with a filled ring instead.
      canvas.drawCircle(
        t,
        18 * px,
        Paint()..color = highlightColor.withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        t,
        18 * px,
        Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * px,
      );
      _pin(canvas, t, highlightColor, px);
    }

    final g = guess;
    if (g != null) {
      if (t != null && path == null) {
        canvas.drawLine(
          g,
          t,
          Paint()
            ..color = _wrongColor
            ..strokeWidth = 2 * px,
        );
      }
      // The guess pin is green when it landed on the country, red when
      // it didn't — same as the country fill.
      _pin(canvas, g, path != null || t != null ? highlightColor : _wrongColor, px);
    }
  }

  void _pin(Canvas canvas, Offset at, Color color, double px) {
    canvas.drawCircle(at, 9 * px, Paint()..color = Colors.white);
    canvas.drawCircle(at, 6 * px, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.fitScale != fitScale ||
      !identical(old.highlight, highlight) ||
      old.highlightColor != highlightColor ||
      old.target != target ||
      old.guess != guess;
}
