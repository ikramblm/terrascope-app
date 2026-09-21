import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/player_providers.dart';

/// Shows how many Streak Freezes the player is holding and lets them
/// buy one more with coins — freezes are spent automatically the
/// moment a day is about to lapse (see
/// [PlayerProfileNotifier.recordSession]), never picked in the moment,
/// so this card is the only place they're managed.
class StreakFreezeCard extends ConsumerWidget {
  const StreakFreezeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final canAfford = profile.coins >= streakFreezeCoinCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.ac_unit_rounded,
                color: AppColors.skyBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak Freezes: ${profile.streakFreezesAvailable}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Protects one missed day automatically',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: canAfford
                  ? () => ref
                        .read(playerProfileProvider.notifier)
                        .buyStreakFreeze()
                  : null,
              child: Text('Buy · $streakFreezeCoinCost'),
            ),
          ],
        ),
      ),
    );
  }
}
