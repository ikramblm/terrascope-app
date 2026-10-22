import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/presentation/name_pool_select_screen.dart';
import '../../../../player/providers/player_providers.dart';

const _letterColors = [
  AppColors.oceanBlue,
  AppColors.green,
  AppColors.orange,
  AppColors.coral,
  AppColors.purple,
  AppColors.skyBlue,
];

/// Name by Letter: pick a starting letter, then name every country that
/// starts with it. Letters with zero matches don't appear.
class NameLetterScreen extends ConsumerWidget {
  const NameLetterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final options = <NamePoolOption>[];
        for (var i = 0; i < 26; i++) {
          final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
          final pool = countries
              .where((c) => c.nameCommon.toUpperCase().startsWith(letter))
              .toList();
          if (pool.isEmpty) continue;
          options.add(
            NamePoolOption(
              label: letter,
              subtitle:
                  '${pool.length} ${pool.length == 1 ? 'country' : 'countries'}',
              icon: Icons.abc,
              color: _letterColors[options.length % _letterColors.length],
              pool: pool,
            ),
          );
        }

        return NamePoolSelectScreen(
          title: 'Name by Letter',
          subtitle:
              'Pick a letter, then name every country that starts with it.',
          icon: Icons.abc,
          options: options,
          gameTitleFor: (o) => 'Countries Starting with ${o.label}',
          instructionsFor: (o) =>
              'Type every country starting with "${o.label}".',
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
          },
        );
      },
    );
  }
}
