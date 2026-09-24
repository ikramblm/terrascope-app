import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/models/country.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/name_engine.dart';
import '../../../../game_engine/name_engine/presentation/name_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

/// Name the Neighbors: one random country with at least one land
/// border is picked when the screen opens, then it's "type every
/// country bordering it" — the reverse of Guess by Borders, which
/// shows the neighbor list and asks for the country they surround.
class NameBordersOfScreen extends ConsumerWidget {
  const NameBordersOfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final eligible = countries.where((c) => c.borders.isNotEmpty).toList();
        if (eligible.isEmpty) {
          return const ErrorView(
            message: 'No countries with land borders found.',
          );
        }
        final byCca3 = {for (final c in countries) c.cca3: c};
        final target = eligible[Random().nextInt(eligible.length)];
        final neighbors = target.borders
            .map((code) => byCca3[code])
            .whereType<Country>()
            .toList();

        return NameGameScreen(
          title: 'Name the Neighbors',
          instructions: 'Name every country bordering ${target.nameCommon}.',
          engineBuilder: () => NameEngine(pool: neighbors),
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
          },
        );
      },
    );
  }
}
