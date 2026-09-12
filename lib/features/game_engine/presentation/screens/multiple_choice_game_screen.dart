import 'package:flutter/material.dart';

import '../../../../data/countries/models/country.dart';
import '../../domain/game_result.dart';
import '../../engine/multiple_choice_engine.dart';
import '../widgets/answer_option_button.dart';
import '../widgets/score_header.dart';
import '../widgets/timer_bar.dart';
import 'game_results_view.dart';

/// Generic screen for any "clue → pick the country" mode. Guess by Flag
/// and Guess by Emoji are both just an [engineBuilder] (which questions)
/// and a [promptBuilder] (how the clue renders) — everything else (timer,
/// scoring, feedback, results) lives here once.
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

  @override
  void initState() {
    super.initState();
    _engine = widget.engineBuilder()..addListener(_onEngineTick);
    _engine.start();
  }

  void _onEngineTick() {
    if (_engine.isComplete && !_resultRecorded) {
      _resultRecorded = true;
      widget.onSessionComplete(_engine.buildResult());
    }
    setState(() {});
  }

  void _playAgain() {
    _engine.removeListener(_onEngineTick);
    _engine.dispose();
    setState(() {
      _resultRecorded = false;
      _engine = widget.engineBuilder()..addListener(_onEngineTick);
      _engine.start();
    });
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineTick);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: _engine.isComplete
            ? GameResultsView(
                result: _engine.buildResult(),
                onPlayAgain: _playAgain,
              )
            : _QuestionView(engine: _engine, promptBuilder: widget.promptBuilder),
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
