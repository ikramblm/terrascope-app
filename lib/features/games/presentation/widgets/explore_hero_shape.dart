import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/globe_grid.dart';

/// Explore's top decoration: one big colorful pill shape with a globe
/// motif, a couple of small accent dots scattered around it — never a
/// full-bleed colored banner. The point is a clean white screen with
/// one confident splash of color at the top, not a wall of gradient.
class ExploreHeroShape extends StatelessWidget {
  const ExploreHeroShape({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: 8,
            left: 60,
            child: _Dot(color: AppColors.yellow, size: 14),
          ),
          const Positioned(
            bottom: 12,
            right: 56,
            child: _Dot(color: AppColors.coral, size: 10),
          ),
          const Positioned(
            top: 20,
            right: 70,
            child: _Dot(color: AppColors.purple, size: 8),
          ),
          Container(
            width: 240,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(65),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: GlobeGrid(
              size: 78,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
