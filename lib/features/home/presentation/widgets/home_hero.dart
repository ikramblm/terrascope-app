import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/globe_grid.dart';

/// Home screen's gradient hero band: title, tagline, settings action, and
/// a translucent decorative globe for visual depth — no image assets
/// needed, just a gradient, a couple of glow blobs, and a procedurally
/// drawn globe grid.
///
/// Deliberately static (not a perpetually-spinning animation): an
/// always-repainting screen burns battery for no real payoff on a
/// barely-visible flourish, and it breaks `pumpAndSettle` in every test
/// that touches Home (which is every test — it's the initial route).
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.indigo, AppColors.grapePurple],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft glow blobs, in two different accent hues for variety.
            Positioned(
              top: -60,
              right: -40,
              child: _glowBlob(AppColors.emerald, 180),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: _glowBlob(AppColors.pink, 140),
            ),
            // Scattered accent dots — a playful, game-y touch.
            const Positioned(top: 18, right: 110, child: _Dot(color: AppColors.sunYellow, size: 8)),
            const Positioned(top: 64, right: 150, child: _Dot(color: AppColors.skyBlue, size: 6)),
            const Positioned(bottom: 60, right: 60, child: _Dot(color: AppColors.emerald, size: 7)),
            // Globe grid, bottom-right, tilted for a bit of energy.
            Positioned(
              bottom: -30,
              right: -10,
              child: Transform.rotate(
                angle: -0.2,
                child: GlobeGrid(size: 130, color: Colors.white.withValues(alpha: 0.22)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TerraScope',
                      style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore the world, one country at a time.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.7)),
    );
  }
}
