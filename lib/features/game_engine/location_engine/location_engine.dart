import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';
import '../../games/guess_outline/data/country_outline_repository.dart';
import '../domain/game_difficulty.dart';
import '../domain/game_result.dart';

/// Drives one play-through of Guess by Location: a country's name
/// appears and one map tap is taken as the guess. The tap is correct
/// only when it lands on the country itself (inside its outline, with a
/// few km of slack for the simplified borders). Countries too small to
/// have an outline fall back to a short-radius distance check around
/// their reference point. Same shape as the multiple-choice engine
/// (per-question countdown, auto-advance after a reveal pause,
/// combo/streak, final [GameResult]), just guess-by-tap instead of
/// guess-by-choice.
///
/// Every entry in [targets] must have non-null `latitude`/`longitude` —
/// the caller filters the pool before construction (see
/// `GuessLocationScreen`), same convention as `AlphabetEngine`'s
/// eligible-letters filter.
class LocationEngine extends ChangeNotifier {
  LocationEngine({
    required this.targets,
    required this.difficulty,
    this.outlines = const {},
  }) : timeRemaining = Duration(seconds: difficulty.secondsPerQuestion);

  final List<Country> targets;
  final GameDifficulty difficulty;

  /// Country silhouettes, keyed by cca3. A tap counts as correct only
  /// when it falls inside the target's outline (or within
  /// [edgeToleranceKm] of its edge). Targets with no outline use
  /// [pointToleranceKm] around their reference point instead.
  final Map<String, CountryOutline> outlines;

  static const _tickInterval = Duration(milliseconds: 100);

  /// How long the distance/score reveal stays on screen before
  /// auto-advancing to the next round.
  static const feedbackDelay = Duration(milliseconds: 1800);

  /// Slack outside an outline's edge that still counts as correct — the
  /// bundled outlines are simplified, so a tap on the visible border of
  /// a small country shouldn't be punished.
  static const edgeToleranceKm = 20.0;

  /// Radius around the reference point for targets that have no outline
  /// (micro-states and small island nations).
  static const pointToleranceKm = 150.0;

  /// A wrong guess still earns partial credit for being near the
  /// country: up to half the base points, fading to zero at this
  /// distance from the country.
  static const _partialZeroKm = 2500.0;

  int currentIndex = 0;
  int score = 0;
  int xpEarned = 0;
  int combo = 0;
  int bestCombo = 0;
  int correctCount = 0;
  final Set<String> correctCca3s = {};

  bool answered = false;
  double? lastGuessLon;
  double? lastGuessLat;

  /// Distance from the tap to the target country: 0 when the tap was
  /// inside it, otherwise the distance to its nearest edge (or to its
  /// reference point when it has no outline). Null only when the round
  /// timed out with no tap at all.
  double? lastDistanceKm;
  int? lastRoundScore;

  /// Whether the round just resolved (tap or timeout) counted as
  /// correct — on the target country itself. The screen uses this to
  /// pick the right/wrong sound and the green/red highlight.
  bool lastGuessWasCorrect = false;

  Duration timeRemaining;
  bool isComplete = false;

  Timer? _ticker;
  Timer? _advanceTimer;

  // clock.now() (package:clock), not DateTime.now() directly or a
  // Stopwatch — both would silently ignore a fake_async test clock;
  // see MultipleChoiceEngine's identical comment for why this matters.
  DateTime? _startedAt;
  Duration _elapsedAtStop = Duration.zero;
  bool _running = false;

  Duration get _clockElapsed =>
      _running ? clock.now().difference(_startedAt!) : _elapsedAtStop;

  Country get currentTarget => targets[currentIndex];
  int get totalQuestions => targets.length;
  Duration get timeAllotted => Duration(seconds: difficulty.secondsPerQuestion);
  Duration get elapsed => _clockElapsed;

  /// Rounds actually resolved — equal to [totalQuestions] after a normal
  /// completion (every target was reached and answered/timed out), but
  /// smaller after [surrender] cuts the session short partway through,
  /// so the end-of-game accuracy stat reflects what was actually played
  /// rather than being diluted by rounds never reached.
  int get _questionsAttempted => answered ? currentIndex + 1 : currentIndex;

