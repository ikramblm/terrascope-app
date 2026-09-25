import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';
import '../domain/game_difficulty.dart';
import '../domain/game_result.dart';
import '../domain/multiple_choice_question.dart';
import '../logic/score_calculator.dart';

/// Drives one play-through of any multiple-choice mode: per-question
/// countdown timer, scoring, combo/streak, and the final [GameResult].
///
/// This is the one place timer/score/combo logic lives — Guess by Flag
/// and Guess by Emoji both just supply questions and render this engine's
/// state; neither re-implements timing or scoring. A `ChangeNotifier`
/// (not a Riverpod provider) because its state is a single ephemeral game
/// session owned by one screen, not app-wide state.
class MultipleChoiceEngine extends ChangeNotifier {
  MultipleChoiceEngine({
    required this.questions,
    required this.difficulty,
    this.suddenDeath = false,
    this.globalTimeLimit,
  }) : timeRemaining = Duration(seconds: difficulty.secondsPerQuestion);

  final List<MultipleChoiceQuestion> questions;
  final GameDifficulty difficulty;

  /// Speed-run mode: a single wrong (or timed-out) answer ends the
  /// session immediately instead of advancing — [bestCombo] becomes the
  /// run's streak length, the whole point of the mode.
  final bool suddenDeath;

  /// Speed-run mode: the session ends the instant this much real time
  /// has elapsed, regardless of question progress — independent of the
  /// per-question timer, which keeps ticking normally until then.
  final Duration? globalTimeLimit;

  static const _tickInterval = Duration(milliseconds: 100);

  int currentIndex = 0;
  int score = 0;
  int xpEarned = 0;
  int combo = 0;
  int bestCombo = 0;
  int correctCount = 0;
  final Set<String> correctCca3s = {};

  bool answered = false;
  Country? selectedAnswer;
  bool? lastAnswerCorrect;

  Duration timeRemaining;
  bool isComplete = false;

  Timer? _ticker;
  Timer? _advanceTimer;
  Timer? _globalTicker;

  // Deliberately not a `Stopwatch`: `Stopwatch` reads a real monotonic
  // clock regardless of any `fake_async` zone a test runs in, so a
  // Stopwatch-based `elapsed` never advances under `FakeAsync.elapse` —
  // it silently made the global-time-limit logic untestable. `clock.now()`
  // (package:clock) is exactly `DateTime.now()` in production but honors
  // a fake clock in tests.
  DateTime? _startedAt;
  Duration _elapsedAtStop = Duration.zero;
  bool _running = false;

  Duration get _clockElapsed =>
      _running ? clock.now().difference(_startedAt!) : _elapsedAtStop;

  /// How long the correct/incorrect feedback stays on screen before
  /// auto-advancing to the next question.
  static const feedbackDelay = Duration(milliseconds: 1100);

  MultipleChoiceQuestion get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  Duration get timeAllotted => Duration(seconds: difficulty.secondsPerQuestion);
  Duration get elapsed => _clockElapsed;

  void start() {
    _startedAt = clock.now();
    _running = true;
    _startQuestionTimer();
    final limit = globalTimeLimit;
    if (limit != null) {
      _globalTicker = Timer.periodic(_tickInterval, (_) {
        if (_clockElapsed >= limit) {
          _globalTicker?.cancel();
          _complete();
        }
      });
    }
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
    _applyAnswer(selected: null, isCorrect: false);
  }

  /// Time Freeze power-up: adds [extra] to the current question's clock,
  /// capped at the question's full allotted time so it can't be stacked
  /// into an effectively unlimited clock.
  void addTime(Duration extra) {
    if (answered || isComplete) return;
    final next = timeRemaining + extra;
    timeRemaining = next > timeAllotted ? timeAllotted : next;
    notifyListeners();
  }

  void submitAnswer(Country selected) {
    if (answered || isComplete) return;
    _ticker?.cancel();
    final isCorrect = selected.cca3 == currentQuestion.correctAnswer.cca3;
    _applyAnswer(selected: selected, isCorrect: isCorrect);
  }

  void _applyAnswer({required Country? selected, required bool isCorrect}) {
    answered = true;
    selectedAnswer = selected;
    lastAnswerCorrect = isCorrect;

    if (isCorrect) {
      score += ScoreCalculator.pointsFor(
        difficulty: difficulty,
        comboBeforeThisAnswer: combo,
        timeRemaining: timeRemaining,
        timeAllotted: timeAllotted,
      );
      xpEarned += ScoreCalculator.xpFor(difficulty: difficulty);
      combo += 1;
      bestCombo = combo > bestCombo ? combo : bestCombo;
      correctCount += 1;
      correctCca3s.add(currentQuestion.correctAnswer.cca3);
    } else {
      combo = 0;
    }

    notifyListeners();

    _advanceTimer?.cancel();
    if (suddenDeath && !isCorrect) {
      _advanceTimer = Timer(feedbackDelay, _complete);
    } else {
      _advanceTimer = Timer(feedbackDelay, nextQuestion);
    }
  }

  /// Advances to the next question, or completes the session. Safe to
  /// call manually (e.g. a "Skip" tap) — cancels any pending auto-advance.
  void nextQuestion() {
    _advanceTimer?.cancel();
    if (isComplete) return;
    if (currentIndex + 1 >= questions.length) {
      _complete();
      return;
    }
    currentIndex += 1;
    answered = false;
    selectedAnswer = null;
    lastAnswerCorrect = null;
    _startQuestionTimer();
  }

  /// Questions actually reached — equal to [totalQuestions] (the fixed
  /// pool size) for a normal fixed-length session, since those only
  /// complete once every question has been reached. For a speed mode,
  /// [totalQuestions] is really just a large safety buffer (the session
  /// ends on sudden death or a global clock, not on exhausting the
  /// pool), so this is what accuracy and results should be measured
  /// against instead.
  int get _questionsAttempted => currentIndex + 1;

  void _complete() {
    if (isComplete) return;
    _ticker?.cancel();
    _advanceTimer?.cancel();
    _globalTicker?.cancel();
    _elapsedAtStop = _clockElapsed;
    _running = false;
    final accuracy = _questionsAttempted == 0
        ? 0.0
        : correctCount / _questionsAttempted;
    xpEarned += ScoreCalculator.completionBonusXp(
      difficulty: difficulty,
      accuracy: accuracy,
    );
    isComplete = true;
    notifyListeners();
  }

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

  /// Ends the session immediately, wherever the player currently is —
  /// results are built from whatever was reached, the same as running
  /// out the clock on the last question would.
  void surrender() => _complete();

  @override
  void dispose() {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    _globalTicker?.cancel();
    super.dispose();
  }
}
