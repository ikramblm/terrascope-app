/// TerraScope's player progression tiers.
///
/// Deliberately few, deliberately named like ranks in a competitive game
/// rather than school grades — see spec section on progression.
enum PlayerLevel {
  beginner('Beginner', 0),
  explorer('Explorer', 500),
  traveler('Traveler', 1500),
  geographer('Geographer', 3500),
  cartographer('Cartographer', 7000),
  worldExpert('World Expert', 13000),
  worldMaster('World Master', 22000);

  const PlayerLevel(this.label, this.minXp);

  final String label;

  /// Total career XP required to enter this level.
  final int minXp;

  static PlayerLevel forXp(int totalXp) {
    PlayerLevel current = PlayerLevel.beginner;
    for (final level in PlayerLevel.values) {
      if (totalXp >= level.minXp) {
        current = level;
      }
    }
    return current;
  }

  PlayerLevel? get next {
    final index = PlayerLevel.values.indexOf(this);
    if (index + 1 >= PlayerLevel.values.length) return null;
    return PlayerLevel.values[index + 1];
  }
}
