import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/max_width_box.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MaxWidthBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 28),
              Text('Choose a difficulty', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              for (final difficulty in GameDifficulty.values) ...[
                _DifficultyTile(difficulty: difficulty, onTap: () => onSelect(difficulty)),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({required this.difficulty, required this.onTap});

  final GameDifficulty difficulty;
  final VoidCallback onTap;

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
    final accent = _accentFor(difficulty);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 5, height: 68, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_iconFor(difficulty), color: accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(difficulty.label, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            '${difficulty.secondsPerQuestion}s per question · ${difficulty.basePoints} base pts',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: accent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
