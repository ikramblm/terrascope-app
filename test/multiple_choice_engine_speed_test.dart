import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/data/countries/models/country.dart';
import 'package:terrascope_app/features/game_engine/domain/game_difficulty.dart';
import 'package:terrascope_app/features/game_engine/domain/multiple_choice_question.dart';
import 'package:terrascope_app/features/game_engine/engine/multiple_choice_engine.dart';

/// Speed-mode engine behavior (sudden death, global time limit) is
/// tested directly against [MultipleChoiceEngine] with [FakeAsync]
/// rather than through a widget test — the answer options a widget test
/// would tap are shuffled per question, so there's no reliable way to
/// force a "wrong answer" from the UI layer alone.
Country _country(String cca3, String name) => Country(
  cca2: cca3.substring(0, 2),
  cca3: cca3,
  nameCommon: name,
  nameOfficial: name,
  capital: null,
  region: '',
  subregion: '',
  continent: '',
  latitude: null,
  longitude: null,
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
  final alpha = _country('AAA', 'Alpha');
  final beta = _country('BBB', 'Beta');

  List<MultipleChoiceQuestion> questions(int count) => List.generate(
    count,
    (i) => MultipleChoiceQuestion(
      promptText: 'q$i',
      correctAnswer: alpha,
      options: [alpha, beta],
    ),
  );

  test('sudden death: one wrong answer ends the session, streak preserved', () {
    fakeAsync((async) {
      final engine = MultipleChoiceEngine(
        questions: questions(10),
        difficulty: GameDifficulty.hard,
        suddenDeath: true,
      );
      engine.start();

      // Two correct answers build a streak...
      engine.submitAnswer(alpha);
      async.elapse(MultipleChoiceEngine.feedbackDelay);
      expect(engine.isComplete, isFalse);
      expect(engine.currentIndex, 1);

      engine.submitAnswer(alpha);
      async.elapse(MultipleChoiceEngine.feedbackDelay);
      expect(engine.isComplete, isFalse);
      expect(engine.combo, 2);

      // ...then one wrong answer ends the run immediately, not just
      // resets the combo and continues like a normal quiz would.
      engine.submitAnswer(beta);
      async.elapse(MultipleChoiceEngine.feedbackDelay);
      expect(engine.isComplete, isTrue);

      final result = engine.buildResult();
      expect(result.bestCombo, 2, reason: 'the streak reached before the miss');
      expect(result.correctCount, 2);
      // Accuracy must be measured against questions actually attempted
      // (2 correct + 1 wrong = 3), not the full pre-generated pool (10)
      // — otherwise a real streak reads as an artificially low score.
      expect(result.totalQuestions, 3);

      engine.dispose();
    });
  });

  test(
    'global time limit ends the session even mid-question, wrong answers keep it going',
    () {
      fakeAsync((async) {
        final engine = MultipleChoiceEngine(
          questions: questions(50),
          difficulty: GameDifficulty.hard,
          globalTimeLimit: const Duration(seconds: 5),
        );
        engine.start();

        // A wrong answer does NOT end a globalTimeLimit session (only
        // sudden death does) — it should advance like a normal quiz.
        engine.submitAnswer(beta);
        async.elapse(MultipleChoiceEngine.feedbackDelay);
        expect(engine.isComplete, isFalse);
        expect(engine.currentIndex, 1);

        // The clock, not question progress, ends the session.
        async.elapse(const Duration(seconds: 5));
        expect(engine.isComplete, isTrue);

        engine.dispose();
      });
    },
  );
}
