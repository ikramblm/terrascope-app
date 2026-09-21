import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/async_state_views.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../data/countries/models/country.dart';
import '../../../../data/countries/providers/country_providers.dart';
import '../../../game_engine/domain/game_difficulty.dart';
import '../../../game_engine/domain/game_result.dart';
import '../../../game_engine/engine/multiple_choice_engine.dart';
import '../../../game_engine/logic/multiple_choice_generator.dart';
import '../../../game_engine/presentation/screens/multiple_choice_game_screen.dart';
import '../../../player/providers/player_providers.dart';
import '../../domain/duel_payload.dart';
import 'duel_result_screen.dart';

const int _duelQuestionCount = 8;

/// The async-duel hub: create a challenge to share, or paste one a
/// friend sent you. No backend, no deep link — the whole challenge is
/// carried in a copy-pasted code (see [DuelPayload]), so both sides
/// really do play the identical question set, honestly compared
/// on-device. The one real gap, stated plainly in the UI: the
/// challenger isn't automatically notified of a result — sharing the
/// return code back is on the player, not the app.
class DuelScreen extends ConsumerStatefulWidget {
  const DuelScreen({super.key});

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  final _nameController = TextEditingController(text: 'Guest Explorer');
  final _codeController = TextEditingController();
  String? _decodeError;
  DuelPayload? _decoded;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startChallenge(List<Country> countries) {
    final name = _nameController.text.trim().isEmpty
        ? 'Guest Explorer'
        : _nameController.text.trim();
    final seed = Random().nextInt(1 << 31);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultipleChoiceGameScreen(
          title: 'Duel Challenge',
          engineBuilder: () {
            final questions = MultipleChoiceGenerator(random: Random(seed))
                .generate(
                  pool: countries,
                  distractorPool: countries,
                  count: _duelQuestionCount,
                  difficulty: GameDifficulty.medium,
                  promptFor: (c) => c.flagEmoji,
                );
            return MultipleChoiceEngine(
              questions: questions,
              difficulty: GameDifficulty.medium,
            );
          },
          promptBuilder: (context, promptText) =>
              Text(promptText, style: const TextStyle(fontSize: 96)),
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DuelResultScreen(
                  myScore: result.totalScore,
                  myName: name,
                  shareCode: DuelPayload(
                    seed: seed,
                    questionCount: _duelQuestionCount,
                    challengerScore: result.totalScore,
                    challengerName: name,
                  ).encode(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _decode() {
    final result = DuelPayload.decode(_codeController.text);
    setState(() {
      _decoded = result;
      _decodeError = result == null
          ? "That code didn't look right — check it and try again."
          : null;
    });
  }

  void _playChallenge(List<Country> countries) {
    final payload = _decoded;
    if (payload == null) return;
    final name = _nameController.text.trim().isEmpty
        ? 'Guest Explorer'
        : _nameController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultipleChoiceGameScreen(
          title: 'vs ${payload.challengerName}',
          engineBuilder: () {
            final questions =
                MultipleChoiceGenerator(random: Random(payload.seed)).generate(
                  pool: countries,
                  distractorPool: countries,
                  count: payload.questionCount,
                  difficulty: GameDifficulty.medium,
                  promptFor: (c) => c.flagEmoji,
                );
            return MultipleChoiceEngine(
              questions: questions,
              difficulty: GameDifficulty.medium,
            );
          },
          promptBuilder: (context, promptText) =>
              Text(promptText, style: const TextStyle(fontSize: 96)),
          onSessionComplete: (GameResult result) {
            ref.read(playerProfileProvider.notifier).recordSession(result);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DuelResultScreen(
                  myScore: result.totalScore,
                  myName: name,
                  opponentScore: payload.challengerScore,
                  opponentName: payload.challengerName,
                  shareCode: DuelPayload(
                    seed: payload.seed,
                    questionCount: payload.questionCount,
                    challengerScore: result.totalScore,
                    challengerName: name,
                  ).encode(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countriesAsync = ref.watch(allCountriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Duel a Friend')),
      body: AppBackground(
        child: MaxWidthBox(
          child: countriesAsync.when(
            loading: () => const LoadingView(message: 'Loading countries…'),
            error: (err, st) => ErrorView(message: '$err'),
            data: (countries) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Challenge a Friend',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Play $_duelQuestionCount flags, then send your friend '
                    'a code to beat your score with the exact same '
                    'questions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Your name'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _startChallenge(countries),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Start Challenge'),
                  ),
                  const SizedBox(height: 32),
                  Container(height: 1, color: theme.colorScheme.outline),
                  const SizedBox(height: 32),
                  Text('Join a Duel', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Paste a code a friend sent you.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Duel code',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _decode,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Decode'),
                  ),
                  if (_decodeError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _decodeError!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                  if (_decoded != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_decoded!.challengerName} scored '
                        '${_decoded!.challengerScore} on '
                        '${_decoded!.questionCount} flags. Beat it?',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _playChallenge(countries),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('Play Their Challenge'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
