import 'package:flutter/material.dart';

import '../../domain/game_mode.dart';

/// A single game mode tile in the catalog grid — a large solid-color
/// square, a white icon, the game's name. Nothing else: no tagline, no
/// stats, no decoration competing with the color and the icon for
/// attention.
///
/// Unavailable modes render visibly muted with a padlock icon and a
/// "Soon" badge — never a tile that looks tappable but silently does
/// nothing, and never a fabricated unlock condition either (these modes
/// simply aren't built yet, not gated behind a player level).
class GameModeCard extends StatelessWidget {
  const GameModeCard({
    super.key,
    required this.mode,
    required this.color,
    this.onTap,
  });

  final GameMode mode;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = mode.isAvailable;
    final background = available
        ? color
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = available
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(28),
            boxShadow: available
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (!available)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text('Soon', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: foreground.withValues(
                        alpha: available ? 0.25 : 0.12,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: !available
                        ? Icon(Icons.lock_rounded, color: foreground, size: 20)
                        : mode.logoBuilder != null
                        ? mode.logoBuilder!(context)
                        : Icon(mode.icon, color: foreground, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mode.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
