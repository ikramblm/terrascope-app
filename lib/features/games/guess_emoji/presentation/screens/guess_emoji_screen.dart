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
import '../../../../game_engine/presentation/screens/difficulty_select_screen.dart';
import '../../../../game_engine/presentation/screens/multiple_choice_game_screen.dart';
import '../../../../player/providers/player_providers.dart';
import '../../providers/emoji_clue_providers.dart';

const int _questionsPerGame = 10;

/// Guess by Emoji: 2-3 emojis appear, pick the country they represent.
/// Correct-answer countries are limited to the curated `emoji_clues.json`
/// set (see its README note); wrong-answer options still draw from the
/// full 195-country pool.
class GuessEmojiScreen extends ConsumerWidget {
  const GuessEmojiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    final cluesAsync = ref.watch(emojiCluesProvider);

    if (countriesAsync.isLoading || cluesAsync.isLoading) {
      return const LoadingView(message: 'Loading emoji clues…');
    }
    if (countriesAsync.hasError || cluesAsync.hasError) {
      return ErrorView(message: '${countriesAsync.error ?? cluesAsync.error}');
    }

    final countries = countriesAsync.requireValue;
    final clues = cluesAsync.requireValue;
    final byCca3 = {for (final c in countries) c.cca3: c};
    final eligible = clues.keys
        .map((cca3) => byCca3[cca3])
        .whereType<Country>()
        .toList();

    return DifficultySelectScreen(
      title: 'Guess by Emoji',
      subtitle: 'A country, told in emoji — name it from 4 options.',
      icon: Icons.emoji_emotions_outlined,
      onSelect: (difficulty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultipleChoiceGameScreen(
              title: 'Guess by Emoji',
              engineBuilder: () =>
                  _buildEngine(eligible, countries, clues, difficulty),
              promptBuilder: (context, promptText) => Text(
                promptText,
                style: const TextStyle(fontSize: 72),
                textAlign: TextAlign.center,
              ),
              onSessionComplete: (GameResult result) {
                ref.read(playerProfileProvider.notifier).recordSession(result);
              },
            ),
          ),
        );
      },
    );
  }

  MultipleChoiceEngine _buildEngine(
    List<Country> eligible,
    List<Country> fullPool,
    Map<String, List<String>> clues,
    GameDifficulty difficulty,
  ) {
    final random = Random();
    final questions = MultipleChoiceGenerator(random: random).generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionsPerGame,
      difficulty: difficulty,
      promptFor: (c) => _pickClue(clues, c.cca3, random),
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }

  String _pickClue(
    Map<String, List<String>> clues,
    String cca3,
    Random random,
  ) {
    final options = clues[cca3]!;
    return options[random.nextInt(options.length)];
  }
}
