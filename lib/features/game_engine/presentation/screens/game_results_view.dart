import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../games/data/quick_play.dart';
import '../../../player/presentation/widgets/mystery_chest_card.dart';
import '../../../player/providers/player_providers.dart';
import '../../domain/game_result.dart';
import '../widgets/personal_best_badge.dart';
import '../widgets/victory_banner.dart';
import '../widgets/xp_progress_bar.dart';

/// Shared end-of-game summary — every multiple-choice mode ends here.
class GameResultsView extends ConsumerWidget {
  const GameResultsView({
    super.key,
    required this.result,
    required this.onPlayAgain,
  });

  final GameResult result;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final chestReward = ref
        .read(playerProfileProvider.notifier)
        .lastChestReward;
    final accuracyPct = (result.accuracy * 100).round();
    // recordSession already ran (onSessionComplete fires before this view
    // builds), so bestScore already reflects this result if it set one.
    final isNewBest =
        result.totalScore > 0 && result.totalScore == profile.bestScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          VictoryBanner(title: 'VICTORY', accuracy: result.accuracy),
          const SizedBox(height: 12),
          Text(
            '${result.correctCount} / ${result.totalQuestions} correct · $accuracyPct% accuracy',
            style: theme.textTheme.bodyMedium,
          ),
          if (isNewBest) ...[
            const SizedBox(height: 12),
            const PersonalBestBadge(),
          ],
          const SizedBox(height: 20),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
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
          if (chestReward != null) ...[
            const SizedBox(height: 12),
            MysteryChestCard(reward: chestReward),
          ],
          const SizedBox(height: 16),
          XpProgressBar(profile: profile),
          const SizedBox(height: 20),
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
