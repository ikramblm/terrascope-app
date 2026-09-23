import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/color_back_button.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../data/countries/models/country.dart';
import '../../domain/game_result.dart';
import '../../engine/multiple_choice_engine.dart';
import '../../sound/sound_service.dart';
import '../widgets/answer_option_button.dart';
import '../widgets/answer_reveal_inset.dart';
import '../widgets/combo_banner.dart';
import '../widgets/power_up_tray.dart';
import '../widgets/radar_reveal.dart';
import '../widgets/score_header.dart';
import '../widgets/timer_bar.dart';
import 'game_results_view.dart';

/// Generic screen for any "clue → pick the country" mode. Guess by Flag
/// and Guess by Emoji are both just an [engineBuilder] (which questions)
/// and a [promptBuilder] (how the clue renders) — everything else (timer,
/// scoring, feedback, confetti, sound, results, power-ups) lives here once.
class MultipleChoiceGameScreen extends StatefulWidget {
  const MultipleChoiceGameScreen({
    super.key,
    required this.title,
    required this.engineBuilder,
    required this.promptBuilder,
    required this.onSessionComplete,
    this.centerLabelBuilder,
  });

  final String title;
  final MultipleChoiceEngine Function() engineBuilder;
  final Widget Function(BuildContext context, String promptText) promptBuilder;
  final void Function(GameResult result) onSessionComplete;

  /// Overrides the header's default "Question X / Y" readout — speed
  /// modes pass a live streak count or countdown instead, since their
  /// pre-generated question pool size isn't a meaningful target.
  final String Function(MultipleChoiceEngine engine)? centerLabelBuilder;

  @override
  State<MultipleChoiceGameScreen> createState() =>
      _MultipleChoiceGameScreenState();
}

class _MultipleChoiceGameScreenState extends State<MultipleChoiceGameScreen> {
  late MultipleChoiceEngine _engine;
  bool _resultRecorded = false;
  int _lastCelebratedIndex = -1;

  // Power-up state, scoped to the current question — reset the moment
  // the engine moves to a new one (see _onEngineTick).
  int _powerUpQuestionIndex = -1;
  Set<String> _eliminatedCca3s = {};
  bool _radarRevealed = false;

  late final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _engine = widget.engineBuilder()..addListener(_onEngineTick);
    _engine.start();
  }

  void _onEngineTick() {
    if (!_engine.isComplete && _engine.currentIndex != _powerUpQuestionIndex) {
      _powerUpQuestionIndex = _engine.currentIndex;
      _eliminatedCca3s = {};
      _radarRevealed = false;
    }
    if (_engine.answered && _engine.currentIndex != _lastCelebratedIndex) {
      _lastCelebratedIndex = _engine.currentIndex;
      if (_engine.lastAnswerCorrect == true) {
        _confettiController.play();
        HapticFeedback.lightImpact();
        // combo was already incremented for this answer, so it's the
        // right "how many in a row so far" figure for the pitch ramp.
        SoundService.instance.playCorrect(comboLevel: _engine.combo);
      } else {
        HapticFeedback.mediumImpact();
        SoundService.instance.playWrong();
      }
    }
    if (_engine.isComplete && !_resultRecorded) {
      _resultRecorded = true;
      HapticFeedback.heavyImpact();
      SoundService.instance.playComplete();
      widget.onSessionComplete(_engine.buildResult());
    }
    setState(() {});
  }

  void _useFiftyFifty() {
    final correct = _engine.currentQuestion.correctAnswer.cca3;
    final wrongCca3s = _engine.currentQuestion.options
        .map((c) => c.cca3)
        .where((cca3) => cca3 != correct)
        .toList();
    setState(() => _eliminatedCca3s = wrongCca3s.take(2).toSet());
  }

  void _useTimeFreeze() => _engine.addTime(const Duration(seconds: 5));

  void _useRadar() => setState(() => _radarRevealed = true);

  void _playAgain() {
    _engine.removeListener(_onEngineTick);
    _engine.dispose();
    setState(() {
      _resultRecorded = false;
      _lastCelebratedIndex = -1;
      _powerUpQuestionIndex = -1;
      _eliminatedCca3s = {};
      _radarRevealed = false;
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
      appBar: AppBar(
        title: Text(widget.title),
        leading: const ColorBackButton(),
      ),
      body: AppBackground(
        child: SafeArea(
          child: MaxWidthBox(
            child: Stack(
              children: [
                _engine.isComplete
                    ? GameResultsView(
                        result: _engine.buildResult(),
                        onPlayAgain: _playAgain,
                      )
                    : _QuestionView(
                        engine: _engine,
                        promptBuilder: widget.promptBuilder,
                        centerLabelBuilder: widget.centerLabelBuilder,
                        eliminatedCca3s: _eliminatedCca3s,
                        radarRevealed: _radarRevealed,
                        onFiftyFifty: _useFiftyFifty,
                        onTimeFreeze: _useTimeFreeze,
                        onRadar: _useRadar,
                      ),
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
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.engine,
    required this.promptBuilder,
    required this.eliminatedCca3s,
    required this.radarRevealed,
    required this.onFiftyFifty,
    required this.onTimeFreeze,
    required this.onRadar,
    this.centerLabelBuilder,
  });

  final MultipleChoiceEngine engine;
  final Widget Function(BuildContext context, String promptText) promptBuilder;
  final String Function(MultipleChoiceEngine engine)? centerLabelBuilder;
  final Set<String> eliminatedCca3s;
  final bool radarRevealed;
  final VoidCallback onFiftyFifty;
  final VoidCallback onTimeFreeze;
  final VoidCallback onRadar;

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
            questionNumber: engine.currentIndex + 1,
            totalQuestions: engine.totalQuestions,
            centerLabel: centerLabelBuilder?.call(engine),
          ),
          const SizedBox(height: 12),
          TimerBar(remaining: engine.timeRemaining, total: engine.timeAllotted),
          const SizedBox(height: 12),
          ComboBanner(combo: engine.combo),
          const SizedBox(height: 8),
          if (!engine.answered)
            PowerUpTray(
              onFiftyFifty: onFiftyFifty,
              onTimeFreeze: onTimeFreeze,
              onRadar: onRadar,
              fiftyFiftyAvailable: eliminatedCca3s.isEmpty,
              radarAvailable: !radarRevealed,
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(child: promptBuilder(context, question.promptText)),
          ),
          if (!engine.answered && radarRevealed) ...[
            const SizedBox(height: 8),
            Center(
              child: RadarReveal(continent: question.correctAnswer.continent),
            ),
          ],
          if (engine.answered) ...[
            const SizedBox(height: 8),
            Center(child: AnswerRevealInset(cca3: question.correctAnswer.cca3)),
          ],
          const SizedBox(height: 12),
          for (final (i, option) in question.options.indexed) ...[
            AnswerOptionButton(
              country: option,
              state: _stateFor(option),
              slotIndex: i,
              onTap: engine.answered || eliminatedCca3s.contains(option.cca3)
                  ? null
                  : () => engine.submitAnswer(option),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  AnswerOptionState _stateFor(Country option) {
    if (!engine.answered) {
      return eliminatedCca3s.contains(option.cca3)
          ? AnswerOptionState.incorrectOther
          : AnswerOptionState.idle;
    }
    final isCorrectOption =
        option.cca3 == engine.currentQuestion.correctAnswer.cca3;
    if (isCorrectOption) return AnswerOptionState.correct;
    final isSelected = option.cca3 == engine.selectedAnswer?.cca3;
    return isSelected
        ? AnswerOptionState.incorrectSelected
        : AnswerOptionState.incorrectOther;
  }
}
