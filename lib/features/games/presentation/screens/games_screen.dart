import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/fade_slide_in.dart';
import '../../data/game_catalog.dart';
import '../../domain/game_category.dart';
import '../../domain/game_mode.dart';
import '../widgets/game_mode_card.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final (i, category) in GameCategory.values.indexed) ...[
            FadeSlideIn(
              index: i,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryHeader(category: category),
                  const SizedBox(height: 12),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 140,
                    ),
                    children: [
                      for (final mode in kGameCatalog.where((m) => m.category == category))
                        GameModeCard(
                          mode: mode,
                          onTap: mode.isAvailable ? () => _openMode(context, mode) : null,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }

  void _openMode(BuildContext context, GameMode mode) {
    context.push(mode.routePath!);
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final GameCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category.label, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 2),
        Text(category.description, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
