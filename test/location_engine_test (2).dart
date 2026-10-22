import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/data/countries/models/country.dart';
import 'package:terrascope_app/features/game_engine/domain/game_difficulty.dart';
import 'package:terrascope_app/features/game_engine/location_engine/location_engine.dart';
import 'package:terrascope_app/features/games/guess_outline/data/country_outline_repository.dart';

Country _country(String cca3, String name, {double? lat, double? lon}) =>
    Country(
      cca2: cca3.substring(0, 2),
      cca3: cca3,
      nameCommon: name,
      nameOfficial: name,
      capital: null,
      region: '',
      subregion: '',
      continent: '',
      latitude: lat,
      longitude: lon,
      area: null,
      population: null,
      flagEmoji: '',
      currencies: const [],
      languages: const [],
      borders: const [],
      landlocked: false,
      independent: true,
      unMember: true,
      altSpellings: const [],
      landmarks: const [],
      emojiClues: const [],
    );

// A 10° x 10° square country at the origin, and a tiny neighbour just
// east of it — close enough that the old 800 km "close enough" rule
// would have scored a tap on one as correct for the other.
CountryOutline _square(double x, double y, double size) => [
  [
    [
      Offset(x, y),
      Offset(x + size, y),
      Offset(x + size, y + size),
      Offset(x, y + size),
      Offset(x, y),
    ],
  ],
];

void main() {
  final big = _country('BIG', 'Big', lat: 5, lon: 5);
  final small = _country('SML', 'Small', lat: 5, lon: 12.5);
  final tiny = _country('TNY', 'Tiny', lat: 0, lon: 0); // no outline
  final outlines = <String, CountryOutline>{
    'BIG': _square(0, 0, 10),
    'SML': _square(12, 4, 1),
  };

  LocationEngine build(List<Country> targets) => LocationEngine(
    targets: targets,
    difficulty: GameDifficulty.medium,
    outlines: outlines,
  );

  test('a tap inside the target\'s outline is correct and scores full marks',
      () {
    fakeAsync((async) {
      final engine = build([big, big])..start();

      // Far corner of the country, far from its reference point.
      engine.submitGuess(9, 9);

      expect(engine.lastGuessWasCorrect, isTrue);
      expect(engine.lastDistanceKm, 0);
      expect(engine.lastRoundScore, GameDifficulty.medium.basePoints);
      expect(engine.combo, 1);
      expect(engine.correctCount, 1);
      expect(engine.correctCca3s, contains('BIG'));
      expect(engine.xpEarned, GameDifficulty.medium.baseXp);

      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.currentIndex, 1);
      expect(engine.answered, isFalse);
      engine.dispose();
    });
  });

  test('a tap on a small neighbouring country is wrong', () {
    fakeAsync((async) {
      final engine = build([small, big])..start();

      // Inside BIG, ~1.5° (~165 km) from SML's edge — close, but not it.
      engine.submitGuess(9.5, 4.5);

      expect(engine.lastGuessWasCorrect, isFalse);
      expect(engine.lastDistanceKm, greaterThan(100));
      expect(engine.correctCount, 0);
      expect(engine.combo, 0);
      expect(engine.xpEarned, 0);
      // Wrong, but near: partial credit, less than full marks.
      expect(engine.lastRoundScore, greaterThan(0));
      expect(engine.lastRoundScore, lessThan(GameDifficulty.medium.basePoints));
      engine.dispose();
    });
  });

  test('a tap just past the border (within tolerance) still counts', () {
    fakeAsync((async) {
      final engine = build([big, big])..start();

      // ~0.05° (~5 km) outside BIG's east edge.
      engine.submitGuess(10.05, 5);

      expect(engine.lastGuessWasCorrect, isTrue);
      expect(engine.lastDistanceKm, lessThan(LocationEngine.edgeToleranceKm));
      engine.dispose();
    });
  });

  test('a far-away tap is wrong and scores zero', () {
    fakeAsync((async) {
      final engine = build([big, big])..start();

      engine.submitGuess(-120, 40);

      expect(engine.lastGuessWasCorrect, isFalse);
      expect(engine.lastRoundScore, 0);
      expect(engine.score, 0);
      expect(engine.combo, 0);
      engine.dispose();
    });
  });

  test('a target without an outline uses a short radius around its point', () {
    fakeAsync((async) {
      final engine = build([tiny, tiny, tiny])..start();

      // ~55 km away — inside the 150 km radius.
      engine.submitGuess(0.5, 0);
      expect(engine.lastGuessWasCorrect, isTrue);

      async.elapse(LocationEngine.feedbackDelay);
      // ~550 km away — outside it.
      engine.submitGuess(5, 0);
      expect(engine.lastGuessWasCorrect, isFalse);
      engine.dispose();
    });
  });

  test('a round that times out with no tap scores zero, not a crash', () {
    fakeAsync((async) {
      final engine = LocationEngine(
        targets: [big, small],
        difficulty: GameDifficulty.hard,
        outlines: outlines,
      )..start();

      async.elapse(engine.timeAllotted);

      expect(engine.answered, isTrue);
      expect(engine.lastDistanceKm, isNull);
      expect(engine.lastRoundScore, 0);
      expect(engine.lastGuessWasCorrect, isFalse);
      expect(engine.combo, 0);
      engine.dispose();
    });
  });

  test('completes after the last round and builds a matching GameResult', () {
    fakeAsync((async) {
      final engine = LocationEngine(
        targets: [big, small],
        difficulty: GameDifficulty.easy,
        outlines: outlines,
      )..start();

      engine.submitGuess(5, 5);
      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.isComplete, isFalse);

      engine.submitGuess(12.5, 4.5);
      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.isComplete, isTrue);

      final result = engine.buildResult();
      expect(result.totalQuestions, 2);
      expect(result.correctCount, 2);
      expect(result.bestCombo, 2);
      expect(result.totalScore, GameDifficulty.easy.basePoints * 2);
      expect(result.correctCca3s, {'BIG', 'SML'});
      engine.dispose();
    });
  });
}
