import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/chest_reward.dart';

/// The results screen's chest reveal — since nothing here can animate,
/// it renders already-open: an icon, a rarity label, and the real
/// contents as a short list (never a flat "+XP" number that hides what
/// actually happened). A tap on the info icon shows the real odds
/// behind every roll, so this reads as a fun bonus, never an opaque
/// gambling pattern.
class MysteryChestCard extends StatelessWidget {
  const MysteryChestCard({super.key, required this.reward});

  final ChestReward reward;

  static String rarityLabel(ChestRarity rarity) => switch (rarity) {
    ChestRarity.common => 'Common',
    ChestRarity.uncommon => 'Uncommon',
    ChestRarity.rare => 'Rare',
    ChestRarity.veryRare => 'Very Rare',
  };

  Color _rarityColor(BuildContext context, ChestRarity rarity) =>
      switch (rarity) {
        ChestRarity.common => Theme.of(context).colorScheme.onSurfaceVariant,
        ChestRarity.uncommon => AppColors.green,
        ChestRarity.rare => AppColors.purple,
        ChestRarity.veryRare => AppColors.yellow,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _rarityColor(context, reward.rarity);
    final lines = <String>[
      '+${reward.xp} XP',
      if (reward.bonusCoins > 0) '+${reward.bonusCoins} bonus coins',
      if (reward.unlockedTitle != null)
        'New title unlocked: ${reward.unlockedTitle}',
      if (reward.grantedStreakFreeze) '+1 Streak Freeze',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.card_giftcard_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${rarityLabel(reward.rarity)} Chest',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const ChestOddsDialog(),
                      ),
                      icon: const Icon(Icons.info_outline_rounded, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Drop rates',
                    ),
                  ],
                ),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('• $line', style: theme.textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The real weighted table behind every chest roll — see [chestOdds].
class ChestOddsDialog extends StatelessWidget {
  const ChestOddsDialog({super.key});

  static const _drops = {
    ChestRarity.common: 'XP only',
    ChestRarity.uncommon: 'XP + bonus coins',
    ChestRarity.rare: 'XP + a cosmetic title',
    ChestRarity.veryRare: 'XP + a free Streak Freeze',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Drop rates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rarity in ChestRarity.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${(chestOdds[rarity]! * 100).round()}% — '
                '${MysteryChestCard.rarityLabel(rarity)}: ${_drops[rarity]}',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
