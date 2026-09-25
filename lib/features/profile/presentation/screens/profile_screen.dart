import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../player/domain/achievement.dart';
import '../../../player/domain/player_level.dart';
import '../../../player/domain/player_profile.dart';
import '../../../player/domain/prestige_title.dart';
import '../../../player/presentation/widgets/achievement_badge.dart';
import '../../../player/presentation/widgets/duel_entry_card.dart';
import '../../../player/presentation/widgets/passport_map.dart';
import '../../../player/presentation/widgets/sound_toggle_card.dart';
import '../../../player/presentation/widgets/streak_freeze_card.dart';
import '../../../player/providers/player_providers.dart';

/// One color per [PlayerLevel] tier, escalating toward gold at the top
/// rank — the frame around the avatar in [_IdentityCard] uses this so a
/// player's status reads at a glance, not just from the text label.
Color colorForLevel(PlayerLevel level) => switch (level) {
  PlayerLevel.beginner => const Color(0xFF9CA3AF),
  PlayerLevel.explorer => AppColors.skyBlue,
  PlayerLevel.traveler => AppColors.oceanBlue,
  PlayerLevel.geographer => AppColors.green,
  PlayerLevel.cartographer => AppColors.orange,
  PlayerLevel.worldExpert => AppColors.coral,
  PlayerLevel.worldMaster => AppColors.yellow,
};

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
      body: AppBackground(
        child: SafeArea(
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
                    FadeSlideIn(
                      index: 0,
                      child: _IdentityCard(profile: profile),
                    ),
                    const SizedBox(height: 12),
                    const FadeSlideIn(index: 1, child: StreakFreezeCard()),
                    const SizedBox(height: 12),
                    const FadeSlideIn(index: 2, child: DuelEntryCard()),
                    const SizedBox(height: 12),
                    const FadeSlideIn(index: 3, child: SoundToggleCard()),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      index: 4,
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
                            icon: Icons.monetization_on_rounded,
                            label: 'Coins',
                            value: '${profile.coins}',
                            color: AppColors.ctaCyan,
                          ),
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
                          StatCard(
                            icon: Icons.workspace_premium_rounded,
                            label: 'Bonus Titles',
                            value: '${profile.unlockedCosmeticTitles.length}',
                            color: AppColors.purple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      index: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'World Coverage',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                            '${profile.countriesDiscovered} / 195',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      index: 6,
                      child: PassportMap(
                        discoveredCca3s: profile.discoveredCountryCodes,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      index: 7,
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
                      index: 8,
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
      ),
    );
  }
}

class _IdentityCard extends ConsumerWidget {
  const _IdentityCard({required this.profile});

  final PlayerProfile profile;

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: profile.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) => Navigator.of(context).pop(value),
          decoration: const InputDecoration(hintText: 'Guest Explorer'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null) {
      ref.read(playerProfileProvider.notifier).setDisplayName(newName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorForLevel(profile.level),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.oceanBlue,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _editName(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.displayName,
                                  style: theme.textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level ${profile.numericLevel} · '
                            '${PrestigeTitle.forLevel(profile.numericLevel)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
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
