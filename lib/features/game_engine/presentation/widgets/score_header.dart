import 'package:flutter/material.dart';

/// Score / question-progress / combo readout shown above every
/// multiple-choice question.
///
/// The score rolls up to its new value instead of jumping — small detail,
/// but it's the difference between a number changing and a number
/// *earning* itself.
class ScoreHeader extends StatelessWidget {
  const ScoreHeader({
    super.key,
    required this.score,
    required this.combo,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final int score;
  final int combo;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SCORE', style: theme.textTheme.labelMedium),
            TweenAnimationBuilder<double>(
              tween: Tween(end: score.toDouble()),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '${value.round()}',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        Text(
          'Question $questionNumber / $totalQuestions',
          style: theme.textTheme.bodyMedium,
        ),
        _ComboBadge(combo: combo),
      ],
    );
  }
}

class _ComboBadge extends StatefulWidget {
  const _ComboBadge({required this.combo});

  final int combo;

  @override
  State<_ComboBadge> createState() => _ComboBadgeState();
}

class _ComboBadgeState extends State<_ComboBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void didUpdateWidget(covariant _ComboBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.combo > oldWidget.combo) {
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
    final visible = widget.combo >= 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bounce = 1 + Curves.elasticOut.transform(_controller.value) * 0.25 * (1 - _controller.value);
        return Transform.scale(scale: visible ? bounce.clamp(1.0, 1.3) : 1, child: child);
      },
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 2),
              Text(
                '${widget.combo}x',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.tertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
