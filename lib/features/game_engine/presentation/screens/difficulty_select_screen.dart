import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../domain/game_difficulty.dart';

/// Shared pre-game difficulty picker — every multiple-choice mode starts
/// here so Easy/Medium/Hard behave and look the same everywhere.
class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(GameDifficulty difficulty) onSelect;

  static Color _accentFor(GameDifficulty difficulty) => switch (difficulty) {
    GameDifficulty.easy => AppColors.difficultyEasy,
    GameDifficulty.medium => AppColors.difficultyMedium,
    GameDifficulty.hard => AppColors.difficultyHard,
  };

  static IconData _iconFor(GameDifficulty difficulty) => switch (difficulty) {
    GameDifficulty.easy => Icons.self_improvement,
    GameDifficulty.medium => Icons.trending_up,
    GameDifficulty.hard => Icons.local_fire_department,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppBackground(
        child: MaxWidthBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(icon, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 28),
                Text(
                  'Choose a difficulty',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                for (final difficulty in GameDifficulty.values) ...[
                  OptionTile(
                    title: difficulty.label,
                    subtitle:
                        '${difficulty.secondsPerQuestion}s per question · ${difficulty.basePoints} base pts',
                    icon: _iconFor(difficulty),
                    color: _accentFor(difficulty),
                    onTap: () => onSelect(difficulty),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
