import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Home screen's gradient hero band: title, tagline, settings action, and
/// a translucent decorative globe for visual depth — no image assets
/// needed, just gradients + a blurred glow + one icon.
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
            colors: [AppColors.indigo, Color(0xFF3A2E8F)],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft glow blob, top-right.
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.18),
                ),
              ),
            ),
            // Translucent globe, bottom-right, tilted for a bit of energy.
            Positioned(
              bottom: -30,
              right: -10,
              child: Transform.rotate(
                angle: -0.35,
                child: Icon(
                  Icons.public,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
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
}
