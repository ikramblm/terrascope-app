import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/presentation/name_pool_select_screen.dart';
import '../../../../player/providers/player_providers.dart';

const Map<String, Color> _continentColors = {
  'Africa': AppColors.continentAfrica,
  'Asia': AppColors.continentAsia,
  'Europe': AppColors.continentEurope,
  'North America': AppColors.continentNorthAmerica,
  'South America': AppColors.continentSouthAmerica,
  'Oceania': AppColors.continentOceania,
};

/// Name by Continent: pick a continent, then name every country in it.
class NameContinentScreen extends ConsumerWidget {
  const NameContinentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final options = _continentColors.entries.map((entry) {
          final pool = countries.where((c) => c.continent == entry.key).toList();
          return NamePoolOption(
            label: entry.key,
            subtitle: '${pool.length} countries',
            icon: Icons.public_rounded,
            color: entry.value,
            pool: pool,
          );
        }).toList();

        return NamePoolSelectScreen(
          title: 'Name by Continent',
          subtitle: 'Pick a continent, then name every country in it.',
          icon: Icons.terrain_outlined,
          options: options,
          gameTitleFor: (o) => 'Name ${o.label}',
          instructionsFor: (o) => 'Type every country in ${o.label} you can think of.',
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
          },
        );
      },
    );
  }
}
