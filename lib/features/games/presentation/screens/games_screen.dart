import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../data/game_catalog.dart';
import '../../domain/game_mode.dart';
import '../widgets/explore_hero_shape.dart';
import '../widgets/game_mode_card.dart';

/// One flat grid of every game mode — no category headers or grouping.
/// Color alone (cycled across this fixed palette) tells modes apart;
/// simplicity was explicitly the point here, not information density.
const _cardColors = [
  AppColors.oceanBlue,
  AppColors.skyBlue,
  AppColors.green,
  AppColors.yellow,
  AppColors.orange,
  AppColors.coral,
  AppColors.purple,
];

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text('Explore', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('Pick a mode and start playing.', style: theme.textTheme.bodyMedium),
              const ExploreHeroShape(),
              const SizedBox(height: 8),
              FadeSlideIn(
                index: 0,
                child: GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 156,
                  ),
                  children: [
                    for (final (i, mode) in kGameCatalog.indexed)
                      GameModeCard(
                        mode: mode,
                        color: _cardColors[i % _cardColors.length],
                        onTap: mode.isAvailable ? () => _openMode(context, mode) : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMode(BuildContext context, GameMode mode) {
    context.push(mode.routePath!);
  }
}
