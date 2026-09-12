import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/app/app.dart';
import 'package:terrascope_app/data/countries/providers/country_providers.dart';
import 'package:terrascope_app/data/countries/repositories/country_repository.dart';
import 'package:terrascope_app/features/game_engine/presentation/widgets/answer_option_button.dart';
import 'package:terrascope_app/features/games/guess_emoji/data/emoji_clue_repository.dart';
import 'package:terrascope_app/features/games/guess_emoji/providers/emoji_clue_providers.dart';

import 'support/sync_test_asset_bundle.dart';

/// Every test boots the real app but with asset-backed repositories swapped
/// for a synchronous test bundle — see [SyncTestAssetBundle] for why: real
/// asset I/O never resolves inside `testWidgets`' FakeAsync-driven pump
/// loop, only a synchronous Future does.
Widget buildTestApp() {
  final bundle = SyncTestAssetBundle();
  return ProviderScope(
    overrides: [
      countryRepositoryProvider.overrideWithValue(CountryRepository(bundle: bundle)),
      emojiClueRepositoryProvider.overrideWithValue(EmojiClueRepository(bundle: bundle)),
    ],
    child: const TerraScopeApp(),
  );
}

void main() {
  testWidgets('TerraScope boots to Home with bottom navigation', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('TerraScope'), findsOneWidget);
    expect(find.text('Quick Play'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    // The real 195-country dataset loaded — not a stub/mock count.
    expect(find.textContaining('195 countries loaded'), findsOneWidget);
  });

  testWidgets('Games tab lists the full catalog, unavailable modes marked Soon', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();

    // Guess by Flag and Guess by Emoji are playable now (Phase 2) — no
    // "Soon" badge on their cards.
    expect(find.text('Guess by Flag'), findsOneWidget);
    expect(find.text('Guess by Emoji'), findsOneWidget);
    // Everything else in the catalog is still honestly marked unavailable.
    expect(find.text('Soon'), findsWidgets);
  });

  testWidgets('Guess by Flag: pick a difficulty, answer, reach results', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guess by Flag'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Easy'));
    // Not pumpAndSettle from here: the per-question countdown timer keeps
    // scheduling frames for the full 12s (easy), so it never "settles"
    // mid-question — pump a bounded, fixed amount instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // In the game: a score header and a timer should be visible immediately.
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.textContaining('Question 1 /'), findsOneWidget);

    // Answer all 10 questions (whichever option — engine records the
    // outcome either way) until the results view appears.
    for (var i = 0; i < 10; i++) {
      final optionFinder = find.byType(AnswerOptionButton).first;
      await tester.tap(optionFinder, warnIfMissed: false);
      // Feedback delay + rebuild.
      await tester.pump(const Duration(milliseconds: 1300));
    }
    // Not pumpAndSettle: the confetti package keeps an idle ticker running
    // once its widget has been mounted (even with no particles active),
    // so it never reports "settled" — bounded pumps instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Game Complete'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Back to Games'), findsOneWidget);
  });

  testWidgets('Guess by Emoji: pick a difficulty and see a question', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guess by Emoji'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byType(AnswerOptionButton), findsNWidgets(4));
  });
}
