import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';

/// How long [SplashScreen] holds before moving on to Home. A provider
/// (not a bare constant) so `buildTestApp()` can override it to
/// [Duration.zero] — a real 2-second wall-clock wait in every widget
/// test would make the whole suite slow and `pumpAndSettle` unreliable
/// for a bare, non-animating `Future.delayed`.
final splashDurationProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// The very first thing the app shows: the logo and the app name, alone,
/// for a fixed beat, then a real navigation into Home — no interaction,
/// nothing to wait on beyond the timer itself.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(ref.read(splashDurationProvider), () {
      if (mounted) context.go(RoutePaths.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.oceanBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.oceanBlueDeep.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.public_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            Text('TerraScope', style: theme.textTheme.displayMedium),
          ],
        ),
      ),
    );
  }
}
