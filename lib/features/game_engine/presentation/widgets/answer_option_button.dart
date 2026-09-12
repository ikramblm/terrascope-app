import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../data/countries/models/country.dart';

enum AnswerOptionState { idle, correct, incorrectSelected, incorrectOther }

/// One tappable answer choice. Reused by every multiple-choice mode —
/// only the label changes (always a country name here).
///
/// Reacts to its own state transitions: a satisfying scale+glow pulse on
/// [AnswerOptionState.correct], a sharp shake on
/// [AnswerOptionState.incorrectSelected] — the feedback a guessing game
/// lives or dies by.
class AnswerOptionButton extends StatefulWidget {
  const AnswerOptionButton({
    super.key,
    required this.country,
    required this.state,
    required this.onTap,
  });

  final Country country;
  final AnswerOptionState state;
  final VoidCallback? onTap;

  @override
  State<AnswerOptionButton> createState() => _AnswerOptionButtonState();
}

class _AnswerOptionButtonState extends State<AnswerOptionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant AnswerOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == widget.state) return;
    if (widget.state == AnswerOptionState.correct ||
        widget.state == AnswerOptionState.incorrectSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background = theme.colorScheme.surfaceContainerHighest;
    Color border = theme.colorScheme.outline;
    Color foreground = theme.colorScheme.onSurface;
    Widget? trailingIcon;
    Color? glowColor;

    switch (widget.state) {
      case AnswerOptionState.idle:
        break;
      case AnswerOptionState.correct:
        background = theme.colorScheme.secondary.withValues(alpha: 0.18);
        border = theme.colorScheme.secondary;
        foreground = theme.colorScheme.secondary;
        trailingIcon = Icon(Icons.check_circle, color: theme.colorScheme.secondary);
        glowColor = theme.colorScheme.secondary;
      case AnswerOptionState.incorrectSelected:
        background = theme.colorScheme.error.withValues(alpha: 0.18);
        border = theme.colorScheme.error;
        foreground = theme.colorScheme.error;
        trailingIcon = Icon(Icons.cancel, color: theme.colorScheme.error);
      case AnswerOptionState.incorrectOther:
        foreground = theme.colorScheme.onSurfaceVariant;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final offsetX = widget.state == AnswerOptionState.incorrectSelected ? _shake(t) : 0.0;
        final scale = widget.state == AnswerOptionState.correct ? _pulse(t) : 1.0;

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: widget.state == AnswerOptionState.idle ? 1 : 1.5),
          boxShadow: glowColor == null
              ? null
              : [BoxShadow(color: glowColor.withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 1)],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.country.nameCommon,
                      style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                    ),
                  ),
                  ?trailingIcon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Decaying horizontal oscillation — a sharp "no" shake.
  double _shake(double t) {
    if (t >= 1) return 0;
    final decay = 1 - t;
    return sin(t * pi * 8) * 10 * decay;
  }

  /// Quick overshoot-and-settle scale — a satisfying "yes" pop.
  double _pulse(double t) {
    if (t >= 1) return 1;
    const curve = Curves.elasticOut;
    return 1 + curve.transform(t) * 0.06;
  }
}
