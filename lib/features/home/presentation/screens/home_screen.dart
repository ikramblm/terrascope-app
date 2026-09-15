import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../data/countries/providers/country_providers.dart';
import '../../../games/data/game_catalog.dart';
import '../../../games/data/quick_play.dart';
import '../../../games/presentation/widgets/game_mode_card.dart';
import '../../../player/providers/player_providers.dart';
import '../widgets/greeting_header.dart';
import '../widgets/play_hero_card.dart';
import '../widgets/player_stat_bar.dart';
import '../widgets/section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final countriesAsync = ref.watch(allCountriesProvider);
    final featuredModes = kGameCatalog.where((m) => m.isAvailable).take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            FadeSlideIn(
              index: 0,
              child: GreetingHeader(
                levelLabel: '${profile.level.label} · ${profile.totalXp} XP',
                onSettingsTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings are coming soon')),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(index: 1, child: PlayerStatBar(profile: profile)),
            const SizedBox(height: 16),
            FadeSlideIn(index: 2, child: PlayHeroCard(onTap: () => launchQuickPlay(context))),
            const SizedBox(height: 28),
            FadeSlideIn(
              index: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Game Modes', style: theme.textTheme.headlineMedium),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.games),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            FadeSlideIn(
              index: 4,
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 152,
                ),
                children: [
                  for (final mode in featuredModes)
                    GameModeCard(mode: mode, onTap: () => context.push(mode.routePath!)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              index: 5,
              child: SectionCard(
                icon: Icons.today_rounded,
                title: 'Daily Challenge',
                subtitle: 'Arrives soon — same challenge for every player, every day.',
                accentColor: theme.colorScheme.tertiary,
                trailing: _ComingSoonChip(),
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              index: 6,
              child: countriesAsync.when(
                data: (countries) => SectionCard(
                  icon: Icons.public_rounded,
                  title: 'World Database Ready',
                  subtitle: '${countries.length} countries loaded — browse every game mode',
                  accentColor: theme.colorScheme.secondary,
                  onTap: () => context.go(RoutePaths.games),
                  trailing: const Icon(Icons.chevron_right),
                ),
                loading: () => const SectionCard(
                  icon: Icons.public_rounded,
                  title: 'Loading world database…',
                  subtitle: 'Preparing 195 countries',
                ),
                error: (err, st) => SectionCard(
                  icon: Icons.error_outline,
                  title: 'Could not load country data',
                  subtitle: '$err',
                  accentColor: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Recent Scores', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.history,
                  title: 'No games played yet',
                  message: 'Your recent scores will show up here after your first game.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text('Soon', style: theme.textTheme.labelSmall),
    );
  }
}
