import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../player/domain/achievement.dart';
import '../../../player/domain/player_profile.dart';
import '../../../player/presentation/widgets/achievement_badge.dart';
import '../../../player/providers/player_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final theme = Theme.of(context);
    final unlockedCount = kAchievements
        .where((a) => a.isUnlockedFor(profile))
        .length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text('Profile', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Your progress, your stats, your badges.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(index: 0, child: _IdentityCard(profile: profile)),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 1,
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 128,
                          ),
                      children: [
                        StatCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Best Streak',
                          value: '${profile.longestStreakDays}',
                          color: AppColors.orange,
                        ),
                        StatCard(
                          icon: Icons.public_rounded,
                          label: 'Countries',
                          value: '${profile.countriesDiscovered} / 195',
                          color: AppColors.oceanBlue,
                        ),
                        StatCard(
                          icon: Icons.stars_rounded,
                          label: 'Best Score',
                          value: '${profile.bestScore}',
                          color: AppColors.yellow,
                        ),
                        StatCard(
                          icon: Icons.sports_esports_rounded,
                          label: 'Games Played',
                          value: '${profile.gamesPlayed}',
                          color: AppColors.purple,
                        ),
                        StatCard(
                          icon: Icons.track_changes_rounded,
                          label: 'Accuracy',
                          value: profile.totalQuestionsAnswered == 0
                              ? '—'
                              : '${(profile.overallAccuracy * 100).round()}%',
                          color: AppColors.coral,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    index: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Achievements',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          '$unlockedCount / ${kAchievements.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    index: 3,
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 164,
                          ),
                      children: [
                        for (final achievement in kAchievements)
                          AchievementBadgeTile(
                            achievement: achievement,
                            unlocked: achievement.isUnlockedFor(profile),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = profile.level.next;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.oceanBlue,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest Explorer', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        profile.level.label,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: profile.levelProgress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              next == null
                  ? '${profile.totalXp} XP · max level'
                  : '${profile.totalXp} / ${next.minXp} XP to ${next.label}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
