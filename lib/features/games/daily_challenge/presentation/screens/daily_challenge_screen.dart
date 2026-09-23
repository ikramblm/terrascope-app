import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_paths.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_background.dart';
import '../../../../../core/widgets/async_state_views.dart';
import '../../../../../core/widgets/color_back_button.dart';
import '../../../../../core/widgets/max_width_box.dart';
import '../../../../../data/countries/providers/country_providers.dart';
import '../../../../game_engine/domain/game_difficulty.dart';
import '../../../../game_engine/domain/game_result.dart';
import '../../../../game_engine/engine/multiple_choice_engine.dart';
import '../../../../game_engine/logic/multiple_choice_generator.dart';
import '../../../../game_engine/presentation/screens/multiple_choice_game_screen.dart';
import '../../../../player/providers/player_providers.dart';

const int _questionsPerChallenge = 5;

/// A daily flag challenge — 5 questions, seeded by today's date so
/// replaying gives the same set (there's no server yet to hand out one
/// shared seed to every player at once, so this is honestly a
/// single-player daily ritual, not a synced global one — see the
/// retention blueprint's Section 5). One honest attempt per calendar day.
class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    final profile = ref.watch(playerProfileProvider);
    final today = DateTime.now();
    final alreadyDone = profile.hasCompletedDailyChallengeOn(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        leading: const ColorBackButton(),
      ),
      body: AppBackground(
        child: MaxWidthBox(
          child: countriesAsync.when(
            loading: () => const LoadingView(message: 'Loading countries…'),
            error: (err, st) => ErrorView(message: '$err'),
            data: (countries) => alreadyDone
                ? _CompletedState(streak: profile.currentStreakDays)
                : _IntroState(
                    onStart: () {
                      final seed =
                          today.year * 10000 + today.month * 100 + today.day;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultipleChoiceGameScreen(
                            title: 'Daily Challenge',
                            engineBuilder: () {
                              final questions =
                                  MultipleChoiceGenerator(
                                    random: Random(seed),
                                  ).generate(
                                    pool: countries,
                                    distractorPool: countries,
                                    count: _questionsPerChallenge,
                                    difficulty: GameDifficulty.medium,
                                    promptFor: (c) => c.flagEmoji,
                                  );
                              return MultipleChoiceEngine(
                                questions: questions,
                                difficulty: GameDifficulty.medium,
                              );
                            },
                            promptBuilder: (context, promptText) => Text(
                              promptText,
                              style: const TextStyle(fontSize: 96),
                            ),
                            onSessionComplete: (GameResult result) {
                              final notifier = ref.read(
                                playerProfileProvider.notifier,
                              );
                              notifier.recordSession(result);
                              notifier.recordDailyChallengeCompletion(today);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _IntroState extends StatelessWidget {
  const _IntroState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.ctaCyan, AppColors.ctaViolet],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.today_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text('Today\'s 5 Flags', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Five flags, one honest attempt a day. Come back tomorrow for a new set — and to keep your streak going.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Start Today\'s Challenge'),
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text('All done for today', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            streak > 0
                ? 'Today\'s challenge is complete — your $streak-day streak is safe. A new one lands tomorrow.'
                : 'Today\'s challenge is complete. A new one lands tomorrow.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
