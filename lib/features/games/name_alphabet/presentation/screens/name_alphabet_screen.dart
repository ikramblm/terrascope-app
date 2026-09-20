import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/alphabet_engine/alphabet_engine.dart';
import '../../../../game_engine/alphabet_engine/presentation/alphabet_game_screen.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../player/providers/player_providers.dart';

/// Name the Alphabet: work through A→Z in order, naming one country per
/// letter — skip if you're stuck, score comes at the end.
class NameAlphabetScreen extends ConsumerWidget {
  const NameAlphabetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => AlphabetGameScreen(
        engineBuilder: () => AlphabetEngine(pool: countries),
        onSessionComplete: (GameResult result) {
          ref.read(playerProfileProvider.notifier).recordSession(result);
        },
      ),
    );
  }
}
