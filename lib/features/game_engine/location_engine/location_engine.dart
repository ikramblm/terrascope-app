import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';
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
  LocationEngine({required this.targets, required this.difficulty})
    : timeRemaining = Duration(seconds: difficulty.secondsPerQuestion);

  final List<Country> targets;
  final GameDifficulty difficulty;

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

    final roundScore = distanceKm == null ? 0 : _scoreForDistance(distanceKm);
    lastRoundScore = roundScore;
    score += roundScore;

    final isClose = distanceKm != null && distanceKm <= closeEnoughKm;
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
}
