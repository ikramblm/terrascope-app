import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/app/app.dart';
import 'package:terrascope_app/data/countries/providers/country_providers.dart';
import 'package:terrascope_app/data/countries/repositories/country_repository.dart';
import 'package:terrascope_app/features/game_engine/presentation/widgets/answer_option_button.dart';
import 'package:terrascope_app/features/games/guess_emoji/data/emoji_clue_repository.dart';
import 'package:terrascope_app/features/games/guess_emoji/providers/emoji_clue_providers.dart';
import 'package:terrascope_app/features/games/guess_outline/data/country_outline_repository.dart';
import 'package:terrascope_app/features/games/guess_outline/providers/country_outline_providers.dart';
import 'package:terrascope_app/features/player/data/player_profile_repository.dart';
import 'package:terrascope_app/features/player/providers/player_providers.dart';
import 'package:terrascope_app/features/splash/presentation/screens/splash_screen.dart';

import 'support/sync_test_asset_bundle.dart';

/// Every test boots the real app but with asset-backed repositories swapped
/// for a synchronous test bundle — see [SyncTestAssetBundle] for why: real
/// asset I/O never resolves inside `testWidgets`' FakeAsync-driven pump
/// loop, only a synchronous Future does.
Widget buildTestApp() {
  final bundle = SyncTestAssetBundle();
  return ProviderScope(
    overrides: [
      countryRepositoryProvider.overrideWithValue(
        CountryRepository(bundle: bundle),
      ),
      emojiClueRepositoryProvider.overrideWithValue(
        EmojiClueRepository(bundle: bundle),
      ),
      countryOutlineRepositoryProvider.overrideWithValue(
        CountryOutlineRepository(bundle: bundle),
      ),
      // `null` prefs: every test gets a fresh PlayerProfile with no
      // platform channel involved — see PlayerProfileRepository's doc
      // comment for why this constructor accepts null at all.
      playerProfileRepositoryProvider.overrideWithValue(
        const PlayerProfileRepository(null),
      ),
      // The real 2-second splash would make every test slow and leaves
      // pumpAndSettle waiting on a bare, non-animating Future.delayed —
      // zero here, a real duration only in the actual app.
      splashDurationProvider.overrideWithValue(Duration.zero),
    ],
    child: const TerraScopeApp(),
  );
}

