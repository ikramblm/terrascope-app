import 'dart:math';

import '../../../data/countries/models/country.dart';
import '../domain/game_difficulty.dart';
import '../domain/multiple_choice_question.dart';

/// Procedurally builds multiple-choice questions from country data — the
/// generic mechanism behind Guess by Flag, Guess by Emoji, and every
/// future "clue in, 4 countries out" mode. Nothing here hardcodes a
/// question; it draws from whatever pool and prompt function the caller
/// supplies, so modes differ only in what clue they show.
class MultipleChoiceGenerator {
  MultipleChoiceGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Builds up to [count] questions, each with [optionsCount] choices.
  ///
  /// - [pool]: countries eligible to be *asked about* (must have a valid
  ///   clue — e.g. only countries with a curated emoji clue).
  /// - [distractorPool]: countries eligible as *wrong answers* — normally
  ///   the full 195, so wrong options aren't limited to the clue-pool.
  /// - On [GameDifficulty.hard], wrong answers are preferentially drawn
  ///   from the same continent as the correct answer (visually/mentally
  ///   closer, so harder to rule out) — on easy/medium, they're global.
  List<MultipleChoiceQuestion> generate({
    required List<Country> pool,
    required List<Country> distractorPool,
    required int count,
    required GameDifficulty difficulty,
    required String Function(Country) promptFor,
    int optionsCount = 4,
  }) {
    if (pool.isEmpty) return const [];

    final shuffledPool = List<Country>.of(pool)..shuffle(_random);
    final questionCountries = shuffledPool.take(count).toList();

    return [
      for (final correct in questionCountries)
        MultipleChoiceQuestion(
          promptText: promptFor(correct),
          correctAnswer: correct,
          options: _buildOptions(
            correct: correct,
            distractorPool: distractorPool,
            optionsCount: optionsCount,
            difficulty: difficulty,
          ),
        ),
    ];
  }

  List<Country> _buildOptions({
    required Country correct,
    required List<Country> distractorPool,
    required int optionsCount,
    required GameDifficulty difficulty,
  }) {
    final needed = optionsCount - 1;
    final candidates = distractorPool.where((c) => c.cca3 != correct.cca3).toList();

    List<Country> chosen;
    if (difficulty == GameDifficulty.hard) {
      final sameContinent = candidates.where((c) => c.continent == correct.continent).toList()
        ..shuffle(_random);
      chosen = sameContinent.take(needed).toList();
      if (chosen.length < needed) {
        final rest = candidates.where((c) => !chosen.contains(c)).toList()..shuffle(_random);
        chosen.addAll(rest.take(needed - chosen.length));
      }
    } else {
      chosen = (candidates..shuffle(_random)).take(needed).toList();
    }

    final options = [correct, ...chosen]..shuffle(_random);
    return options;
  }
}
