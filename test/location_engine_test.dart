import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/data/countries/models/country.dart';
import 'package:terrascope_app/features/game_engine/domain/game_difficulty.dart';
import 'package:terrascope_app/features/game_engine/location_engine/location_engine.dart';

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

void main() {
  // Sits at the equator/prime meridian so distances from a handful of
  // simple (lon, lat) test guesses are easy to reason about by hand.
  final origin = _country('AAA', 'Origin', lat: 0, lon: 0);
  final another = _country('BBB', 'Another', lat: 0, lon: 0);

  test('a near-exact guess scores full points and counts as close', () {
    fakeAsync((async) {
      final engine = LocationEngine(
        targets: [origin, another],
        difficulty: GameDifficulty.medium,
      );
      engine.start();

      // ~111 km east of the target — comfortably inside the 300 km
      // full-marks radius and the 800 km "close enough" threshold.
      engine.submitGuess(1, 0);

      expect(engine.answered, isTrue);
      expect(engine.lastDistanceKm, isNotNull);
      expect(engine.lastDistanceKm!, lessThan(150));
      expect(engine.lastRoundScore, GameDifficulty.medium.basePoints);
      expect(engine.score, GameDifficulty.medium.basePoints);
      expect(engine.combo, 1);
      expect(engine.bestCombo, 1);
      expect(engine.correctCount, 1);
      expect(engine.correctCca3s, contains('AAA'));
      expect(engine.xpEarned, GameDifficulty.medium.baseXp);

      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.currentIndex, 1);
      expect(engine.answered, isFalse);

      engine.dispose();
    });
  });

  test(
    'a guess on the opposite side of the world scores zero and resets combo',
    () {
      fakeAsync((async) {
        final engine = LocationEngine(
          targets: [origin, another],
          difficulty: GameDifficulty.medium,
        );
        engine.start();

        // Antipodal-ish guess — roughly half the Earth's circumference
        // away, well past the zero-marks distance.
        engine.submitGuess(180, 0);

        expect(engine.lastDistanceKm, greaterThan(15000));
        expect(engine.lastRoundScore, 0);
        expect(engine.score, 0);
        expect(engine.combo, 0);
        expect(engine.correctCount, 0);
        expect(engine.xpEarned, 0);

        engine.dispose();
      });
    },
  );

  test('a round that times out with no tap scores zero, not a crash', () {
    fakeAsync((async) {
      final engine = LocationEngine(
        targets: [origin, another],
        difficulty: GameDifficulty.hard,
      );
      engine.start();

      async.elapse(engine.timeAllotted);

      expect(engine.answered, isTrue);
      expect(engine.lastDistanceKm, isNull);
      expect(engine.lastRoundScore, 0);
      expect(engine.combo, 0);

      engine.dispose();
    });
  });

  test('completes after the last round and builds a matching GameResult', () {
    fakeAsync((async) {
      final engine = LocationEngine(
        targets: [origin, another],
        difficulty: GameDifficulty.easy,
      );
      engine.start();

      engine.submitGuess(0, 0);
      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.isComplete, isFalse);

      engine.submitGuess(0, 0);
      async.elapse(LocationEngine.feedbackDelay);
      expect(engine.isComplete, isTrue);

      final result = engine.buildResult();
      expect(result.totalQuestions, 2);
      expect(result.correctCount, 2);
      expect(result.bestCombo, 2);
      expect(result.totalScore, GameDifficulty.easy.basePoints * 2);
      expect(result.correctCca3s, {'AAA', 'BBB'});

      engine.dispose();
    });
  });
}
