import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Countdown for the current question — a row of blocks instead of one
/// solid bar. Segments disappear one at a time as time runs out, and the
/// whole bar ramps green -> orange -> red as it empties, so "how much
/// time is left" reads at a glance from color alone, not just count.
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
    final filledCount = (fraction * _segmentCount).ceil().clamp(
      0,
      _segmentCount,
    );
    final color = fraction > 0.6
        ? AppColors.green
        : fraction > 0.25
        ? AppColors.orange
        : theme.colorScheme.error;

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
