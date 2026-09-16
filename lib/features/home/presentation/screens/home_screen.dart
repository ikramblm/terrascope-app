import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../games/data/game_catalog.dart';
import '../widgets/game_mode_button.dart';
import '../widgets/world_map_banner.dart';

/// Home: a big colorful "this is a geography game" visual, then a short,
/// clean list of large mode buttons. Deliberately nothing else — no
/// stats, no cards, no secondary sections competing for attention.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _buttonColors = [
    AppColors.oceanBlue,
    AppColors.green,
    AppColors.orange,
    AppColors.coral,
    AppColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final featuredModes = kGameCatalog.where((m) => m.isAvailable).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            FadeSlideIn(index: 0, child: const WorldMapBanner(title: 'TerraScope')),
            const SizedBox(height: 24),
            for (final (i, mode) in featuredModes.indexed) ...[
              FadeSlideIn(
                index: i + 1,
                child: GameModeButton(
                  label: mode.title,
                  icon: mode.icon,
                  color: _buttonColors[i % _buttonColors.length],
                  onTap: () => context.push(mode.routePath!),
                ),
              ),
              const SizedBox(height: 14),
            ],
            FadeSlideIn(
              index: featuredModes.length + 1,
              child: GameModeButton(
                label: 'Explore All Games',
                icon: Icons.explore_rounded,
                color: _buttonColors[featuredModes.length % _buttonColors.length],
                onTap: () => context.go(RoutePaths.games),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
