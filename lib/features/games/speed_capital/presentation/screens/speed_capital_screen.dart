import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../data/countries/models/country.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_difficulty.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/engine/multiple_choice_engine.dart';
import '../../../../game_engine/logic/multiple_choice_generator.dart';
import '../../../../game_engine/presentation/screens/multiple_choice_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

const int _questionPoolSize = 100;

/// Capital Speed Run: capitals, fast — one wrong answer ends the run.
class SpeedCapitalScreen extends ConsumerWidget {
  const SpeedCapitalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final eligible = countries.where((c) => c.capital != null && c.capital!.isNotEmpty).toList();
        return MultipleChoiceGameScreen(
          title: 'Capital Speed Run',
          engineBuilder: () => _buildEngine(eligible, countries),
          promptBuilder: (context, promptText) => Text(
            promptText,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          centerLabelBuilder: (engine) => 'Streak: ${engine.combo}',
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
          },
        );
      },
    );
  }

  MultipleChoiceEngine _buildEngine(List<Country> eligible, List<Country> fullPool) {
    final questions = MultipleChoiceGenerator().generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionPoolSize,
      difficulty: GameDifficulty.hard,
      promptFor: (c) => c.capital!,
    );
    return MultipleChoiceEngine(questions: questions, difficulty: GameDifficulty.hard, suddenDeath: true);
  }
}
