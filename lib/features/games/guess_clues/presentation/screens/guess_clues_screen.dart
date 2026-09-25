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

/// How many clues (from the front of [_cluesFor]'s vague-to-specific
/// list) each difficulty reveals — fewer and vaguer at Hard, matching
/// the mode's own tagline: "fewer clues, more points" pairs naturally
/// with Hard's already-higher base points from [GameDifficulty].
int _clueCountFor(GameDifficulty difficulty) => switch (difficulty) {
  GameDifficulty.easy => 3,
  GameDifficulty.medium => 2,
  GameDifficulty.hard => 1,
};

/// Guess by Clues: a short list of facts about a country, vaguest
/// first — pick the country they describe. No stored "clue" field
/// exists in the dataset, so clues are synthesized from fields every
/// country already has (continent, subregion, landlocked/coastal,
/// area, capital) rather than inventing new per-country content. Kept
/// as short label fragments, not full sentences — the shared game
/// screen's prompt area has room for one wrapped line or two, not a
/// paragraph.
List<String> _cluesFor(Country c) {
  return [
    c.continent,
    if (c.subregion.isNotEmpty) c.subregion,
    c.landlocked ? 'Landlocked' : 'Coastal',
    if (c.area != null) '~${_formatArea(c.area!)} km²',
    if (c.capital != null) 'Capital: ${c.capital}',
  ];
}

String _formatArea(double area) {
  if (area >= 1000000) return '${(area / 1000000).toStringAsFixed(1)}M';
  if (area >= 1000) return '${(area / 1000).round()}K';
  return area.round().toString();
}

class GuessCluesScreen extends ConsumerWidget {
  const GuessCluesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        return DifficultySelectScreen(
          title: 'Guess by Clues',
          subtitle: 'A few facts appear — name the country they describe.',
          icon: Icons.lightbulb_outline,
          onSelect: (difficulty) {
            context.pushScreen(
              MultipleChoiceGameScreen(
                title: 'Guess by Clues',
                engineBuilder: () => _buildEngine(countries, difficulty),
                promptBuilder: (context, promptText) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  // FittedBox as a hard guarantee, on top of keeping
                  // clues short: the prompt area's real height varies
                  // by device and by how many power-ups are still in
                  // stock, so no fixed font size can promise a fit —
                  // this scales the text down instead of ever
                  // overflowing into the rows above or below it.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      promptText,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
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
    List<Country> countries,
    GameDifficulty difficulty,
  ) {
    final clueCount = _clueCountFor(difficulty);
    final questions = MultipleChoiceGenerator().generate(
      pool: countries,
      distractorPool: countries,
      count: _questionsPerGame,
      difficulty: difficulty,
      promptFor: (c) => _cluesFor(c).take(clueCount).join(' · '),
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }
}
