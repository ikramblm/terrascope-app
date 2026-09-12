import '../domain/game_difficulty.dart';

/// Turns (difficulty, remaining time, current combo) into points/XP for
/// one correct answer. The one place this math lives, shared by every
/// mode that uses [MultipleChoiceEngine].
abstract class ScoreCalculator {
  ScoreCalculator._();

  /// Combo multiplier caps at 2.0x (combo 10+): +10% per consecutive
  /// correct answer.
  static double comboMultiplier(int comboBeforeThisAnswer) {
    final steps = comboBeforeThisAnswer.clamp(0, 10);
    return 1.0 + (steps * 0.1);
  }

  static int pointsFor({
    required GameDifficulty difficulty,
    required int comboBeforeThisAnswer,
    required Duration timeRemaining,
    required Duration timeAllotted,
  }) {
    final base = difficulty.basePoints;
    final multiplier = comboMultiplier(comboBeforeThisAnswer);

    final timeFraction = timeAllotted.inMilliseconds == 0
        ? 0.0
        : (timeRemaining.inMilliseconds / timeAllotted.inMilliseconds).clamp(0.0, 1.0);
    final timeBonus = (base * 0.5 * timeFraction);

    return ((base + timeBonus) * multiplier).round();
  }

  static int xpFor({required GameDifficulty difficulty}) => difficulty.baseXp;

  /// Flat bonus XP awarded once, on game completion, scaled by accuracy.
  static int completionBonusXp({
    required GameDifficulty difficulty,
    required double accuracy,
  }) {
    return (difficulty.baseXp * 5 * accuracy).round();
  }
}
