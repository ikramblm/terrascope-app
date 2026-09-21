import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../data/game_catalog.dart';
import '../../domain/game_category.dart';
import '../../domain/game_mode.dart';
import '../widgets/explore_hero_shape.dart';
import 'game_category_screen.dart';

/// Explore, reorganized into categories instead of one long flat grid —
/// Guessing, Naming, Speed, and a cross-cutting Soon bucket that pulls
/// together every not-yet-shipped mode regardless of its own category,
/// so "what's coming next" is always one tap away.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soon = kGameCatalog.where((m) => !m.isAvailable).toList();

    final categories = [
      _ExploreCategory(
        title: 'Guessing',
        subtitle:
            '${kGameCatalog.where((m) => m.category == GameCategory.guess).length} games',
        icon: Icons.travel_explore_rounded,
        color: AppColors.oceanBlue,
        modes: kGameCatalog
            .where((m) => m.category == GameCategory.guess)
            .toList(),
      ),
      _ExploreCategory(
        title: 'Naming',
        subtitle:
            '${kGameCatalog.where((m) => m.category == GameCategory.name).length} games',
        icon: Icons.abc_rounded,
        color: AppColors.green,
        modes: kGameCatalog
            .where((m) => m.category == GameCategory.name)
            .toList(),
      ),
      _ExploreCategory(
        title: 'Speed',
        subtitle:
            '${kGameCatalog.where((m) => m.category == GameCategory.speed).length} games',
        icon: Icons.bolt_rounded,
        color: AppColors.orange,
        modes: kGameCatalog
            .where((m) => m.category == GameCategory.speed)
            .toList(),
      ),
      _ExploreCategory(
        title: 'Soon',
        subtitle: '${soon.length} upcoming',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.purple,
        modes: soon,
      ),
    ];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: MaxWidthBox(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text('Explore', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  'Pick a category to find your next game.',
                  style: theme.textTheme.bodyMedium,
                ),
                const ExploreHeroShape(),
                const SizedBox(height: 8),
                FadeSlideIn(
                  index: 0,
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent: 140,
                        ),
                    children: [
                      for (final category in categories)
                        _CategoryCard(
                          category: category,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GameCategoryScreen(
                                title: category.title,
                                subtitle: category.title == 'Soon'
                                    ? 'Every mode still in the works, all in one place.'
                                    : 'All ${category.title.toLowerCase()} modes in one place.',
                                modes: category.modes,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _ExploreCategory {
  const _ExploreCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.modes,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<GameMode> modes;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final _ExploreCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(category.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                category.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
