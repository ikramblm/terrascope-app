import 'package:flutter/material.dart';

/// Score / question-progress / combo readout shown above every
/// multiple-choice question.
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
            Text('$score', style: theme.textTheme.titleLarge),
          ],
        ),
        Text(
          'Question $questionNumber / $totalQuestions',
          style: theme.textTheme.bodyMedium,
        ),
        AnimatedOpacity(
          opacity: combo >= 2 ? 1 : 0,
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
                  '${combo}x',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.tertiary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
