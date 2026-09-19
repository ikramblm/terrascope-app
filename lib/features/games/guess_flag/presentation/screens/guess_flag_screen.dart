import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Guess by Flag: show a country's flag, pick its name from 4 options.
/// Every country in the 195-country dataset is eligible — no hardcoded
/// question list, just the bundled flag emoji data.
class GuessFlagScreen extends ConsumerWidget {
  const GuessFlagScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => DifficultySelectScreen(
        title: 'Guess by Flag',
        subtitle: 'A flag appears — name the country behind it.',
        icon: Icons.flag_outlined,
        onSelect: (difficulty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultipleChoiceGameScreen(
                title: 'Guess by Flag',
                engineBuilder: () => _buildEngine(countries, difficulty),
                promptBuilder: (context, promptText) => Text(
                  promptText,
                  style: const TextStyle(fontSize: 96),
                ),
                onSessionComplete: (GameResult result) {
                  ref.read(playerProfileProvider.notifier).recordSession(result);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  MultipleChoiceEngine _buildEngine(List<Country> countries, GameDifficulty difficulty) {
    final questions = MultipleChoiceGenerator().generate(
      pool: countries,
      distractorPool: countries,
      count: _questionsPerGame,
      difficulty: difficulty,
      promptFor: (c) => c.flagEmoji,
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }
}
