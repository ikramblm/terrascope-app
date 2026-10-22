import 'package:flutter/material.dart';

/// A large, bold, single-color game-mode button — the entire home
/// screen's action list is built from these. One flat color per mode,
/// a white icon, a short name: nothing else competing for attention.
class GameModeButton extends StatelessWidget {
  const GameModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.logoBuilder,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  /// An optional bespoke visual (a flag, a colored outline, a themed
  /// emoji) shown instead of [icon] — see [GameMode.logoBuilder].
  final Widget Function(BuildContext context)? logoBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    logoBuilder?.call(context) ??
                    Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
