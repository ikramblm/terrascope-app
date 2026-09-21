import 'package:flutter/material.dart';

/// Countdown for the current question — a row of blocks instead of one
/// solid bar. Segments disappear one at a time as time runs out, so
/// "how much time is left" reads at a glance instead of requiring a
/// length comparison — and it turns urgent-red once under 25% remains.
class TimerBar extends StatelessWidget {
  const TimerBar({super.key, required this.remaining, required this.total});

  final Duration remaining;
  final Duration total;

  static const _segmentCount = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total.inMilliseconds == 0
        ? 0.0
        : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final urgent = fraction <= 0.25;
    final filledCount = (fraction * _segmentCount).ceil().clamp(
      0,
      _segmentCount,
    );
    final color = urgent
        ? theme.colorScheme.error
        : theme.colorScheme.secondary;

    return Row(
      children: [
        for (var i = 0; i < _segmentCount; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 8,
              decoration: BoxDecoration(
                color: i < filledCount
                    ? color
                    : theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
