import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A full-width, fiery "combo" callout shown directly above the active
/// question once the player has 2+ correct answers in a row — the
/// brief's "prominent 3X MULTIPLIER badge," not a small corner pill.
/// Reserves its own height even when hidden so the question below it
/// doesn't jump up and down as a streak starts and breaks.
class ComboBanner extends StatelessWidget {
  const ComboBanner({super.key, required this.combo});

  final int combo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = combo >= 2;

    return SizedBox(
      height: 40,
      child: visible
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.orange, AppColors.comboFlame],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.comboFlame.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${combo}X MULTIPLIER',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
