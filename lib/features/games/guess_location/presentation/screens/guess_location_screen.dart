import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/push_screen.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/location_engine/location_engine.dart';
import '../../../../game_engine/location_engine/presentation/screens/location_game_screen.dart';
import '../../../../game_engine/presentation/screens/difficulty_select_screen.dart';
import '../../../../player/providers/player_providers.dart';
import '../../../guess_outline/providers/country_outline_providers.dart';

const int _questionsPerGame = 10;

/// Guess by Location: a country's name appears, tap the world map as
/// close as you can to where it actually is. Needs both the country
/// pool (for names/coordinates) and the outline dataset (for the map's
/// land silhouette), so this waits on two providers instead of one.
class GuessLocationScreen extends ConsumerWidget {
  const GuessLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    final outlinesAsync = ref.watch(countryOutlinesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => outlinesAsync.when(
        loading: () => const LoadingView(message: 'Loading the map…'),
        error: (err, st) => ErrorView(message: '$err'),
        data: (outlines) {
          final eligible = countries
              .where((c) => c.latitude != null && c.longitude != null)
              .toList();
          return DifficultySelectScreen(
            title: 'Guess by Location',
            subtitle: 'Tap the map as close as you can to each country.',
            icon: Icons.my_location_outlined,
            onSelect: (difficulty) {
              context.pushScreen(
                LocationGameScreen(
                  engineBuilder: () => LocationEngine(
                    targets: (List.of(
                      eligible,
                    )..shuffle()).take(_questionsPerGame).toList(),
                    difficulty: difficulty,
                    outlines: outlines,
                  ),
                  outlines: outlines,
                  onSessionComplete: (GameResult result) {
                    ref
                        .read(playerProfileProvider.notifier)
                        .recordSession(result);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
