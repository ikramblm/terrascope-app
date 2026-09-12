import 'package:flutter/material.dart';

/// Countdown bar for the current question — shrinks smoothly and turns
/// urgent-red once under 25% of the allotted time.
class TimerBar extends StatelessWidget {
  const TimerBar({super.key, required this.remaining, required this.total});

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final urgent = fraction <= 0.25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: fraction, end: fraction),
        duration: const Duration(milliseconds: 120),
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: theme.colorScheme.outlineVariant,
          color: urgent ? theme.colorScheme.error : theme.colorScheme.secondary,
        ),
      ),
    );
  }
}
