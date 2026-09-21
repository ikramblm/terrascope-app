import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

const Map<String, Color> _continentColors = {
  'Africa': AppColors.continentAfrica,
  'Asia': AppColors.continentAsia,
  'Europe': AppColors.continentEurope,
  'North America': AppColors.continentNorthAmerica,
  'South America': AppColors.continentSouthAmerica,
  'Oceania': AppColors.continentOceania,
};

/// The Radar power-up's reveal: which continent the answer is on —
/// shown before answering, a coarser hint than [AnswerRevealInset]'s
/// full silhouette (which only ever appears after), so it narrows the
/// question down without handing away the answer outright.
class RadarReveal extends StatelessWidget {
  const RadarReveal({super.key, required this.continent});

  final String continent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _continentColors[continent] ?? AppColors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            continent,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
