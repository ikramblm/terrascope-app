import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../player/domain/player_profile.dart';

/// A static "here's exactly where you stand" readout — current level,
/// a pre-filled progress bar (already showing the XP this session just
/// earned, not animating up to it), and the numeric target for the next
/// tier. Gives the player a concrete number to chase on the next round.
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = profile.level.next;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(profile.level.label, style: theme.textTheme.titleMedium),
              Text(
                next == null
                    ? '${profile.totalXp} XP · max level'
                    : '${profile.totalXp} / ${next.minXp} XP',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: profile.levelProgress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface,
              color: AppColors.green,
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: 6),
            Text(
              '${next.minXp - profile.totalXp} XP to ${next.label}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
