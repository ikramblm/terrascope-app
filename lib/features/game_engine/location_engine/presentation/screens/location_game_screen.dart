import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_background.dart';
import '../../../../../core/widgets/color_back_button.dart';
import '../../../../../core/widgets/max_width_box.dart';
import '../../../../games/guess_outline/data/country_outline_repository.dart';
import '../../../domain/game_result.dart';
import '../../../presentation/screens/game_results_view.dart';
import '../../../presentation/widgets/score_header.dart';
import '../../../presentation/widgets/timer_bar.dart';
import '../../../sound/sound_service.dart';
import '../../location_engine.dart';
import '../widgets/world_tap_map.dart';

/// Guess by Location: a country's name appears, one tap on the world
/// map is the guess, scored by real-world distance — the same
/// engine-drives-the-state / screen-swaps-playing-for-results shape as
/// every other mode's shared game screen.
class LocationGameScreen extends StatefulWidget {
  const LocationGameScreen({
    super.key,
    required this.engineBuilder,
    required this.outlines,
    required this.onSessionComplete,
  });

  final LocationEngine Function() engineBuilder;
  final Map<String, CountryOutline> outlines;
  final void Function(GameResult result) onSessionComplete;

  @override
  State<LocationGameScreen> createState() => _LocationGameScreenState();
}

class _LocationGameScreenState extends State<LocationGameScreen> {
  late LocationEngine _engine;
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
      SoundService.instance.playComplete();
      widget.onSessionComplete(_engine.buildResult());
    }
    setState(() {});
  }

  void _handleGuess(double lon, double lat) {
    _engine.submitGuess(lon, lat);
    SoundService.instance.playTap();
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
      appBar: AppBar(
        title: const Text('Guess by Location'),
        leading: const ColorBackButton(),
      ),
      body: AppBackground(
        child: SafeArea(
          child: MaxWidthBox(
            child: _engine.isComplete
                ? GameResultsView(
                    result: _engine.buildResult(),
                    onPlayAgain: _playAgain,
                  )
                : _PlayingView(
                    engine: _engine,
                    outlines: widget.outlines,
                    onGuess: _handleGuess,
                  ),
          ),
        ),
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.engine,
    required this.outlines,
    required this.onGuess,
  });

  final LocationEngine engine;
  final Map<String, CountryOutline> outlines;
  final void Function(double lon, double lat) onGuess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = engine.lastDistanceKm;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScoreHeader(
            score: engine.score,
            questionNumber: engine.currentIndex + 1,
            totalQuestions: engine.totalQuestions,
          ),
          const SizedBox(height: 12),
          TimerBar(remaining: engine.timeRemaining, total: engine.timeAllotted),
          const SizedBox(height: 16),
          Text(
            'Where is ${engine.currentTarget.nameCommon}?',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          WorldTapMap(
            outlines: outlines,
            enabled: !engine.answered,
            onGuess: onGuess,
            guessLon: engine.lastGuessLon,
            guessLat: engine.lastGuessLat,
            actualLon: engine.answered ? engine.currentTarget.longitude : null,
            actualLat: engine.answered ? engine.currentTarget.latitude : null,
          ),
          const SizedBox(height: 12),
          if (engine.answered)
            Text(
              distance == null
                  ? "Time's up — no guess that round."
                  : '${distance.round()} km away · +${engine.lastRoundScore} pts',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
        ],
      ),
    );
  }
}
