import 'package:flutter/foundation.dart';

/// Final summary of one completed game session — shared shape every mode's
/// results screen renders, regardless of which mode produced it.
@immutable
class GameResult {
  const GameResult({
    required this.totalScore,
    required this.xpEarned,
    required this.correctCount,
    required this.totalQuestions,
    required this.bestCombo,
    required this.elapsed,
    required this.correctCca3s,
  });

  final int totalScore;
  final int xpEarned;
  final int correctCount;
  final int totalQuestions;
  final int bestCombo;
  final Duration elapsed;

  /// cca3 codes answered correctly — feeds "countries discovered".
  final Set<String> correctCca3s;

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;
}
