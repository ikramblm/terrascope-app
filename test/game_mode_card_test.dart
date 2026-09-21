import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/app/theme/app_theme.dart';
import 'package:terrascope_app/features/games/domain/game_category.dart';
import 'package:terrascope_app/features/games/domain/game_mode.dart';
import 'package:terrascope_app/features/games/presentation/widgets/game_mode_card.dart';

/// [GameMode.requiredLevel] has no real catalog entry using it yet (no
/// mode is currently shipped level-gated) — these tests build one
/// directly to prove [GameModeCard]'s level-gate rendering actually
/// works, distinct from its "not built yet" state.
Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(
    body: Center(child: SizedBox(width: 160, child: child)),
  ),
);

const _builtMode = GameMode(
  id: 'test_mode',
  category: GameCategory.guess,
  title: 'Test Mode',
  tagline: 'A built mode used only in tests',
  icon: Icons.public,
  routePath: '/test-mode',
  requiredLevel: 5,
);

const _unbuiltMode = GameMode(
  id: 'test_unbuilt',
  category: GameCategory.guess,
  title: 'Test Unbuilt',
  tagline: 'A never-built mode used only in tests',
  icon: Icons.public,
);

void main() {
  testWidgets(
    'a level-gated mode below the required level shows Lvl N, not Soon',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          GameModeCard(
            mode: _builtMode,
            color: Colors.blue,
            lockedUntilLevel: 5,
          ),
        ),
      );

      expect(find.text('Lvl 5'), findsOneWidget);
      expect(find.text('Soon'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    },
  );

  testWidgets(
    'a level-gated mode at/above the required level renders unlocked',
    (tester) async {
      await tester.pumpWidget(
        GestureDetector(
          onTap: () {},
          child: _wrap(
            GameModeCard(
              mode: _builtMode,
              color: Colors.blue,
              // Caller only passes lockedUntilLevel when the player
              // hasn't reached it yet — reached means null, same as an
              // ungated mode.
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Lvl 5'), findsNothing);
      expect(find.text('Soon'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byIcon(Icons.public), findsOneWidget);
    },
  );

  testWidgets('a not-yet-built mode still shows Soon, never a level number', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(GameModeCard(mode: _unbuiltMode, color: Colors.blue)),
    );

    expect(find.text('Soon'), findsOneWidget);
    expect(find.textContaining('Lvl'), findsNothing);
  });
}
