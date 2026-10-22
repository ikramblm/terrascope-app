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

/// Flag Speed Run: flags, fast — one wrong answer ends the run. No
/// difficulty picker (it's already the fast tier); score is how long a
/// correct streak you can build.
class SpeedFlagScreen extends ConsumerWidget {
  const SpeedFlagScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => MultipleChoiceGameScreen(
        title: 'Flag Speed Run',
        engineBuilder: () => _buildEngine(countries),
        promptBuilder: (context, promptText) =>
            Text(promptText, style: const TextStyle(fontSize: 96)),
        centerLabelBuilder: (engine) => 'Streak: ${engine.combo}',
        onSessionComplete: (GameResult result) {
          ref.read(playerProfileProvider.notifier).recordSession(result);
        },
      ),
    );
  }

  MultipleChoiceEngine _buildEngine(List<Country> countries) {
    final questions = MultipleChoiceGenerator().generate(
      pool: countries,
      distractorPool: countries,
      count: _questionPoolSize,
      difficulty: GameDifficulty.hard,
      promptFor: (c) => c.flagEmoji,
    );
    return MultipleChoiceEngine(
      questions: questions,
      difficulty: GameDifficulty.hard,
      suddenDeath: true,
    );
  }
}
