import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../data/countries/models/country.dart';

enum AnswerOptionState { idle, correct, incorrectSelected, incorrectOther }

/// One tappable answer choice — Kahoot-style: each of the 4 option slots
/// has a fixed color and shape (triangle/diamond/circle/square) regardless
/// of content, so players can tell options apart by color+shape alone,
/// not just by reading text. Reused by every multiple-choice mode.
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
    required this.slotIndex,
  });

  final Country country;
  final AnswerOptionState state;
  final VoidCallback? onTap;

  /// Position among this question's options (0-3) — picks the fixed
  /// slot color/shape.
  final int slotIndex;

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
    final slotColor = AppColors.answerSlotColors[widget.slotIndex % AppColors.answerSlotColors.length];
    final slotIcon = AppColors.answerSlotIcons[widget.slotIndex % AppColors.answerSlotIcons.length];

    Color background;
    Color foreground;
    Color shapeColor = slotColor;
    Color shapeBg = Colors.white;
    IconData trailingIcon = slotIcon;
    Color? glowColor;
    double opacity = 1;

    switch (widget.state) {
      case AnswerOptionState.idle:
        background = slotColor.withValues(alpha: 0.10);
        foreground = theme.colorScheme.onSurface;
      case AnswerOptionState.correct:
        background = AppColors.green;
        foreground = Colors.white;
        shapeColor = AppColors.green;
        shapeBg = Colors.white;
        trailingIcon = Icons.check_rounded;
        glowColor = AppColors.green;
      case AnswerOptionState.incorrectSelected:
        background = AppColors.coral;
        foreground = Colors.white;
        shapeColor = AppColors.coral;
        shapeBg = Colors.white;
        trailingIcon = Icons.close_rounded;
      case AnswerOptionState.incorrectOther:
        background = slotColor.withValues(alpha: 0.10);
        foreground = theme.colorScheme.onSurfaceVariant;
        opacity = 0.5;
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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: glowColor == null
                ? null
                : [BoxShadow(color: glowColor.withValues(alpha: 0.4), blurRadius: 18, spreadRadius: 1)],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: shapeBg, shape: BoxShape.circle),
                      child: Icon(trailingIcon, color: shapeColor, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.country.nameCommon,
                        style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
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
