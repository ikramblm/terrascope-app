import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../games/data/quick_play.dart';
import '../alphabet_engine.dart';

/// End-of-session summary for Name the Alphabet — same visual language
/// as every other results screen ([GameResultsView], [NameResultsView]).
class AlphabetResultsView extends StatelessWidget {
  const AlphabetResultsView({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  final AlphabetEngine engine;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedAll = engine.correctCount == engine.totalLetters;

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
          Text('Alphabet Complete', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '${engine.correctCount} / ${engine.totalLetters} letters named',
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
                  label: 'Named',
                  value: '${engine.correctCount}',
                  icon: Icons.sort_by_alpha_rounded,
                  color: AppColors.oceanBlue,
                ),
                StatCard(
                  label: 'XP Earned',
                  value: '+${engine.buildResult().xpEarned}',
                  icon: Icons.bolt,
                  color: AppColors.green,
                ),
                StatCard(
                  label: 'Skipped',
                  value: '${engine.skippedCount}',
                  icon: Icons.skip_next_rounded,
                  color: AppColors.coral,
                ),
                StatCard(
                  label: 'Score',
                  value: '${engine.buildResult().totalScore}',
                  icon: Icons.stars_rounded,
                  color: AppColors.yellow,
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
}
