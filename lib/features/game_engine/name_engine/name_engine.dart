import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';
import '../domain/game_result.dart';

/// Drives every "type as many countries as you can" mode — Name All
/// Countries, Name by Continent, Name by Letter, Name by Category, Name
/// the Neighbors, Name as Many as Possible. They differ only in which
/// [pool] of countries counts and whether there's a [timeLimit]; the
/// mechanic (type a name, match it, track what's found) is identical,
/// so it lives here once.
class NameEngine extends ChangeNotifier {
  NameEngine({required List<Country> pool, this.timeLimit}) : pool = List.unmodifiable(pool);

  final List<Country> pool;

  /// Null means untimed — the session only ends when every country in
  /// [pool] is found or the player taps Finish.
  final Duration? timeLimit;

  final Set<String> _foundCca3 = {};
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  DateTime? _startedAt;
  bool _isComplete = false;

  /// Set by [submit] for one frame so the UI can flash "already found" vs
  /// a fresh miss differently; cleared on the next submit.
  bool lastSubmitWasDuplicate = false;

  Set<String> get foundCca3 => _foundCca3;
  int get foundCount => _foundCca3.length;
  int get totalCount => pool.length;
  Duration get elapsed => _elapsed;
  Duration? get timeRemaining => timeLimit == null ? null : timeLimit! - _elapsed;
  bool get isComplete => _isComplete;
  double get progress => totalCount == 0 ? 0 : foundCount / totalCount;

  List<Country> get foundCountriesSorted {
    final found = pool.where((c) => _foundCca3.contains(c.cca3)).toList();
    found.sort((a, b) => a.nameCommon.compareTo(b.nameCommon));
    return found;
  }

  void start() {
    _startedAt = DateTime.now();
    // Only untimed sessions skip the periodic ticker — with no countdown
    // to display, there's nothing for a 200ms tick to usefully redraw;
    // `elapsed` is just computed once, lazily, when the session ends.
    if (timeLimit != null) {
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    }
  }

  void _tick() {
    if (_isComplete) return;
    _elapsed = DateTime.now().difference(_startedAt!);
    if (timeLimit != null && _elapsed >= timeLimit!) {
      _elapsed = timeLimit!;
      _finish();
      return;
    }
    notifyListeners();
  }

  /// Tries to match [text] against an unfound country in [pool] (by
  /// common name or any alt spelling, case/diacritic-loose). Returns
  /// true if it found a new match.
  bool submit(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) return false;

    lastSubmitWasDuplicate = false;
    for (final country in pool) {
      final matches = _normalize(country.nameCommon) == normalized ||
          country.altSpellings.any((alt) => _normalize(alt) == normalized);
      if (!matches) continue;

      if (_foundCca3.contains(country.cca3)) {
        lastSubmitWasDuplicate = true;
        notifyListeners();
        return false;
      }
      _foundCca3.add(country.cca3);
      if (_foundCca3.length == pool.length) {
        _finish();
      } else {
        notifyListeners();
      }
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Player-triggered early stop (e.g. "I'm done" on an untimed session).
  void finish() => _finish();

  void _finish() {
    if (_isComplete) return;
    // For a timed session that just hit its limit, _tick already pinned
    // _elapsed to exactly timeLimit; for an untimed session (no ticker
    // running) or an early "I'm Done"/completionist finish, compute it
    // fresh here — this is the only point it's needed.
    if (timeLimit == null || _elapsed < timeLimit!) {
      _elapsed = DateTime.now().difference(_startedAt!);
    }
    _isComplete = true;
    _ticker?.cancel();
    notifyListeners();
  }

  GameResult buildResult() {
    const pointsPerCountry = 15;
    const xpPerCountry = 3;
    return GameResult(
      totalScore: foundCount * pointsPerCountry,
      xpEarned: foundCount * xpPerCountry,
      correctCount: foundCount,
      totalQuestions: totalCount,
      bestCombo: foundCount,
      elapsed: _elapsed,
      correctCca3s: Set.of(_foundCca3),
    );
  }

  String _normalize(String s) {
    const diacritics = 'àáâãäåāăąèéêëēĕėęěìíîïĩīĭįòóôõöøōŏőùúûüũūŭůűųçćĉċčñńņňÿýş';
    const plain = 'aaaaaaaaaeeeeeeeeeiiiiiiiiiooooooooouuuuuuuuuuccccc nnnyys';
    final buffer = StringBuffer();
    for (final ch in s.toLowerCase().trim().split('')) {
      final idx = diacritics.indexOf(ch);
      buffer.write(idx >= 0 ? plain[idx] : ch);
    }
    return buffer.toString().replaceAll(RegExp(r"[^a-z0-9 ]"), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
