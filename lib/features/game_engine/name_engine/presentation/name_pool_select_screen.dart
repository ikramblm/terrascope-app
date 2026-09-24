import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/color_back_button.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../data/countries/models/country.dart';
import '../../domain/game_result.dart';
import '../name_engine.dart';
import 'name_game_screen.dart';

/// One selectable filter on a [NamePoolSelectScreen] — a colorful tile
/// that, when tapped, launches [NameGameScreen] scoped to [pool].
class NamePoolOption {
  const NamePoolOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pool,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Country> pool;
}

/// Shared "pick a scope, then name as many as you can within it" picker
/// — Name by Continent, Name by Category, and Name by Letter are all
/// just a different [options] list over this one screen.
class NamePoolSelectScreen extends StatelessWidget {
  const NamePoolSelectScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.options,
    required this.gameTitleFor,
    required this.instructionsFor,
    required this.onSessionComplete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<NamePoolOption> options;
  final String Function(NamePoolOption option) gameTitleFor;
  final String Function(NamePoolOption option) instructionsFor;
  final void Function(GameResult result) onSessionComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title), leading: const ColorBackButton()),
      body: AppBackground(
        child: MaxWidthBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greenDeep.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return OptionTile(
                        title: option.label,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        color: option.color,
                        onTap: option.pool.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NameGameScreen(
                                    title: gameTitleFor(option),
                                    instructions: instructionsFor(option),
                                    engineBuilder: () =>
                                        NameEngine(pool: option.pool),
                                    onSessionComplete: onSessionComplete,
                                  ),
                                ),
                              ),
                      );
                    },
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
