import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../games/data/quick_play.dart';
import '../name_engine.dart';

/// Shared end-of-session summary for every "name as many as you can"
/// mode — same visual language as [GameResultsView] (the multiple-choice
/// results screen), just with stats that make sense for this mechanic
/// (no accuracy/combo — there's no wrong answer to be inaccurate about,
/// just countries found or not).
class NameResultsView extends StatelessWidget {
  const NameResultsView({super.key, required this.engine, required this.onPlayAgain});

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
          Text(completedAll ? 'All Found!' : 'Nice Run!', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '${engine.foundCount} / ${engine.totalCount} countries found',
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
                _StatCard(
                  label: 'Found',
                  value: '${engine.foundCount}',
                  icon: Icons.public_rounded,
                  accent: AppColors.oceanBlue,
                ),
                _StatCard(
                  label: 'XP Earned',
                  value: '+${engine.buildResult().xpEarned}',
                  icon: Icons.bolt,
                  accent: AppColors.green,
                ),
                _StatCard(
                  label: 'Score',
                  value: '${engine.buildResult().totalScore}',
                  icon: Icons.stars_rounded,
                  accent: AppColors.yellow,
                ),
                _StatCard(
                  label: 'Time',
                  value: _formatDuration(engine.elapsed),
                  icon: Icons.timer_outlined,
                  accent: AppColors.purple,
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
            onPressed: () => launchQuickPlay(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.accent});

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
