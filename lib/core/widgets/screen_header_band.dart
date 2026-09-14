import 'package:flutter/material.dart';

import 'globe_grid.dart';

/// A compact colorful gradient header, shared by top-level tab screens
/// that don't use [HomeHero]'s bigger bespoke banner — keeps every tab
/// feeling like part of the same colorful game rather than Home being
/// the only screen with any visual identity and everything else falling
/// back to a flat `AppBar`.
class ScreenHeaderBand extends StatelessWidget {
  const ScreenHeaderBand({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -40,
              right: -20,
              child: GlobeGrid(size: 90, color: Colors.white.withValues(alpha: 0.18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
