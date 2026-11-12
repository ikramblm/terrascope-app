/// Decides after which finished games a full-screen ad may show: after the
/// 2nd game, then 3 games later, then 2, then 3 … ([gaps] cycles), and never
/// sooner than [minInterval] after the previous one. Pure logic, no SDK —
/// so the rhythm is unit-tested.
class InterstitialPolicy {
  InterstitialPolicy({
    this.gaps = const [2, 3],
    this.minInterval = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final List<int> gaps;
  final Duration minInterval;
  final DateTime Function() _now;

  int _gamesSinceAd = 0;
  int _gapIndex = 0;
  DateTime? _lastShown;

  /// Call once per finished game. True when an ad is due now. If it's due
  /// but not shown (no ad loaded, too soon), it stays due for the next game
  /// — call [markShown] only when an ad actually went on screen.
  bool onGameFinished() {
    _gamesSinceAd++;
    if (_gamesSinceAd < gaps[_gapIndex % gaps.length]) return false;
    final last = _lastShown;
    if (last != null && _now().difference(last) < minInterval) return false;
    return true;
  }

  void markShown() {
    _gamesSinceAd = 0;
    _gapIndex++;
    _lastShown = _now();
  }
}
