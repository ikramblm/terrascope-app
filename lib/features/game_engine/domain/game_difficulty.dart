/// Shared difficulty tiers for every multiple-choice game mode.
///
/// Centralizing timing/scoring-weight per difficulty here is what lets
/// every mode (flag, emoji, and later capital/outline/etc.) share one
/// engine instead of each screen inventing its own numbers.
///
/// In the Easy/Medium/Hard pickers the level chooses *which countries*
/// appear (see `CountryDifficulty`), not how fast the clock runs.
/// [secondsPerQuestion] is only the clock for modes that use a fixed
/// level on purpose (the speed runs use Hard's short 5s clock).
enum GameDifficulty {
  easy(
    label: 'Easy',
    description: 'Famous countries',
    secondsPerQuestion: 12,
    basePoints: 100,
    baseXp: 8,
  ),
  medium(
    label: 'Medium',
    description: 'Less familiar countries',
    secondsPerQuestion: 8,
    basePoints: 150,
    baseXp: 12,
  ),
  hard(
    label: 'Hard',
    description: 'Obscure, hard-to-guess countries',
    secondsPerQuestion: 5,
    basePoints: 200,
    baseXp: 18,
  );

  const GameDifficulty({
    required this.label,
    required this.description,
    required this.secondsPerQuestion,
    required this.basePoints,
    required this.baseXp,
  });

  final String label;
  final String description;
  final int secondsPerQuestion;
  final int basePoints;
  final int baseXp;
}
