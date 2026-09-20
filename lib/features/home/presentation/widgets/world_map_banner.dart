import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Home screen's top visual: an abstract "world map" made of a handful
/// of large, overlapping colorful blob shapes (never a literal map, and
/// never realistic continents) — a single glance should read
/// "geography game," nothing more literal than that.
class WorldMapBanner extends StatelessWidget {
  const WorldMapBanner({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.oceanBlue),
            _blob(
              top: -60,
              left: -50,
              size: 200,
              color: AppColors.orange,
              radius: 90,
            ),
            _blob(
              top: -40,
              right: -60,
              size: 190,
              color: AppColors.coral,
              radius: 100,
            ),
            _blob(
              bottom: -70,
              right: -50,
              size: 210,
              color: AppColors.green,
              radius: 95,
            ),
            _blob(
              bottom: -90,
              left: -70,
              size: 220,
              color: AppColors.skyBlue,
              radius: 100,
            ),
            _blob(
              bottom: -60,
              left: 90,
              size: 130,
              color: AppColors.purple,
              radius: 60,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double radius,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
