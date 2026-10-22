import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/name_engine/name_engine.dart';
import '../../../../game_engine/name_engine/presentation/name_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

/// Name as Many as Possible: same mechanic as Name All Countries, framed
/// as casual practice rather than a completionist run — no implied goal
/// of 195, just see how many you know. Pool is the full dataset either
/// way; stop anytime with "I'm Done".
class NameAsManyScreen extends ConsumerWidget {
  const NameAsManyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => NameGameScreen(
        title: 'Name as Many as Possible',
        instructions: 'No timer, no target — just see how many you know.',
        engineBuilder: () => NameEngine(pool: countries),
        onSessionComplete: (GameResult result) {
          ref.read(playerProfileProvider.notifier).recordSession(result);
        },
      ),
    );
  }
}
