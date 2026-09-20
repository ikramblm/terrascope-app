import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../games/data/quick_play.dart';
import '../../domain/game_result.dart';

/// Shared end-of-game summary — every multiple-choice mode ends here.
class GameResultsView extends StatelessWidget {
  const GameResultsView({
    super.key,
    required this.result,
    required this.onPlayAgain,
  });

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
            result.accuracy >= 0.7
                ? Icons.emoji_events
                : Icons.flag_circle_outlined,
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
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 128,
              ),
              children: [
                StatCard(
                  label: 'Score',
                  value: '${result.totalScore}',
                  icon: Icons.stars_rounded,
                  color: AppColors.skyBlue,
                ),
                StatCard(
                  label: 'XP Earned',
                  value: '+${result.xpEarned}',
                  icon: Icons.bolt,
                  color: AppColors.green,
                ),
                StatCard(
                  label: 'Best Combo',
                  value: '${result.bestCombo}x',
                  icon: Icons.local_fire_department,
                  color: AppColors.orange,
                ),
                StatCard(
                  label: 'Time',
                  value: _formatDuration(result.elapsed),
                  icon: Icons.timer_outlined,
                  color: AppColors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onPlayAgain,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => launchQuickPlay(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Try Another'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => context.go(RoutePaths.home),
            child: const Text('Home'),
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
