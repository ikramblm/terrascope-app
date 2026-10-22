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
    // Rounds up so the label never flashes "0s" while a sliver of the
    // last segment is still showing.
    final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 1 << 30);

    return Row(
      children: [
        Expanded(
          child: Row(
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
          ),
        ),
        const SizedBox(width: 10),
        // The segmented bar alone drains the same visual way regardless
        // of how long the round actually is — this is what makes Medium
        // and Hard's shorter clocks (see GameDifficulty) actually read
        // as shorter, not just theoretically be shorter. A fixed-height
        // box keeps this label from ever nudging the row's total height
        // (and every fixed-height layout above it) — the game font's
        // line height runs tall enough at labelLarge to overflow some
        // of the more vertically packed screens by a pixel or two.
        SizedBox(
          height: 16,
          child: Text(
            '${seconds}s',
            style: theme.textTheme.labelSmall?.copyWith(
              color: fraction <= 0.25 ? theme.colorScheme.error : null,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
