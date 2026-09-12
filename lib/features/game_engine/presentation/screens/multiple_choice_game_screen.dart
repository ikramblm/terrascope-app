import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../data/countries/models/country.dart';
import '../../domain/game_result.dart';
import '../../engine/multiple_choice_engine.dart';
import '../../sound/sound_service.dart';
import '../widgets/answer_option_button.dart';
import '../widgets/score_header.dart';
import '../widgets/timer_bar.dart';
import 'game_results_view.dart';

/// Generic screen for any "clue → pick the country" mode. Guess by Flag
/// and Guess by Emoji are both just an [engineBuilder] (which questions)
/// and a [promptBuilder] (how the clue renders) — everything else (timer,
/// scoring, feedback, confetti, sound, results) lives here once.
class MultipleChoiceGameScreen extends StatefulWidget {
  const MultipleChoiceGameScreen({
    super.key,
    required this.title,
    required this.engineBuilder,
    required this.promptBuilder,
    required this.onSessionComplete,
  });

  final String title;
  final MultipleChoiceEngine Function() engineBuilder;
  final Widget Function(BuildContext context, String promptText) promptBuilder;
  final void Function(GameResult result) onSessionComplete;

  @override
  State<MultipleChoiceGameScreen> createState() => _MultipleChoiceGameScreenState();
}

class _MultipleChoiceGameScreenState extends State<MultipleChoiceGameScreen> {
  late MultipleChoiceEngine _engine;
  bool _resultRecorded = false;
  int _lastCelebratedIndex = -1;

  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _engine = widget.engineBuilder()..addListener(_onEngineTick);
    _engine.start();
  }

  void _onEngineTick() {
    if (_engine.answered && _engine.currentIndex != _lastCelebratedIndex) {
      _lastCelebratedIndex = _engine.currentIndex;
      if (_engine.lastAnswerCorrect == true) {
        _confettiController.play();
        SoundService.instance.playCorrect();
      } else {
        SoundService.instance.playWrong();
      }
    }
    if (_engine.isComplete && !_resultRecorded) {
      _resultRecorded = true;
      SoundService.instance.playComplete();
      widget.onSessionComplete(_engine.buildResult());
    }
    setState(() {});
  }

  void _playAgain() {
    _engine.removeListener(_onEngineTick);
    _engine.dispose();
    setState(() {
      _resultRecorded = false;
      _lastCelebratedIndex = -1;
      _engine = widget.engineBuilder()..addListener(_onEngineTick);
      _engine.start();
    });
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineTick);
    _engine.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Stack(
          children: [
            _engine.isComplete
                ? GameResultsView(
                    result: _engine.buildResult(),
                    onPlayAgain: _playAgain,
                  )
                : _QuestionView(engine: _engine, promptBuilder: widget.promptBuilder),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 18,
                gravity: 0.4,
                emissionFrequency: 0.9,
                maxBlastForce: 16,
                minBlastForce: 6,
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.engine, required this.promptBuilder});

  final MultipleChoiceEngine engine;
  final Widget Function(BuildContext context, String promptText) promptBuilder;

  @override
  Widget build(BuildContext context) {
    final question = engine.currentQuestion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScoreHeader(
            score: engine.score,
            combo: engine.combo,
            questionNumber: engine.currentIndex + 1,
            totalQuestions: engine.totalQuestions,
          ),
          const SizedBox(height: 12),
          TimerBar(remaining: engine.timeRemaining, total: engine.timeAllotted),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: promptBuilder(context, question.promptText),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in question.options) ...[
            AnswerOptionButton(
              country: option,
              state: _stateFor(option),
              onTap: engine.answered ? null : () => engine.submitAnswer(option),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  AnswerOptionState _stateFor(Country option) {
    if (!engine.answered) return AnswerOptionState.idle;
    final isCorrectOption = option.cca3 == engine.currentQuestion.correctAnswer.cca3;
    if (isCorrectOption) return AnswerOptionState.correct;
    final isSelected = option.cca3 == engine.selectedAnswer?.cca3;
    return isSelected ? AnswerOptionState.incorrectSelected : AnswerOptionState.incorrectOther;
  }
}
