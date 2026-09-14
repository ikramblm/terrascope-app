import 'package:flutter/material.dart';

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
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(mode.icon, color: accent, size: 20),
                    ),
                    if (!available)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: theme.colorScheme.outline),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
