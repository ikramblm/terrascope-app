import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../games/data/quick_play.dart';
import '../name_engine.dart';

/// Shared end-of-session summary for every "name as many as you can"
/// mode — same visual language as [GameResultsView] (the multiple-choice
/// results screen), just with stats that make sense for this mechanic
/// (no accuracy/combo — there's no wrong answer to be inaccurate about,
/// just countries found or not).
class NameResultsView extends StatelessWidget {
  const NameResultsView({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  final NameEngine engine;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedAll = engine.foundCount == engine.totalCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Icon(
            completedAll ? Icons.emoji_events : Icons.flag_circle_outlined,
            size: 56,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          Text(
            completedAll ? 'All Found!' : 'Nice Run!',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '${engine.foundCount} / ${engine.totalCount} countries found',
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
                  label: 'Found',
                  value: '${engine.foundCount}',
                  icon: Icons.public_rounded,
                  color: AppColors.oceanBlue,
                ),
                StatCard(
                  label: 'XP Earned',
                  value: '+${engine.buildResult().xpEarned}',
                  icon: Icons.bolt,
                  color: AppColors.green,
                ),
                StatCard(
                  label: 'Score',
                  value: '${engine.buildResult().totalScore}',
                  icon: Icons.stars_rounded,
                  color: AppColors.yellow,
                ),
                StatCard(
                  label: 'Time',
                  value: _formatDuration(engine.elapsed),
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
