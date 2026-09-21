import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../player/domain/power_up.dart';
import '../../../player/providers/player_providers.dart';

/// Three consumable lifelines shown above the answer grid — each tile
/// shows its remaining free count, and still lights up after that if
/// the player has enough coins to buy one more use on the spot.
class PowerUpTray extends ConsumerWidget {
  const PowerUpTray({
    super.key,
    required this.onFiftyFifty,
    required this.onTimeFreeze,
    required this.onRadar,
    this.fiftyFiftyAvailable = true,
    this.radarAvailable = true,
  });

  final VoidCallback onFiftyFifty;
  final VoidCallback onTimeFreeze;
  final VoidCallback onRadar;

  /// 50/50 and Radar only make sense once per question (there's nothing
  /// left to eliminate or reveal a second time); Time Freeze has no such
  /// cap — stacking it just runs into [MultipleChoiceEngine.addTime]'s
  /// own ceiling at the question's full allotted time.
  final bool fiftyFiftyAvailable;
  final bool radarAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: _PowerUpButton(
            type: PowerUpType.fiftyFifty,
            count: profile.fiftyFiftyCount,
            enabled:
                fiftyFiftyAvailable && notifier.canUse(PowerUpType.fiftyFifty),
            onTap: () {
              if (notifier.usePowerUp(PowerUpType.fiftyFifty)) onFiftyFifty();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PowerUpButton(
            type: PowerUpType.timeFreeze,
            count: profile.timeFreezeCount,
            enabled: notifier.canUse(PowerUpType.timeFreeze),
            onTap: () {
              if (notifier.usePowerUp(PowerUpType.timeFreeze)) onTimeFreeze();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PowerUpButton(
            type: PowerUpType.radar,
            count: profile.radarCount,
            enabled: radarAvailable && notifier.canUse(PowerUpType.radar),
            onTap: () {
              if (notifier.usePowerUp(PowerUpType.radar)) onRadar();
            },
          ),
        ),
      ],
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({
    required this.type,
    required this.count,
    required this.enabled,
    required this.onTap,
  });

  final PowerUpType type;
  final int count;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled
        ? AppColors.ctaCyan
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: enabled ? 0.65 : 0.3,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? AppColors.ctaCyan.withValues(alpha: 0.4)
                  : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Icon(type.icon, size: 20, color: foreground),
              const SizedBox(height: 4),
              Text(
                count > 0 ? '$count' : '${type.coinCost}c',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
