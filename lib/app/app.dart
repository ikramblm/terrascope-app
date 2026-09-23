import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/game_engine/sound/sound_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TerraScopeApp extends ConsumerWidget {
  const TerraScopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TerraScope',
      debugShowCheckedModeBanner: false,
      // Light is the one, primary theme now — see AppTheme's doc comment.
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider),
      // A `Listener` (not a `GestureDetector`) on purpose: it doesn't
      // enter the gesture arena, so it can never steal or delay a tap
      // from the button/card underneath — it just overhears every
      // pointer-down anywhere in the app and fires the click blip.
      // SoundService.playTap() itself no-ops when muted.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => SoundService.instance.playTap(),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
