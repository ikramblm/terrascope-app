import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../player/providers/player_providers.dart';

/// Home's top card — the single highest-value daily-return hook in the
/// app, so it sits above even the featured game buttons. Shows whether
/// today's challenge is still open or already played, rather than
/// always inviting a tap that leads nowhere new.
class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(playerProfileProvider);
    final done = profile.hasCompletedDailyChallengeOn(DateTime.now());

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push(RoutePaths.dailyChallenge),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: done
                ? null
                : const LinearGradient(
                    colors: [AppColors.ctaCyan, AppColors.ctaViolet],
                  ),
            color: done ? theme.colorScheme.surfaceContainerHighest : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: done
                ? null
                : [
                    BoxShadow(
                      color: AppColors.ctaCyan.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      (done ? theme.colorScheme.onSurfaceVariant : Colors.white)
                          .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  done ? Icons.check_rounded : Icons.today_rounded,
                  color: done
                      ? theme.colorScheme.onSurfaceVariant
                      : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done ? 'Daily Challenge complete' : 'Daily Challenge',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: done ? null : Colors.white,
                      ),
                    ),
                    Text(
                      done ? 'A new one lands tomorrow' : '5 flags, once a day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: done
                            ? null
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: done
                    ? theme.colorScheme.onSurfaceVariant
                    : Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
