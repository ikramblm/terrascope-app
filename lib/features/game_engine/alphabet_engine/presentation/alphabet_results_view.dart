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
import '../alphabet_engine.dart';

/// End-of-session summary for Name the Alphabet — same visual language
/// as every other results screen ([GameResultsView], [NameResultsView]).
class AlphabetResultsView extends ConsumerWidget {
  const AlphabetResultsView({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  final AlphabetEngine engine;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final chestReward = ref
        .read(playerProfileProvider.notifier)
        .lastChestReward;
    final result = engine.buildResult();
    final completedAll = engine.correctCount == engine.totalLetters;
    final isNewBest =
        result.totalScore > 0 && result.totalScore == profile.bestScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          VictoryBanner(
            title: completedAll ? 'A TO Z CLEAR' : 'ROUND COMPLETE',
            accuracy: result.accuracy,
          ),
          const SizedBox(height: 12),
          Text(
            '${engine.correctCount} / ${engine.totalLetters} letters named',
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
                label: 'Named',
                value: '${engine.correctCount}',
                icon: Icons.sort_by_alpha_rounded,
                color: AppColors.oceanBlue,
              ),
              StatCard(
                label: 'Skipped',
                value: '${engine.skippedCount}',
                icon: Icons.skip_next_rounded,
                color: AppColors.coral,
              ),
              StatCard(
                label: 'Score',
                value: '${result.totalScore}',
                icon: Icons.stars_rounded,
                color: AppColors.yellow,
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
}
