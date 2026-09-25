import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../games/data/quick_play.dart';
import '../../../player/presentation/widgets/mystery_chest_card.dart';
import '../../../player/providers/player_providers.dart';
import '../../presentation/widgets/personal_best_badge.dart';
import '../../presentation/widgets/victory_banner.dart';
import '../../presentation/widgets/xp_progress_bar.dart';
import '../name_engine.dart';

/// Shared end-of-session summary for every "name as many as you can"
/// mode — same visual language as [GameResultsView] (the multiple-choice
/// results screen), just with stats that make sense for this mechanic
/// (no wrong answers, just countries found or not — "accuracy" here is
/// really completeness: how much of the pool got found).
class NameResultsView extends ConsumerWidget {
  const NameResultsView({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  final NameEngine engine;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final chestReward = ref
        .read(playerProfileProvider.notifier)
        .lastChestReward;
    final result = engine.buildResult();
    final completedAll = engine.foundCount == engine.totalCount;
    final isNewBest =
        result.totalScore > 0 && result.totalScore == profile.bestScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          VictoryBanner(
            title: completedAll ? 'ALL FOUND' : 'NICE RUN',
            accuracy: result.accuracy,
          ),
          const SizedBox(height: 12),
          Text(
            '${engine.foundCount} / ${engine.totalCount} countries found',
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
                label: 'Found',
                value: '${engine.foundCount}',
                icon: Icons.public_rounded,
                color: AppColors.oceanBlue,
              ),
              StatCard(
                label: 'Score',
                value: '${result.totalScore}',
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
          ElevatedButton(
            onPressed: () => launchQuickPlay(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Try Another'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.oceanBlue,
              side: const BorderSide(color: AppColors.oceanBlue, width: 1.5),
              minimumSize: const Size.fromHeight(56),
            ),
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
