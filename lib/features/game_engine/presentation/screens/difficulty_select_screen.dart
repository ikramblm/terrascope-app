import 'package:flutter/material.dart';

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
      body: Padding(
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
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({required this.difficulty, required this.onTap});

  final GameDifficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
