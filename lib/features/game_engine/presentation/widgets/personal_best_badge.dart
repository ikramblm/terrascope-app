import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A bright, unmissable badge shown only when this session's score
/// actually matches the player's all-time best — never shown
/// speculatively, so it stays a real signal.
class PersonalBestBadge extends StatelessWidget {
  const PersonalBestBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'NEW PERSONAL BEST',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
