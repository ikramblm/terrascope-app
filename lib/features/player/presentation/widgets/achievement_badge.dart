import 'package:flutter/material.dart';

import '../../domain/achievement.dart';

/// One collectible badge — full color icon when unlocked, grayed and
/// dimmed when not, with a small lock icon. Never hides *what* the
/// achievement is, only celebrates having earned it.
class AchievementBadgeTile extends StatelessWidget {
  const AchievementBadgeTile({super.key, required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = unlocked ? achievement.color : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? achievement.color.withValues(alpha: 0.10) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked ? achievement.color.withValues(alpha: 0.16) : theme.colorScheme.surface,
                ),
                alignment: Alignment.center,
                child: Icon(
                  achievement.icon,
                  size: 26,
                  color: unlocked ? achievement.color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              if (!unlocked)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surface),
                    child: Icon(Icons.lock_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: unlocked ? theme.colorScheme.onSurface : color),
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
