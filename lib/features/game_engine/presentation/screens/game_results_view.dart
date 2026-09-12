import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/game_result.dart';

/// Shared end-of-game summary — every multiple-choice mode ends here.
class GameResultsView extends StatelessWidget {
  const GameResultsView({super.key, required this.result, required this.onPlayAgain});

  final GameResult result;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyPct = (result.accuracy * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Icon(
            result.accuracy >= 0.7 ? Icons.emoji_events : Icons.flag_circle_outlined,
            size: 56,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Text('Game Complete', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '${result.correctCount} / ${result.totalQuestions} correct · $accuracyPct% accuracy',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard(label: 'Score', value: '${result.totalScore}', icon: Icons.stars_rounded),
                _StatCard(label: 'XP Earned', value: '+${result.xpEarned}', icon: Icons.bolt),
                _StatCard(label: 'Best Combo', value: '${result.bestCombo}x', icon: Icons.local_fire_department),
                _StatCard(
                  label: 'Time',
                  value: _formatDuration(result.elapsed),
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onPlayAgain,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go('/games'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
