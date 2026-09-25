import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';
import '../../games/guess_outline/data/country_outline_repository.dart';
import '../domain/game_difficulty.dart';
import '../domain/game_result.dart';

/// Drives one play-through of Guess by Location: a country's name
/// appears, one map tap is taken as the guess, scored by real-world
/// distance (Haversine) to its actual coordinates — same shape as the
/// multiple-choice engine (per-question countdown, auto-advance after a
/// reveal pause, combo/streak, final [GameResult]), just guess-by-tap
/// instead of guess-by-choice.
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

  /// Country silhouettes, keyed by cca3 — when the target's outline is
  /// known, a tap anywhere inside it counts as fully correct even if
  /// it's far from the stored reference point. Countries are big; a tap
  /// on the far side of Russia or Brazil from its capital shouldn't
  /// score worse than one a few hundred km off in the ocean next to a
  /// small country. Falls back to pure distance scoring when no outline
  /// is available for that target.
  final Map<String, CountryOutline> outlines;

  static const _tickInterval = Duration(milliseconds: 100);

  /// How long the distance/score reveal stays on screen before
  /// auto-advancing to the next round.
  static const feedbackDelay = Duration(milliseconds: 1800);

  /// A guess within this many km counts as "close enough" — feeds
  /// correctCount/correctCca3s/combo/XP, the same way a right
  /// multiple-choice answer would.
  static const closeEnoughKm = 800.0;

  /// Distance scoring curve: full base points inside [_fullMarksKm],
  /// zero at or beyond [_zeroMarksKm], linear falloff between.
  static const _fullMarksKm = 300.0;
  static const _zeroMarksKm = 10000.0;

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

  /// Null only when the round timed out with no tap at all.
  double? lastDistanceKm;
  int? lastRoundScore;

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
    final distanceKm = (lon == null || lat == null)
        ? null
        : _haversineKm(lon, lat, target.longitude!, target.latitude!);
    lastDistanceKm = distanceKm;

    final outline = outlines[target.cca3];
    final insideCountry = lon != null && lat != null && outline != null
        ? _pointInOutline(lon, lat, outline)
        : false;

    final roundScore = insideCountry
        ? difficulty.basePoints
        : (distanceKm == null ? 0 : _scoreForDistance(distanceKm));
    lastRoundScore = roundScore;
    score += roundScore;

    final isClose =
        insideCountry || (distanceKm != null && distanceKm <= closeEnoughKm);
    if (isClose) {
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

  int _scoreForDistance(double distanceKm) {
    if (distanceKm <= _fullMarksKm) return difficulty.basePoints;
    if (distanceKm >= _zeroMarksKm) return 0;
    final t = 1 - (distanceKm - _fullMarksKm) / (_zeroMarksKm - _fullMarksKm);
    return (difficulty.basePoints * t).round();
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

  GameResult buildResult() {
    return GameResult(
      totalScore: score,
      xpEarned: xpEarned,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
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
}
