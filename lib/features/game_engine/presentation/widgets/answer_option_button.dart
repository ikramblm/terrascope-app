import 'package:flutter/material.dart';

import '../../../../data/countries/models/country.dart';

enum AnswerOptionState { idle, correct, incorrectSelected, incorrectOther }

/// One tappable answer choice. Reused by every multiple-choice mode —
/// only the label changes (always a country name here).
class AnswerOptionButton extends StatelessWidget {
  const AnswerOptionButton({
    super.key,
    required this.country,
    required this.state,
    required this.onTap,
  });

  final Country country;
  final AnswerOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background = theme.colorScheme.surfaceContainerHighest;
    Color border = theme.colorScheme.outline;
    Color foreground = theme.colorScheme.onSurface;
    Widget? trailingIcon;

    switch (state) {
      case AnswerOptionState.idle:
        break;
      case AnswerOptionState.correct:
        background = theme.colorScheme.secondary.withValues(alpha: 0.18);
        border = theme.colorScheme.secondary;
        foreground = theme.colorScheme.secondary;
        trailingIcon = Icon(Icons.check_circle, color: theme.colorScheme.secondary);
      case AnswerOptionState.incorrectSelected:
        background = theme.colorScheme.error.withValues(alpha: 0.18);
        border = theme.colorScheme.error;
        foreground = theme.colorScheme.error;
        trailingIcon = Icon(Icons.cancel, color: theme.colorScheme.error);
      case AnswerOptionState.incorrectOther:
        foreground = theme.colorScheme.onSurfaceVariant;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    country.nameCommon,
                    style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                  ),
                ),
                ?trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