/// Explore tab → tap a category tile → land on that category's grid.
Future<void> _openCategory(WidgetTester tester, String category) async {
  await tester.tap(find.text('Explore'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'TerraScope boots to Home with bottom navigation and only the featured modes',
    (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // The world-map banner title and bottom-nav destinations are the
      // anchors of the redesigned Home screen.
      expect(find.text('TerraScope'), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      // Only the three headline modes get a button — everything else lives
      // in Explore now.
      expect(find.text('Guess by Flag'), findsOneWidget);
      expect(find.text('Guess by Emoji'), findsOneWidget);
      // Outline is off the fold in the test viewport now that the Daily
      // Challenge card sits above the featured buttons — scroll to it.
      await tester.dragUntilVisible(
        find.text('Guess by Outline'),
        find.byType(ListView),
        const Offset(0, -400),
      );
      expect(find.text('Guess by Outline'), findsOneWidget);
      expect(find.text('Guess by Capital'), findsNothing);
      // Scroll to the last button — off the fold in the test viewport.
      await tester.dragUntilVisible(
        find.text('Explore All Games'),
        find.byType(ListView),
        const Offset(0, -400),
      );
      // Drain the newly-scrolled-into-view FadeSlideIn's entrance timer
      // before the test ends. Confirmed (twice) that pumpAndSettle does
      // NOT reliably clear a timer newly scheduled mid-dragUntilVisible —
      // unclear why, but bounded pumps are the proven fix; sized with
      // generous headroom (covers a stagger index over 30) so this
      // doesn't need re-tuning as Home's mode list grows.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Explore All Games'), findsOneWidget);
    },
  );

  testWidgets('Explore tab shows categories, not a flat game list', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    expect(find.text('Guessing'), findsOneWidget);
    expect(find.text('Naming'), findsOneWidget);
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);
    // Individual modes aren't listed until a category is opened.
    expect(find.text('Guess by Flag'), findsNothing);
  });

  testWidgets(
    'Guessing category lists guess modes, unavailable ones marked Soon',
    (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await _openCategory(tester, 'Guessing');

      expect(find.text('Guess by Flag'), findsOneWidget);
      expect(find.text('Guess by Emoji'), findsOneWidget);
      expect(find.text('Guess by Outline'), findsOneWidget);
      expect(find.text('Guess by Borders'), findsOneWidget);
      // Still-unshipped guess modes appear here too, honestly marked.
      expect(find.text('Soon'), findsWidgets);
    },
  );

  testWidgets('Soon category pulls together every unavailable mode', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Soon');

    expect(find.text('Guess by Clues'), findsOneWidget);
    expect(find.text('Guess by Landmark'), findsOneWidget);
    expect(find.text('Guess by Location'), findsOneWidget);
    expect(find.text('Name the Neighbors'), findsOneWidget);
  });

  testWidgets('Guess by Flag: pick a difficulty, answer, reach results', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Guessing');
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

    expect(find.text('VICTORY'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Try Another'), findsOneWidget);
  });

  testWidgets('Guess by Emoji: pick a difficulty and see a question', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Guessing');
    await tester.tap(find.text('Guess by Emoji'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byType(AnswerOptionButton), findsNWidgets(4));
  });

  testWidgets('Guess by Outline: pick a difficulty and see a question', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Guessing');
    await tester.ensureVisible(find.text('Guess by Outline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guess by Outline'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Hard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byType(AnswerOptionButton), findsNWidgets(4));
    // A real silhouette (not a placeholder) rendered for the question.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Guess by Capital: pick a difficulty and see a question', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Guessing');
    // ensureVisible scrolls until the target's bounds are fully within
    // the viewport (dragUntilVisible only guarantees the barest partial
    // overlap, which isn't always enough for tap()'s center-point hit
    // test on a tall page like this one).
    await tester.ensureVisible(find.text('Guess by Capital'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guess by Capital'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Easy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byType(AnswerOptionButton), findsNWidgets(4));
  });

  testWidgets('Guess by Borders: pick a difficulty and see a question', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Guessing');
    await tester.ensureVisible(find.text('Guess by Borders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guess by Borders'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a difficulty'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byType(AnswerOptionButton), findsNWidgets(4));
  });

  testWidgets(
    'Name All Countries: type a country, see it found, finish the session',
    (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await _openCategory(tester, 'Naming');
      await tester.ensureVisible(find.text('Name All Countries'));
      await tester.pumpAndSettle();
      // Not pumpAndSettle from here: NameEngine runs a Timer.periodic the
      // entire time a session is in progress (even untimed — it's what
      // drives the elapsed-time stat), so the widget tree never "settles"
      // until the session ends. Bounded pumps instead, as with the
      // per-question countdown on the multiple-choice screens.
      await tester.tap(find.text('Name All Countries'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('0 / 195'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'France');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('1 / 195'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
      // Drain the 500ms feedback-flash timer _handleSubmit scheduled
      // before moving on, or it's still pending at teardown.
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text("I'm Done"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('NICE RUN'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
    },
  );

  testWidgets('Name the Alphabet: answer one letter, skip another', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await _openCategory(tester, 'Naming');
    await tester.ensureVisible(find.text('Name the Alphabet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name the Alphabet'));
    await tester.pumpAndSettle();

    // No W or X in the dataset, so the sequence starts at A and skips
    // straight past those two — the first eligible letter is A.
    expect(find.textContaining('Letter 1 /'), findsOneWidget);
    expect(find.text('Name a country starting with "A"'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Afghanistan');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.textContaining('Letter 2 /'), findsOneWidget);
    expect(find.text('Name a country starting with "B"'), findsOneWidget);

    await tester.tap(find.text('Skip this letter'));
    await tester.pump();

    expect(find.textContaining('Letter 3 /'), findsOneWidget);
  });

  testWidgets('Lists tab replaces Rankings with a browsable country list', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Rankings'), findsNothing);

    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();

    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Capitals'), findsOneWidget);
    expect(find.text('Flags'), findsOneWidget);
    expect(find.text('Afghanistan'), findsOneWidget);
  });
}
