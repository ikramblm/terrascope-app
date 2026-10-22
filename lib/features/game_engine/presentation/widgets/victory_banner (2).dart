import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The end-of-session headline — a bold banner plus a 3-star rating
/// (accuracy-based, never inflated) instead of a plain "results"
/// heading, so finishing a round feels like clearing a level.
class VictoryBanner extends StatelessWidget {
  const VictoryBanner({super.key, required this.title, required this.accuracy});

  final String title;

  /// In [0, 1]. Drives the star rating: 3 stars at 90%+, 2 at 60%+, 1 at
  /// 30%+, otherwise 0 — an honest reflection of how the round went, not
  /// a participation trophy.
  final double accuracy;

  int get _starsEarned {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.6) return 2;
    if (accuracy >= 0.3) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = _starsEarned;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.oceanBlue, AppColors.purple],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.oceanBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.star_rounded,
                    size: i == 1 ? 40 : 32,
                    color: i < stars
                        ? AppColors.yellow
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
