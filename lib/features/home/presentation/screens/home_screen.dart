import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../data/countries/providers/country_providers.dart';
import '../../../games/data/game_catalog.dart';
import '../../../player/providers/player_providers.dart';
import '../widgets/home_hero.dart';
import '../widgets/player_stat_bar.dart';
import '../widgets/section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final countriesAsync = ref.watch(allCountriesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeHero(
                onSettingsTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings are coming soon')),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: FadeSlideIn(
                    index: 0,
                    child: PlayerStatBar(profile: profile),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _quickPlay(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Quick Play'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 2,
                  child: SectionCard(
                    icon: Icons.today_outlined,
                    title: 'Daily Challenge',
                    subtitle: 'Arrives soon — same challenge for every player, every day.',
                    accentColor: theme.colorScheme.tertiary,
                    trailing: _ComingSoonChip(),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 3,
                  child: countriesAsync.when(
                    data: (countries) => SectionCard(
                      icon: Icons.public,
                      title: 'World Database Ready',
                      subtitle: '${countries.length} countries loaded — browse every game mode',
                      accentColor: theme.colorScheme.secondary,
                      onTap: () => context.go(RoutePaths.games),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    loading: () => const SectionCard(
                      icon: Icons.public,
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text('Recent Scores', style: theme.textTheme.headlineMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              sliver: SliverToBoxAdapter(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.history,
                      title: 'No games played yet',
                      message: 'Your recent scores will show up here after your first game.',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickPlay(BuildContext context) {
    final available = kGameCatalog.where((m) => m.isAvailable).toList();
    if (available.isEmpty) {
      context.go(RoutePaths.games);
      return;
    }
    final pick = available[Random().nextInt(available.length)];
    context.push(pick.routePath!);
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text('Soon', style: theme.textTheme.labelSmall),
    );
  }
}
