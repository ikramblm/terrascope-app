import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../games/presentation/widgets/game_category_style.dart';
import '../../../games/domain/game_category.dart';
import '../../domain/game_result.dart';
import '../../sound/sound_service.dart';
import '../name_engine.dart';
import 'name_results_view.dart';

/// Generic screen for every "type as many countries as you can" mode —
/// [NameEngine] carries the pool/timer differences; this screen is the
/// same input-and-chips UI for all of them.
class NameGameScreen extends StatefulWidget {
  const NameGameScreen({
    super.key,
    required this.title,
    required this.instructions,
    required this.engineBuilder,
    required this.onSessionComplete,
  });

  final String title;
  final String instructions;
  final NameEngine Function() engineBuilder;
  final void Function(GameResult result) onSessionComplete;

  @override
  State<NameGameScreen> createState() => _NameGameScreenState();
}

enum _FeedbackKind { none, correct, duplicate, wrong }

class _NameGameScreenState extends State<NameGameScreen> {
  late NameEngine _engine;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _resultRecorded = false;
  _FeedbackKind _feedback = _FeedbackKind.none;

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

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    final matched = _engine.submit(text);
    _controller.clear();
    setState(() {
      _feedback = matched
          ? _FeedbackKind.correct
          : (_engine.lastSubmitWasDuplicate
                ? _FeedbackKind.duplicate
                : _FeedbackKind.wrong);
    });
    if (matched) {
      HapticFeedback.lightImpact();
      SoundService.instance.playCorrect();
    } else if (_feedback == _FeedbackKind.wrong) {
      HapticFeedback.mediumImpact();
      SoundService.instance.playWrong();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _feedback = _FeedbackKind.none);
    });
    _focusNode.requestFocus();
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: MaxWidthBox(
          child: _engine.isComplete
              ? NameResultsView(engine: _engine, onPlayAgain: _playAgain)
              : _PlayingView(
                  engine: _engine,
                  instructions: widget.instructions,
                  controller: _controller,
                  focusNode: _focusNode,
                  feedback: _feedback,
                  onSubmitted: _handleSubmit,
                ),
        ),
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.engine,
    required this.instructions,
    required this.controller,
    required this.focusNode,
    required this.feedback,
    required this.onSubmitted,
  });

  final NameEngine engine;
  final String instructions;
  final TextEditingController controller;
  final FocusNode focusNode;
  final _FeedbackKind feedback;
  final ValueChanged<String> onSubmitted;

  Color? _feedbackColor(BuildContext context) {
    switch (feedback) {
      case _FeedbackKind.correct:
        return AppColors.green;
      case _FeedbackKind.duplicate:
        return AppColors.orange;
      case _FeedbackKind.wrong:
        return AppColors.coral;
      case _FeedbackKind.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentForCategory(GameCategory.name);
    final feedbackColor = _feedbackColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(instructions, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${engine.foundCount} / ${engine.totalCount}',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Text('found', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: engine.progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: accent,
            ),
          ),
          if (engine.timeLimit != null) ...[
            const SizedBox(height: 12),
            _TimeBar(
              remaining: engine.timeRemaining!,
              total: engine.timeLimit!,
            ),
          ],
          const SizedBox(height: 16),
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
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => onSubmitted(controller.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (engine.timeLimit == null)
            OutlinedButton.icon(
              onPressed: engine.finish,
              icon: const Icon(Icons.flag_rounded),
              label: const Text("I'm Done"),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: engine.foundCount == 0
                ? Center(
                    child: Text(
                      'Countries you find will appear here.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final country in engine.foundCountriesSorted)
                          Chip(
                            label: Text(country.nameCommon),
                            backgroundColor: AppColors.green.withValues(
                              alpha: 0.12,
                            ),
                            side: BorderSide.none,
                            avatar: const Icon(
                              Icons.check_circle,
                              color: AppColors.green,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A compact countdown bar for the total-session timer (as opposed to
/// [TimerBar], which is per-question) — urgent-red under 25% remaining.
class _TimeBar extends StatelessWidget {
  const _TimeBar({required this.remaining, required this.total});

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final urgent = fraction <= 0.25;
    final seconds = remaining.inSeconds.clamp(0, 1 << 30);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: urgent
                  ? theme.colorScheme.error
                  : theme.colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${seconds}s',
          style: theme.textTheme.labelLarge?.copyWith(
            color: urgent
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
