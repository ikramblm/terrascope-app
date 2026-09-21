import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/features/player/domain/chest_reward.dart';

/// A [Random] stand-in that always returns the same fixed value, so a
/// roll's rarity tier is deterministic instead of actually random —
/// the only way to test each tier's contents reliably.
class _FixedRandom implements Random {
  _FixedRandom(this._value);
  final double _value;

  @override
  double nextDouble() => _value;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

void main() {
  group('ChestReward.roll', () {
    test('a low roll lands Common: XP only, no bonuses', () {
      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: {},
        random: _FixedRandom(0.0),
      );

      expect(reward.rarity, ChestRarity.common);
      expect(reward.xp, 100);
      expect(reward.bonusCoins, 0);
      expect(reward.unlockedTitle, isNull);
      expect(reward.grantedStreakFreeze, isFalse);
    });

    test('a roll just past 70% lands Uncommon: XP + bonus coins', () {
      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: {},
        random: _FixedRandom(0.71),
      );

      expect(reward.rarity, ChestRarity.uncommon);
      expect(reward.bonusCoins, chestBonusCoins);
      expect(reward.unlockedTitle, isNull);
    });

    test('a roll just past 90% lands Rare: unlocks an unowned title', () {
      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: {},
        random: _FixedRandom(0.91),
      );

      expect(reward.rarity, ChestRarity.rare);
      expect(reward.unlockedTitle, isNotNull);
      expect(cosmeticTitlePool, contains(reward.unlockedTitle));
      expect(reward.bonusCoins, 0);
    });

    test('a Rare roll never repeats an already-owned title', () {
      final almostAllOwned = cosmeticTitlePool
          .skip(1)
          .toSet(); // every title owned except the first

      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: almostAllOwned,
        random: _FixedRandom(0.91),
      );

      expect(reward.unlockedTitle, cosmeticTitlePool.first);
    });

    test('a Rare roll falls back to coins once every title is owned', () {
      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: cosmeticTitlePool.toSet(),
        random: _FixedRandom(0.91),
      );

      expect(reward.rarity, ChestRarity.rare);
      expect(reward.unlockedTitle, isNull);
      expect(reward.bonusCoins, chestBonusCoins);
    });

    test('a roll just past 98% lands Very Rare: a free Streak Freeze', () {
      final reward = ChestReward.roll(
        xpEarned: 100,
        ownedTitles: {},
        random: _FixedRandom(0.99),
      );

      expect(reward.rarity, ChestRarity.veryRare);
      expect(reward.grantedStreakFreeze, isTrue);
    });

    test('the published odds sum to exactly 100%', () {
      final total = chestOdds.values.fold<double>(0, (a, b) => a + b);
      expect(total, closeTo(1.0, 0.0001));
    });
  });
}
