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

/// Guess by Borders: a list of neighboring countries appears, pick the
/// country they all border. Island nations and other countries with no
/// land border have nothing to show, so they're excluded from the
/// correct-answer pool; wrong-answer options still draw from the full
/// 195-country pool.
class GuessBordersScreen extends ConsumerWidget {
  const GuessBordersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);

    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final byCca3 = {for (final c in countries) c.cca3: c};
        final eligible = countries.where((c) => c.borders.isNotEmpty).toList();
        return DifficultySelectScreen(
          title: 'Guess by Borders',
          subtitle: 'Its neighbors appear — name the country.',
          icon: Icons.hub_outlined,
          onSelect: (difficulty) {
            context.pushScreen(
              MultipleChoiceGameScreen(
                title: 'Guess by Borders',
                engineBuilder: () =>
                    _buildEngine(eligible, countries, byCca3, difficulty),
                promptBuilder: (context, promptText) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    promptText,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
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
    List<Country> eligible,
    List<Country> fullPool,
    Map<String, Country> byCca3,
    GameDifficulty difficulty,
  ) {
    final questions = MultipleChoiceGenerator().generate(
      pool: eligible,
      distractorPool: fullPool,
      count: _questionsPerGame,
      difficulty: difficulty,
      promptFor: (c) =>
          c.borders.map((code) => byCca3[code]?.nameCommon ?? code).join(' · '),
    );
    return MultipleChoiceEngine(questions: questions, difficulty: difficulty);
  }
}
