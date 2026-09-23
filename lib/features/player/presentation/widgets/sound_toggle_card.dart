import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/player_providers.dart';

/// The one place sound gets muted — flips
/// [PlayerProfileNotifier.setSoundEnabled], which keeps the persisted
/// preference and [SoundService]'s live flag in sync together.
class SoundToggleCard extends ConsumerWidget {
  const SoundToggleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(
      playerProfileProvider.select((p) => p.soundEnabled),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: AppColors.purple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sound Effects', style: theme.textTheme.titleMedium),
                  Text(
                    enabled ? 'Taps and game sounds on' : 'Muted',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) => ref
                  .read(playerProfileProvider.notifier)
                  .setSoundEnabled(value),
            ),
          ],
        ),
      ),
    );
  }
}
