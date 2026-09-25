import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/router/push_screen.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/models/country.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_difficulty.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/engine/multiple_choice_engine.dart';
import '../../../../game_engine/logic/multiple_choice_generator.dart';
import '../../../../game_engine/presentation/screens/difficulty_select_screen.dart';
import '../../../../game_engine/presentation/screens/multiple_choice_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

const int _questionsPerGame = 10;

/// Guess by Capital: a capital city appears, pick its country from 4
/// options. A small number of entries have no formally recognized
/// capital (see `Country.capital`) — those are simply excluded from the
/// correct-answer pool; wrong-answer options still draw from the full
/// 195-country pool.
class GuessCapitalScreen extends ConsumerWidget {
  const GuessCapitalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final eligible = countries
            .where((c) => c.capital != null && c.capital!.isNotEmpty)
            .toList();
        return DifficultySelectScreen(
          title: 'Guess by Capital',
          subtitle: 'A capital city appears — name its country.',
          icon: Icons.location_city_outlined,
          onSelect: (difficulty) {
            context.pushScreen(
              MultipleChoiceGameScreen(
                title: 'Guess by Capital',
                engineBuilder: () =>
                    _buildEngine(eligible, countries, difficulty),
                promptBuilder: (context, promptText) => Text(
                  promptText,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                onSessionComplete: (GameResult result) {
                  ref.read(playerProfileProvider.notifier).recordSession(result);
                },
              ),
            );
          },
        );
      },
    );
  }

  MultipleChoiceEngine _buildEngine(
    List<Country> eligible,
    List<Country> fullPool,
    GameDifficulty difficulty,
  ) {
    final questions = MultipleChoiceGenerator().generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionsPerGame,
      difficulty: difficulty,
      promptFor: (c) => c.capital!,
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }
}
