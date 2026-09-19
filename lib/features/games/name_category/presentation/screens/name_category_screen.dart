import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/presentation/name_pool_select_screen.dart';
import '../../../../player/providers/player_providers.dart';

/// Name by Category: pick a geographic category, then name every
/// country that fits it. Categories are drawn only from fields the
/// dataset actually has (island/landlocked status, land area) — never
/// an invented grouping.
class NameCategoryScreen extends ConsumerWidget {
  const NameCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final options = [
          NamePoolOption(
            label: 'Islands',
            subtitle: 'No land border',
            icon: Icons.beach_access_outlined,
            color: AppColors.skyBlue,
            pool: countries.where((c) => c.isIsland).toList(),
          ),
          NamePoolOption(
            label: 'Landlocked',
            subtitle: 'No coastline',
            icon: Icons.terrain_outlined,
            color: AppColors.orange,
            pool: countries.where((c) => c.landlocked).toList(),
          ),
          NamePoolOption(
            label: 'Small Nations',
            subtitle: 'Under 20,000 km²',
            icon: Icons.zoom_in_map_rounded,
            color: AppColors.purple,
            pool: countries.where((c) => c.area != null && c.area! < 20000).toList(),
          ),
          NamePoolOption(
            label: 'Large Nations',
            subtitle: 'Over 1,000,000 km²',
            icon: Icons.zoom_out_map_rounded,
            color: AppColors.green,
            pool: countries.where((c) => c.area != null && c.area! > 1000000).toList(),
          ),
        ];

        return NamePoolSelectScreen(
          title: 'Name by Category',
          subtitle: 'Pick a category, then name every country that fits.',
          icon: Icons.category_outlined,
          options: options,
          gameTitleFor: (o) => 'Name ${o.label}',
          instructionsFor: (o) => 'Type every ${o.label.toLowerCase()} country you can think of.',
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
          },
        );
      },
    );
  }
}
