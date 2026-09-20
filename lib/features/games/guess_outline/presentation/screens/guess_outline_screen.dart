import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
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
import '../../providers/country_outline_providers.dart';
import '../widgets/country_outline_shape.dart';

const int _questionsPerGame = 10;

/// Guess by Outline: a country's real silhouette appears, pick its name
/// from 4 options. Correct-answer countries are limited to the curated
/// `country_outlines.json` set (see its README note — small island
/// nations don't render at this map resolution); wrong-answer options
/// still draw from the full 195-country pool.
class GuessOutlineScreen extends ConsumerWidget {
  const GuessOutlineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    final outlinesAsync = ref.watch(countryOutlinesProvider);

    if (countriesAsync.isLoading || outlinesAsync.isLoading) {
      return const LoadingView(message: 'Loading country outlines…');
    }
    if (countriesAsync.hasError || outlinesAsync.hasError) {
      return ErrorView(
        message: '${countriesAsync.error ?? outlinesAsync.error}',
      );
    }

    final countries = countriesAsync.requireValue;
    final outlines = outlinesAsync.requireValue;
    final byCca3 = {for (final c in countries) c.cca3: c};
    final eligible = outlines.keys
        .map((cca3) => byCca3[cca3])
        .whereType<Country>()
        .toList();

    return DifficultySelectScreen(
      title: 'Guess by Outline',
      subtitle: 'A country\'s shape appears — name it from 4 options.',
      icon: Icons.crop_free,
      onSelect: (difficulty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultipleChoiceGameScreen(
              title: 'Guess by Outline',
              engineBuilder: () =>
                  _buildEngine(eligible, countries, difficulty),
              promptBuilder: (context, promptText) => CountryOutlineShape(
                outline: outlines[promptText]!,
                color: AppColors.green,
                glowColor: AppColors.orange,
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
    GameDifficulty difficulty,
  ) {
    final questions = MultipleChoiceGenerator(random: Random()).generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionsPerGame,
      difficulty: difficulty,
      // The "prompt" is just the cca3 code; promptBuilder looks up the
      // actual outline geometry from it (geometry isn't a String, so it
      // can't be the prompt itself — the generic engine's prompt is
      // always text).
      promptFor: (c) => c.cca3,
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }
}
