import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:math';

import '../../../../app/router/route_paths.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/countries/providers/country_providers.dart';
import '../../../games/data/game_catalog.dart';
import '../../../player/providers/player_providers.dart';
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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TerraScope', style: theme.textTheme.headlineLarge),
                        Text('Explore the world, one country at a time.',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    IconButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings are coming soon')),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: PlayerStatBar(profile: profile)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionCard(
                  icon: Icons.today_outlined,
                  title: 'Daily Challenge',
                  subtitle: 'Arrives soon — same challenge for every player, every day.',
                  accentColor: theme.colorScheme.tertiary,
                  trailing: _ComingSoonChip(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
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
