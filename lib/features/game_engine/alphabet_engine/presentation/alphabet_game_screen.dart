import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/color_back_button.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../domain/game_result.dart';
import '../../sound/sound_service.dart';
import '../alphabet_engine.dart';
import 'alphabet_results_view.dart';

/// Name the Alphabet: A→Z in order, one country per letter. Correct
/// advances; Skip advances with no credit; the score comes at the end,
/// once every eligible letter has been resolved.
class AlphabetGameScreen extends StatefulWidget {
  const AlphabetGameScreen({
    super.key,
    required this.engineBuilder,
    required this.onSessionComplete,
  });

  final AlphabetEngine Function() engineBuilder;
  final void Function(GameResult result) onSessionComplete;

  @override
  State<AlphabetGameScreen> createState() => _AlphabetGameScreenState();
}

class _AlphabetGameScreenState extends State<AlphabetGameScreen> {
  late AlphabetEngine _engine;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _resultRecorded = false;
  bool _showWrongFlash = false;
  bool _showCorrectPop = false;
  Timer? _correctPopTimer;
  Timer? _wrongFlashTimer;

  @override
  void initState() {
    super.initState();
    _engine = widget.engineBuilder()..start();
    _maybeRecordCompletion();
  }

  void _maybeRecordCompletion() {
    if (_engine.isComplete && !_resultRecorded) {
      _resultRecorded = true;
      SoundService.instance.playComplete();
      widget.onSessionComplete(_engine.buildResult());
    }
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty || _engine.isComplete) return;
    final matched = _engine.submit(text);
    _controller.clear();
    if (matched) {
      HapticFeedback.lightImpact();
      SoundService.instance.playCorrect();
      setState(() {
        _showWrongFlash = false;
        _showCorrectPop = true;
      });
      _correctPopTimer?.cancel();
      _correctPopTimer = Timer(const Duration(milliseconds: 550), () {
        if (mounted) setState(() => _showCorrectPop = false);
      });
      _maybeRecordCompletion();
    } else {
      HapticFeedback.mediumImpact();
      SoundService.instance.playWrong();
      setState(() => _showWrongFlash = true);
      _wrongFlashTimer?.cancel();
      _wrongFlashTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showWrongFlash = false);
      });
    }
    _focusNode.requestFocus();
  }

  void _handleSkip() {
    if (_engine.isComplete) return;
    setState(() {
      _engine.skip();
      _showWrongFlash = false;
    });
    _maybeRecordCompletion();
    _focusNode.requestFocus();
  }

  void _playAgain() {
    setState(() {
      _resultRecorded = false;
      _showWrongFlash = false;
      _engine = widget.engineBuilder()..start();
    });
  }

  @override
  void dispose() {
    _correctPopTimer?.cancel();
    _wrongFlashTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name the Alphabet'),
        leading: const ColorBackButton(),
      ),
      body: AppBackground(
        child: SafeArea(
          child: MaxWidthBox(
            child: Stack(
              children: [
                _engine.isComplete
                    ? AlphabetResultsView(
                        engine: _engine,
                        onPlayAgain: _playAgain,
                      )
                    : _PlayingView(
                        engine: _engine,
                        controller: _controller,
                        focusNode: _focusNode,
                        showWrongFlash: _showWrongFlash,
                        onSubmitted: _handleSubmit,
                        onSkip: _handleSkip,
                      ),
                if (_engine.lastMatchedCountry != null)
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        opacity: _showCorrectPop ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: AnimatedScale(
                          scale: _showCorrectPop ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.elasticOut,
                          child: Text(
                            _engine.lastMatchedCountry!.flagEmoji,
                            style: const TextStyle(fontSize: 96),
                          ),
                        ),
                      ),
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

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.engine,
    required this.controller,
    required this.focusNode,
    required this.showWrongFlash,
    required this.onSubmitted,
    required this.onSkip,
  });

  final AlphabetEngine engine;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showWrongFlash;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedbackColor = showWrongFlash ? AppColors.coral : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  'Letter ${engine.letterIndex + 1} / ${engine.totalLetters}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.greenDeep,
                  ),
                ),
                const Spacer(),
                Text(
                  'Score ${engine.correctCount * 100}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: engine.progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green,
                boxShadow: [
                  BoxShadow(
                    color: (feedbackColor ?? AppColors.green).withValues(
                      alpha: 0.4,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                engine.currentLetter,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Name a country starting with "${engine.currentLetter}"',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: feedbackColor == null
                  ? null
                  : [
                      BoxShadow(
                        color: feedbackColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              style: theme.textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: 'Type a country…',
                filled: true,
                fillColor: AppColors.green.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.green,
                  ),
                  onPressed: () => onSubmitted(controller.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onSkip,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.orange,
              side: const BorderSide(color: AppColors.orange, width: 1.5),
            ),
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('Skip this letter'),
          ),
        ],
      ),
    );
  }
}
