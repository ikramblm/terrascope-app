import 'package:flutter/material.dart';

import '../../../player/domain/player_profile.dart';

/// The top-of-Home summary of level, XP progress, and streak.
class PlayerStatBar extends StatelessWidget {
  const PlayerStatBar({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = profile.level.next;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.military_tech_outlined, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
                _StreakBadge(days: profile.currentStreakDays),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: profile.levelProgress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: theme.colorScheme.tertiary),
          const SizedBox(width: 4),
          Text('$days', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.tertiary)),
        ],
      ),
    );
  }
}