  void start() {
    _startedAt = clock.now();
    _running = true;
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    timeRemaining = timeAllotted;
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) {
      final next = timeRemaining - _tickInterval;
      if (next <= Duration.zero) {
        timeRemaining = Duration.zero;
        _ticker?.cancel();
        _handleTimeout();
      } else {
        timeRemaining = next;
      }
      notifyListeners();
    });
  }

  void _handleTimeout() {
    if (answered) return;
    _applyGuess(lon: null, lat: null);
  }

  void submitGuess(double lon, double lat) {
    if (answered || isComplete) return;
    _ticker?.cancel();
    _applyGuess(lon: lon, lat: lat);
  }

  void _applyGuess({required double? lon, required double? lat}) {
    answered = true;
    lastGuessLon = lon;
    lastGuessLat = lat;

    final target = currentTarget;
    final outline = outlines[target.cca3];

    double? distanceKm;
    var correct = false;
    if (lon != null && lat != null) {
      if (outline != null) {
        final inside = _pointInOutline(lon, lat, outline);
        distanceKm = inside ? 0.0 : _distanceToOutlineKm(lon, lat, outline);
        correct = inside || distanceKm <= edgeToleranceKm;
      } else {
        distanceKm = _haversineKm(lon, lat, target.longitude!, target.latitude!);
        correct = distanceKm <= pointToleranceKm;
      }
    }
    lastDistanceKm = distanceKm;

    final roundScore = correct
        ? difficulty.basePoints
        : (distanceKm == null ? 0 : _partialScore(distanceKm));
    lastRoundScore = roundScore;
    score += roundScore;

    lastGuessWasCorrect = correct;
    if (correct) {
      xpEarned += difficulty.baseXp;
      combo += 1;
      bestCombo = combo > bestCombo ? combo : bestCombo;
      correctCount += 1;
      correctCca3s.add(target.cca3);
    } else {
      combo = 0;
    }

    notifyListeners();

    _advanceTimer?.cancel();
    _advanceTimer = Timer(feedbackDelay, nextQuestion);
  }

  int _partialScore(double distanceKm) {
    if (distanceKm >= _partialZeroKm) return 0;
    final t = 1 - distanceKm / _partialZeroKm;
    return (difficulty.basePoints * 0.5 * t).round();
  }

  /// Advances to the next round, or completes the session. Safe to call
  /// manually — cancels any pending auto-advance first.
  void nextQuestion() {
    _advanceTimer?.cancel();
    if (isComplete) return;
    if (currentIndex + 1 >= targets.length) {
      _complete();
      return;
    }
    currentIndex += 1;
    answered = false;
    lastGuessLon = null;
    lastGuessLat = null;
    lastDistanceKm = null;
    lastRoundScore = null;
    lastGuessWasCorrect = false;
    _startQuestionTimer();
  }

  void _complete() {
    if (isComplete) return;
    _ticker?.cancel();
    _advanceTimer?.cancel();
    _elapsedAtStop = _clockElapsed;
    _running = false;
    isComplete = true;
    notifyListeners();
  }

  /// Ends the session immediately, wherever the player currently is —
  /// results are built from whatever was reached, the same as running
  /// out the clock on the last round would.
  void surrender() => _complete();

  GameResult buildResult() {
    return GameResult(
      totalScore: score,
      xpEarned: xpEarned,
      correctCount: correctCount,
      totalQuestions: _questionsAttempted,
      bestCombo: bestCombo,
      elapsed: _clockElapsed,
      correctCca3s: correctCca3s,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  static double _haversineKm(
    double lon1,
    double lat1,
    double lon2,
    double lat2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;

  /// Even-odd ray-casting point-in-polygon test, run across every ring
  /// of every polygon part together — matches the even-odd fill rule
  /// [WorldTapMap] renders the outline with, so "inside" here means
  /// exactly what the player sees filled in as land, holes (enclaves)
  /// included.
  static bool _pointInOutline(double lon, double lat, CountryOutline outline) {
    var inside = false;
    for (final polygon in outline) {
      for (final ring in polygon) {
        final n = ring.length;
        if (n < 3) continue;
        for (var i = 0, j = n - 1; i < n; j = i++) {
          final xi = ring[i].dx, yi = ring[i].dy;
          final xj = ring[j].dx, yj = ring[j].dy;
          final crosses =
              (yi > lat) != (yj > lat) &&
              (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi);
          if (crosses) inside = !inside;
        }
      }
    }
    return inside;
  }

  static double _wrapLon(double d) {
    while (d > 180) {
      d -= 360;
    }
    while (d < -180) {
      d += 360;
    }
    return d;
  }

  /// Great-circle distance from a tap to the nearest point on any edge
  /// of [outline]. The nearest edge point is found in a flat local
  /// projection around the tap (cheap, and accurate at the short ranges
  /// that matter), then measured with Haversine.
  static double _distanceToOutlineKm(
    double lon,
    double lat,
    CountryOutline outline,
  ) {
    final cosLat = max(cos(_degToRad(lat)), 0.01);
    var bestSq = double.infinity;
    var bestLon = lon;
    var bestLat = lat;
    for (final polygon in outline) {
      for (final ring in polygon) {
        final n = ring.length;
        if (n < 2) continue;
        for (var i = 0; i < n; i++) {
          final a = ring[i];
          final b = ring[(i + 1) % n];
          final adx = _wrapLon(a.dx - lon);
          final bdx = _wrapLon(b.dx - lon);
          // A jump of more than 180° is an antimeridian break in the
          // ring, not a real edge.
          if ((adx - bdx).abs() > 180) continue;
          final ax = adx * cosLat, ay = a.dy - lat;
          final bx = bdx * cosLat, by = b.dy - lat;
          final dx = bx - ax, dy = by - ay;
          final lenSq = dx * dx + dy * dy;
          final t = lenSq == 0
              ? 0.0
              : (-(ax * dx + ay * dy) / lenSq).clamp(0.0, 1.0);
          final cx = ax + t * dx, cy = ay + t * dy;
          final sq = cx * cx + cy * cy;
          if (sq < bestSq) {
            bestSq = sq;
            bestLon = lon + cx / cosLat;
            bestLat = lat + cy;
          }
        }
      }
    }
    if (bestSq == double.infinity) return double.infinity;
    return _haversineKm(lon, lat, bestLon, bestLat);
  }
}
