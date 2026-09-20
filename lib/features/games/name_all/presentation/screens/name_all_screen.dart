import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/name_engine.dart';
import '../../../../game_engine/name_engine/presentation/name_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

/// Name All Countries: type every country you can think of, no clock —
/// the completionist mode. Pool is the full 195-country dataset.
class NameAllScreen extends ConsumerWidget {
  const NameAllScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => NameGameScreen(
        title: 'Name All Countries',
        instructions:
            'Type every country you can think of — no rush, no clock.',
        engineBuilder: () => NameEngine(pool: countries),
        onSessionComplete: (GameResult result) {
          ref.read(playerProfileProvider.notifier).recordSession(result);
        },
      ),
    );
  }
}
