/// Shared difficulty tiers for every multiple-choice game mode.
///
/// Centralizing timing/scoring-weight per difficulty here is what lets
/// every mode (flag, emoji, and later capital/outline/etc.) share one
/// engine instead of each screen inventing its own numbers.
enum GameDifficulty {
  easy(label: 'Easy', secondsPerQuestion: 12, basePoints: 100, baseXp: 8),
  medium(label: 'Medium', secondsPerQuestion: 8, basePoints: 150, baseXp: 12),
  hard(label: 'Hard', secondsPerQuestion: 5, basePoints: 200, baseXp: 18);

  const GameDifficulty({
    required this.label,
    required this.secondsPerQuestion,
    required this.basePoints,
    required this.baseXp,
  });

  final String label;
  final int secondsPerQuestion;
  final int basePoints;
  final int baseXp;
}
