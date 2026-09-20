import 'package:flutter/material.dart';

/// A solid-color, tappable row tile — the same visual language as the
/// Explore grid and Home's mode buttons, used wherever the app asks the
/// player to pick one option from a short list (difficulty, continent,
/// category, letter). A disabled tile (nothing to pick, e.g. an empty
/// pool) renders muted with no color, matching [GameModeCard]'s
/// unavailable state — never a tile that looks tappable but does
/// nothing.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    final background = enabled
        ? color
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = enabled
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: enabled ? 0.25 : 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: foreground, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? foreground.withValues(alpha: 0.85)
                            : foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled
                    ? foreground.withValues(alpha: 0.85)
                    : foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
