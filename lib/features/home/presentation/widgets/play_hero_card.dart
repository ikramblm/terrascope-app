import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/globe_grid.dart';

/// Home screen's single bold color block: the primary "Play" call to
/// action. Everything else on Home stays light and quiet on purpose so
/// this card is unmistakably where the eye — and the thumb — goes.
class PlayHeroCard extends StatelessWidget {
  const PlayHeroCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(24, 24, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.oceanBlue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: AppColors.oceanBlue.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: -20,
                right: -10,
                child: GlobeGrid(size: 96, color: Colors.white.withValues(alpha: 0.16)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to explore?',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Play a quick round now',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Icon(Icons.play_arrow_rounded, color: AppColors.oceanBlue, size: 32),
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
