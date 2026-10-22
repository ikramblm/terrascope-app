import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/features/duels/domain/duel_payload.dart';

void main() {
  group('DuelPayload', () {
    test('round-trips every field through encode/decode', () {
      const payload = DuelPayload(
        seed: 123456,
        questionCount: 8,
        challengerScore: 742,
        challengerName: 'Ikram',
      );

      final decoded = DuelPayload.decode(payload.encode());

      expect(decoded, isNotNull);
      expect(decoded!.seed, 123456);
      expect(decoded.questionCount, 8);
      expect(decoded.challengerScore, 742);
      expect(decoded.challengerName, 'Ikram');
    });

    test('tolerates surrounding whitespace and line breaks from a paste', () {
      const payload = DuelPayload(
        seed: 1,
        questionCount: 5,
        challengerScore: 10,
        challengerName: 'A',
      );
      final withWhitespace = '  \n${payload.encode()}\n  ';

      expect(DuelPayload.decode(withWhitespace), isNotNull);
    });

    test('returns null for garbage input instead of throwing', () {
      expect(DuelPayload.decode('not a real code'), isNull);
      expect(DuelPayload.decode(''), isNull);
      expect(DuelPayload.decode('!!!'), isNull);
    });

    test('rejects a well-formed code with a blank challenger name', () {
      final blankName = const DuelPayload(
        seed: 1,
        questionCount: 1,
        challengerScore: 1,
        challengerName: '',
      ).encode();

      // Never a duel with no one to credit the challenge to.
      expect(DuelPayload.decode(blankName), isNull);
    });
  });
}
