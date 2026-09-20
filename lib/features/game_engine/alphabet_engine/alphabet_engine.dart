import '../../../data/countries/models/country.dart';
import '../domain/game_result.dart';

/// Drives "Name the Alphabet": the player works through A→Z in order,
/// naming one country per letter. A correct answer advances to the next
/// letter; skipping does too, just without credit. Letters with no
/// eligible country (no country's name starts with them, e.g. W or X)
/// are left out entirely — never an impossible letter to block on.
class AlphabetEngine {
  AlphabetEngine({required List<Country> pool})
    : pool = List.unmodifiable(pool),
      letters = _eligibleLetters(pool);

  final List<Country> pool;
  final List<String> letters;

  int _index = 0;
  int correctCount = 0;
  int skippedCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  final Set<String> _correctCca3s = {};

  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  bool _isComplete = false;

  /// Set by [submit] for one frame so the UI can flash a miss without
  /// advancing; cleared on the next submit/skip.
  bool lastSubmitWasWrong = false;

  static List<String> _eligibleLetters(List<Country> pool) {
    final letters = <String>[];
    for (var i = 0; i < 26; i++) {
      final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
      final hasMatch = pool.any(
        (c) => c.nameCommon.toUpperCase().startsWith(letter),
      );
      if (hasMatch) letters.add(letter);
    }
    return letters;
  }

  int get totalLetters => letters.length;
  int get letterIndex => _index;
  String get currentLetter => letters[_index];
  bool get isComplete => _isComplete;
  Duration get elapsed => _elapsed;
  double get progress => totalLetters == 0 ? 0 : _index / totalLetters;

  void start() {
    _startedAt = DateTime.now();
  }

  /// Tries to match [text] against a country starting with
  /// [currentLetter] (by common name or any alt spelling, case/diacritic
  /// -loose). Returns true and advances on a match; a miss just flashes
  /// [lastSubmitWasWrong] without advancing, so the player can retry.
  bool submit(String text) {
    if (_isComplete) return false;
    final normalized = _normalize(text);
    if (normalized.isEmpty) return false;

    for (final country in pool) {
      if (!country.nameCommon.toUpperCase().startsWith(currentLetter)) {
        continue;
      }
      final matches =
          _normalize(country.nameCommon) == normalized ||
          country.altSpellings.any((alt) => _normalize(alt) == normalized);
      if (!matches) continue;

      lastSubmitWasWrong = false;
      correctCount++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
      _correctCca3s.add(country.cca3);
      _advance();
      return true;
    }

    lastSubmitWasWrong = true;
    return false;
  }

  /// Player-triggered skip — moves on with no credit and breaks the
  /// current correct-streak.
  void skip() {
    if (_isComplete) return;
    _currentStreak = 0;
    skippedCount++;
    _advance();
  }

  void _advance() {
    lastSubmitWasWrong = false;
    _index++;
    if (_index >= totalLetters) {
      _finish();
    }
  }

  void _finish() {
    if (_isComplete) return;
    _isComplete = true;
    _elapsed = DateTime.now().difference(_startedAt!);
  }

  GameResult buildResult() {
    const pointsPerLetter = 100;
    const xpPerLetter = 5;
    return GameResult(
      totalScore: correctCount * pointsPerLetter,
      xpEarned: correctCount * xpPerLetter,
      correctCount: correctCount,
      totalQuestions: totalLetters,
      bestCombo: _bestStreak,
      elapsed: _elapsed,
      correctCca3s: Set.of(_correctCca3s),
    );
  }

  String _normalize(String s) {
    const diacritics =
        'àáâãäåāăąèéêëēĕėęěìíîïĩīĭįòóôõöøōŏőùúûüũūŭůűųçćĉċčñńņňÿýş';
    const plain = 'aaaaaaaaaeeeeeeeeeiiiiiiiiiooooooooouuuuuuuuuuccccc nnnyys';
    final buffer = StringBuffer();
    for (final ch in s.toLowerCase().trim().split('')) {
      final idx = diacritics.indexOf(ch);
      buffer.write(idx >= 0 ? plain[idx] : ch);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
