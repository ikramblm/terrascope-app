import 'dart:math';

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
import '../../../guess_emoji/providers/emoji_clue_providers.dart';

const int _questionPoolSize = 100;

/// Country Speed Run: countries told in emoji, fast — one wrong answer
/// ends the run. Correct-answer countries are limited to the curated
/// emoji clue set (see `emoji_clues.json`'s README note).
class SpeedCountryScreen extends ConsumerWidget {
  const SpeedCountryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    final cluesAsync = ref.watch(emojiCluesProvider);

    if (countriesAsync.isLoading || cluesAsync.isLoading) {
      return const LoadingView(message: 'Loading countries…');
    }
    if (countriesAsync.hasError || cluesAsync.hasError) {
      return ErrorView(message: '${countriesAsync.error ?? cluesAsync.error}');
    }

    final countries = countriesAsync.requireValue;
    final clues = cluesAsync.requireValue;
    final byCca3 = {for (final c in countries) c.cca3: c};
    final eligible = clues.keys.map((cca3) => byCca3[cca3]).whereType<Country>().toList();

    return MultipleChoiceGameScreen(
      title: 'Country Speed Run',
      engineBuilder: () => _buildEngine(eligible, countries, clues),
      promptBuilder: (context, promptText) => Text(
        promptText,
        style: const TextStyle(fontSize: 72),
        textAlign: TextAlign.center,
      ),
      centerLabelBuilder: (engine) => 'Streak: ${engine.combo}',
      onSessionComplete: (GameResult result) {
        ref.read(playerProfileProvider.notifier).recordSession(result);
      },
    );
  }

  MultipleChoiceEngine _buildEngine(
    List<Country> eligible,
    List<Country> fullPool,
    Map<String, List<String>> clues,
  ) {
    final random = Random();
    final questions = MultipleChoiceGenerator(random: random).generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionPoolSize,
      difficulty: GameDifficulty.hard,
      promptFor: (c) => _pickClue(clues, c.cca3, random),
    );
    return MultipleChoiceEngine(questions: questions, difficulty: GameDifficulty.hard, suddenDeath: true);
  }

  String _pickClue(Map<String, List<String>> clues, String cca3, Random random) {
    final options = clues[cca3]!;
    return options[random.nextInt(options.length)];
  }
}
