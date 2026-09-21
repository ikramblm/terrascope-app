import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../player/providers/player_providers.dart';
import '../../domain/game_mode.dart';
import '../widgets/game_mode_card.dart';

/// One flat grid of game modes, scoped to a single Explore category
/// (Guessing, Naming, Speed, or Soon). Pushed from [GamesScreen]'s
/// category tiles — the same card grid the old flat Explore screen
/// used, just filtered to one category at a time.
const _cardColors = [
  AppColors.oceanBlue,
  AppColors.skyBlue,
  AppColors.green,
  AppColors.yellow,
  AppColors.orange,
  AppColors.coral,
  AppColors.purple,
];

class GameCategoryScreen extends ConsumerWidget {
  const GameCategoryScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.modes,
  });

  final String title;
  final String subtitle;
  final List<GameMode> modes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playerLevel = ref.watch(
      playerProfileProvider.select((p) => p.numericLevel),
    );
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppBackground(
        child: MaxWidthBox(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 156,
                ),
                children: [
                  for (final (i, mode) in modes.indexed)
                    _modeCard(
                      context,
                      mode,
                      _cardColors[i % _cardColors.length],
                      playerLevel,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

GameModeCard _modeCard(
  BuildContext context,
  GameMode mode,
  Color color,
  int playerLevel,
) {
  final required = mode.requiredLevel;
  final lockedUntilLevel = required != null && playerLevel < required
      ? required
      : null;
  final unlocked = mode.isAvailable && lockedUntilLevel == null;
  return GameModeCard(
    mode: mode,
    color: color,
    lockedUntilLevel: lockedUntilLevel,
    onTap: unlocked ? () => context.push(mode.routePath!) : null,
  );
}
