import 'package:flutter/material.dart';

/// Score / question-progress readout shown above every multiple-choice
/// question. The combo indicator used to live here as a small corner
/// pill — it's now [ComboBanner], shown full-width just above the
/// question itself, since a streak bonus is worth more than a corner
/// badge's worth of attention.
///
/// The score rolls up to its new value instead of jumping — small detail,
/// but it's the difference between a number changing and a number
/// *earning* itself.
class ScoreHeader extends StatelessWidget {
  const ScoreHeader({
    super.key,
    required this.score,
    required this.questionNumber,
    required this.totalQuestions,
    this.centerLabel,
  });

  final int score;
  final int questionNumber;
  final int totalQuestions;

  /// Overrides the default "Question X / Y" center readout — speed
  /// modes show a streak count or countdown here instead, since the
  /// underlying question pool size isn't a meaningful target for them.
  final String? centerLabel;

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
              builder: (context, value, _) =>
                  Text('${value.round()}', style: theme.textTheme.titleLarge),
            ),
          ],
        ),
        Text(
          centerLabel ?? 'Question $questionNumber / $totalQuestions',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
