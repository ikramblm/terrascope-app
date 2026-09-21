import 'dart:math';

/// How rare this session's chest roll was — drives both the reward
/// contents and the reveal card's color.
enum ChestRarity { common, uncommon, rare, veryRare }

/// The real odds behind every chest roll, exposed so the UI can show
/// them verbatim rather than claiming a number nobody can check — see
/// [ChestReward.roll].
const Map<ChestRarity, double> chestOdds = {
  ChestRarity.common: 0.70,
  ChestRarity.uncommon: 0.20,
  ChestRarity.rare: 0.08,
  ChestRarity.veryRare: 0.02,
};

/// A pool of flavor titles a Rare roll can unlock — separate from
/// [PrestigeTitle]'s level-driven ladder; these are pure bonus cosmetics
/// with no numeric-level requirement behind them.
const List<String> cosmeticTitlePool = [
  'Stargazer',
  'Windrunner',
  'Lighthouse Keeper',
  'Cloud Chaser',
  'Deep Diver',
  'Summit Seeker',
  'Horizon Chaser',
  'Compass Bearer',
];

const int chestBonusCoins = 10;

/// One session's end-of-round chest — always carries the session's real
/// XP, plus whatever the roll added on top. Every field here reflects a
/// change [PlayerProfileNotifier.recordSession] actually applied, never
/// a cosmetic-only claim.
class ChestReward {
  const ChestReward({
    required this.rarity,
    required this.xp,
    this.bonusCoins = 0,
    this.unlockedTitle,
    this.grantedStreakFreeze = false,
  });

  final ChestRarity rarity;
  final int xp;
  final int bonusCoins;

  /// Non-null only on a Rare roll that unlocked a title this player
  /// didn't already have — null (falling back to a coin bonus instead)
  /// once the whole [cosmeticTitlePool] is owned, so the roll is never
  /// a silent no-op.
  final String? unlockedTitle;
  final bool grantedStreakFreeze;

  /// Rolls one chest for [xpEarned] XP against the real [chestOdds],
  /// picking an unowned title from [cosmeticTitlePool] for a Rare roll
  /// (falling back to bonus coins once every title is owned).
  factory ChestReward.roll({
    required int xpEarned,
    required Set<String> ownedTitles,
    Random? random,
  }) {
    final rng = random ?? Random();
    final roll = rng.nextDouble();
    var cumulative = 0.0;
    var rarity = ChestRarity.common;
    for (final entry in chestOdds.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        rarity = entry.key;
        break;
      }
    }

    switch (rarity) {
      case ChestRarity.common:
        return ChestReward(rarity: rarity, xp: xpEarned);
      case ChestRarity.uncommon:
        return ChestReward(
          rarity: rarity,
          xp: xpEarned,
          bonusCoins: chestBonusCoins,
        );
      case ChestRarity.rare:
        final unowned = cosmeticTitlePool
            .where((t) => !ownedTitles.contains(t))
            .toList();
        if (unowned.isEmpty) {
          return ChestReward(
            rarity: rarity,
            xp: xpEarned,
            bonusCoins: chestBonusCoins,
          );
        }
        return ChestReward(
          rarity: rarity,
          xp: xpEarned,
          unlockedTitle: unowned[rng.nextInt(unowned.length)],
        );
      case ChestRarity.veryRare:
        return ChestReward(
          rarity: rarity,
          xp: xpEarned,
          grantedStreakFreeze: true,
        );
    }
  }
}
