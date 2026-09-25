import 'dart:math';

import 'package:confetti/confetti.dart';
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
/// This is the one moment that gets the confetti burst now — not every
/// correct answer, just the final "you made it" celebration.
class GameResultsView extends ConsumerStatefulWidget {
  const GameResultsView({
    super.key,
    required this.result,
    required this.onPlayAgain,
  });

  final GameResult result;
  final VoidCallback onPlayAgain;

  @override
  ConsumerState<GameResultsView> createState() => _GameResultsViewState();
}

class _GameResultsViewState extends ConsumerState<GameResultsView> {
  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 1200),
  )..play();

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final onPlayAgain = widget.onPlayAgain;
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

    return Stack(
      children: [
        SingleChildScrollView(
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
                  side: const BorderSide(
                    color: AppColors.oceanBlue,
                    width: 1.5,
                  ),
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 24,
            gravity: 0.5,
            emissionFrequency: 0.9,
            maxBlastForce: 20,
            minBlastForce: 8,
            colors: [
              theme.colorScheme.secondary,
              theme.colorScheme.primary,
              theme.colorScheme.tertiary,
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}
