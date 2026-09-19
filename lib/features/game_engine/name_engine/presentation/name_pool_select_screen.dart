import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_box.dart';
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
      appBar: AppBar(title: Text(title)),
      body: MaxWidthBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _OptionTile(
                    option: option,
                    onTap: option.pool.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NameGameScreen(
                                  title: gameTitleFor(option),
                                  instructions: instructionsFor(option),
                                  engineBuilder: () => NameEngine(pool: option.pool),
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
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option, required this.onTap});

  final NamePoolOption option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = option.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(width: 5, height: 68, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(option.icon, color: accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.label, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(option.subtitle, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: onTap == null ? theme.colorScheme.outline : accent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
