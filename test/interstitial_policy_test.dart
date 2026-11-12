import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/features/ads/interstitial_policy.dart';

void main() {
  test('ads are due after game 2, then 3 games later, then 2, then 3', () {
    var clock = DateTime(2026, 1, 1);
    final policy = InterstitialPolicy(now: () => clock);
    final due = <int>[];
    for (var game = 1; game <= 10; game++) {
      clock = clock.add(const Duration(minutes: 5));
      if (policy.onGameFinished()) {
        due.add(game);
        policy.markShown();
      }
    }
    expect(due, [2, 5, 7, 10]);
  });

  test('an ad that was due but not shown stays due', () {
    final policy = InterstitialPolicy();
    expect(policy.onGameFinished(), isFalse);
    expect(policy.onGameFinished(), isTrue); // due, but nothing loaded
    expect(policy.onGameFinished(), isTrue); // still due on the next game
  });

  test('never twice within the minimum interval', () {
    var clock = DateTime(2026, 1, 1);
    final policy = InterstitialPolicy(now: () => clock);
    policy.onGameFinished();
    expect(policy.onGameFinished(), isTrue);
    policy.markShown();
    // Three quick games, all within 60 seconds of the last ad.
    clock = clock.add(const Duration(seconds: 10));
    policy.onGameFinished();
    policy.onGameFinished();
    expect(policy.onGameFinished(), isFalse);
    clock = clock.add(const Duration(seconds: 61));
    expect(policy.onGameFinished(), isTrue);
  });
}
