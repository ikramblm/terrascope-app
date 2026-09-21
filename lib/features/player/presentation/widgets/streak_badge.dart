import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../providers/player_providers.dart';

/// The persistent daily-streak indicator — a small glowing flame badge
/// pinned in the corner of every top-level tab, so the streak is always
/// visible without hunting for it on the Profile screen. Hidden at
/// streak 0 (a new player has nothing to protect yet, so there's
/// nothing honest to show).
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(
      playerProfileProvider.select((p) => p.currentStreakDays),
    );
    if (streak <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.orange,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
