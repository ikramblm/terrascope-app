import 'dart:convert';

/// Everything needed to regenerate and compare someone else's exact
/// duel challenge, packed into one paste-able code.
///
/// The trick that makes this honestly buildable with no backend: the
/// whole challenge is encoded in the code itself. Both devices run the
/// same [seed] through the same question generator and get the
/// identical question set — no server ever compares anything, because
/// there's nothing hidden left to compare; the code carries all of it.
class DuelPayload {
  const DuelPayload({
    required this.seed,
    required this.questionCount,
    required this.challengerScore,
    required this.challengerName,
  });

  final int seed;
  final int questionCount;
  final int challengerScore;
  final String challengerName;

  String encode() {
    final json = {
      'seed': seed,
      'q': questionCount,
      'score': challengerScore,
      'name': challengerName,
    };
    return base64Url.encode(utf8.encode(jsonEncode(json)));
  }

  /// Null for any malformed or tampered code — a bad paste is just
  /// "check it and try again," never a crash.
  static DuelPayload? decode(String code) {
    try {
      final cleaned = code.trim().replaceAll(RegExp(r'\s+'), '');
      final json =
          jsonDecode(utf8.decode(base64Url.decode(cleaned)))
              as Map<String, dynamic>;
      final name = json['name'] as String;
      if (name.trim().isEmpty) return null;
      return DuelPayload(
        seed: json['seed'] as int,
        questionCount: json['q'] as int,
        challengerScore: json['score'] as int,
        challengerName: name,
      );
    } catch (_) {
      return null;
    }
  }
}
