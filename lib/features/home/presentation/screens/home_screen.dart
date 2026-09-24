import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../games/data/game_catalog.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/game_mode_button.dart';
import '../widgets/world_map_banner.dart';

/// Home: a big colorful "this is a geography game" visual, then a short,
/// clean list of large mode buttons. Deliberately nothing else — no
/// stats, no cards, no secondary sections competing for attention.
///
/// Only the headline modes appear here — every other mode lives one tap
/// away in Explore, organized by category.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _featuredIds = [
    'guess_emoji',
    'guess_flag',
    'guess_outline',
    'name_alphabet',
  ];

  static const _buttonColors = [
    AppColors.oceanBlue,
    AppColors.green,
    AppColors.orange,
    AppColors.skyBlue,
  ];

  @override
  Widget build(BuildContext context) {
    final featuredModes = [
      for (final id in _featuredIds) kGameCatalog.firstWhere((m) => m.id == id),
    ].where((m) => m.isAvailable).toList();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: MaxWidthBox(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              children: [
                FadeSlideIn(
                  index: 0,
                  child: const WorldMapBanner(title: 'TerraScope'),
                ),
                const SizedBox(height: 16),
                const FadeSlideIn(index: 1, child: DailyChallengeCard()),
                const SizedBox(height: 16),
                for (final (i, mode) in featuredModes.indexed) ...[
                  FadeSlideIn(
                    index: i + 2,
                    child: GameModeButton(
                      label: mode.title,
                      icon: mode.icon,
                      color: _buttonColors[i % _buttonColors.length],
                      logoBuilder: mode.logoBuilder,
                      onTap: () => context.push(mode.routePath!),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                FadeSlideIn(
                  index: featuredModes.length + 2,
                  child: GameModeButton(
                    label: 'Explore All Games',
                    icon: Icons.explore_rounded,
                    color: AppColors.purple,
                    onTap: () => context.go(RoutePaths.games),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
