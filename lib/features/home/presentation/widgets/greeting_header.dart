import 'package:flutter/material.dart';

/// Home screen's top row: a time-of-day greeting plus settings — plain
/// and light, deliberately not competing with the Play hero card below
/// it for visual weight.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.levelLabel, required this.onSettingsTap});

  final String levelLabel;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: theme.textTheme.headlineLarge),
            const SizedBox(height: 2),
            Text(levelLabel, style: theme.textTheme.bodyMedium),
          ],
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 18) return 'Good afternoon!';
    return 'Good evening!';
  }
}
