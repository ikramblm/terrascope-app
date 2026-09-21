import 'package:flutter/material.dart';

import 'globe_grid.dart';

/// The dark theme's screen backdrop: the deep slate background plus one
/// large, faint, static globe-grid watermark behind the content — never
/// competing with it, just texture. Wraps a screen's body; the globe is
/// sized and positioned off the top-right edge so it reads as a subtle
/// presence in the corner of the eye, not a centered logo.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final globeSize = size.width * 1.6;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -globeSize * 0.32,
          right: -globeSize * 0.38,
          child: GlobeGrid(
            size: globeSize,
            color: theme.colorScheme.outline.withValues(alpha: 0.10),
            strokeWidth: 1.2,
          ),
        ),
        child,
      ],
    );
  }
}
