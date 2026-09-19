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
const Duration _globalTimeLimit = Duration(seconds: 60);

/// 60-Second Challenge: one minute, as many flags as you can get right.
/// Unlike the streak speed-runs, a wrong answer doesn't end the run —
/// only the clock does.
class Speed60sScreen extends ConsumerWidget {
  const Speed60sScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) => MultipleChoiceGameScreen(
        title: '60-Second Challenge',
        engineBuilder: () => _buildEngine(countries),
        promptBuilder: (context, promptText) => Text(promptText, style: const TextStyle(fontSize: 96)),
        centerLabelBuilder: (engine) {
          final remaining = _globalTimeLimit - engine.elapsed;
          final seconds = remaining.isNegative ? 0 : remaining.inSeconds + 1;
          return '${seconds}s left';
        },
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
      globalTimeLimit: _globalTimeLimit,
    );
  }
}
