import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/game_mode.dart';
import 'game_category_style.dart';

/// A single game mode tile in the catalog grid.
///
/// Unavailable modes render visibly disabled with a "Coming soon" badge —
/// never a button that looks tappable but silently does nothing.
class GameModeCard extends StatelessWidget {
  const GameModeCard({super.key, required this.mode, this.onTap});

  final GameMode mode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = mode.isAvailable;
    final accent = accentForCategory(mode.category);

    return Opacity(
      opacity: available ? 1 : 0.55,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: available ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(mode.icon, color: accent, size: 20),
                    ),
                    if (!available)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('Soon', style: theme.textTheme.labelSmall),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(mode.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  mode.tagline,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (available) _DifficultyDots(accent: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Every mode offers all three difficulties — this isn't a fixed rating,
/// just a quiet visual reminder that Easy/Medium/Hard are all there.
class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    const colors = [AppColors.difficultyEasy, AppColors.difficultyMedium, AppColors.difficultyHard];
    return Row(
      children: [
        for (final c in colors) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c),
          ),
          const SizedBox(width: 4),
        ],
      ],
    );
  }
}
