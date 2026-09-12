import 'dart:async';

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
  }) : timeRemaining = Duration(seconds: difficulty.secondsPerQuestion);

  final List<MultipleChoiceQuestion> questions;
  final GameDifficulty difficulty;

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
  final Stopwatch _stopwatch = Stopwatch();

  /// How long the correct/incorrect feedback stays on screen before
  /// auto-advancing to the next question.
  static const feedbackDelay = Duration(milliseconds: 1100);

  MultipleChoiceQuestion get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  Duration get timeAllotted => Duration(seconds: difficulty.secondsPerQuestion);

  void start() {
    _stopwatch.start();
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
    _applyAnswer(selected: null, isCorrect: false);
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
    _advanceTimer = Timer(feedbackDelay, nextQuestion);
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

  void _complete() {
    _ticker?.cancel();
    _stopwatch.stop();
    final accuracy = totalQuestions == 0 ? 0.0 : correctCount / totalQuestions;
    xpEarned += ScoreCalculator.completionBonusXp(difficulty: difficulty, accuracy: accuracy);
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
      elapsed: _stopwatch.elapsed,
      correctCca3s: correctCca3s,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }
}
