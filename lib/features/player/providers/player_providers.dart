import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_engine/domain/game_result.dart';
import '../data/player_profile_repository.dart';
import '../domain/player_profile.dart';
import '../domain/power_up.dart';

/// Overridden in `main()` with a real, `SharedPreferences`-backed
/// repository. Left unoverridden (e.g. a test that forgets to override
/// it) fails loudly at first use rather than silently not persisting.
final playerProfileRepositoryProvider = Provider<PlayerProfileRepository>((
  ref,
) {
  throw UnimplementedError(
    'playerProfileRepositoryProvider must be overridden with a real '
    'PlayerProfileRepository (see main()) or a test double.',
  );
});

/// Holds the current player's progression state, backed by on-device
/// storage via [PlayerProfileRepository] — every mutation here is
/// persisted immediately after, so progress survives an app restart.
class PlayerProfileNotifier extends Notifier<PlayerProfile> {
  late final PlayerProfileRepository _repository;

  @override
  PlayerProfile build() {
    _repository = ref.watch(playerProfileRepositoryProvider);
    return _repository.load() ?? PlayerProfile.newPlayer();
  }

  void _persist() {
    // Fire-and-forget: nothing in the UI blocks on a save completing,
    // and a failed write here is no worse than the write never having
    // been attempted — the in-memory `state` the player sees is already
    // correct either way.
    unawaited(_repository.save(state));
  }

  void addXp(int amount) {
    state = state.copyWith(totalXp: state.totalXp + amount);
    _persist();
  }

  /// Applies a completed game session's outcome: XP, coins, and
  /// newly-discovered countries. Called once per session by every game
  /// mode via the shared game engine — the single place player
  /// progression is updated from gameplay.
  void recordSession(GameResult result) {
    // Coins track XP at a flat 1-for-5 rate — no separate balancing
    // pass, just enough that a solid round buys roughly one power-up.
    final coinsEarned = (result.xpEarned / 5).round();
    state = state.copyWith(
      totalXp: state.totalXp + result.xpEarned,
      coins: state.coins + coinsEarned,
      discoveredCountryCodes: {
        ...state.discoveredCountryCodes,
        ...result.correctCca3s,
      },
      bestScore: result.totalScore > state.bestScore
          ? result.totalScore
          : state.bestScore,
      gamesPlayed: state.gamesPlayed + 1,
      totalCorrectAnswers: state.totalCorrectAnswers + result.correctCount,
      totalQuestionsAnswered:
          state.totalQuestionsAnswered + result.totalQuestions,
      lastPlayedAt: DateTime.now(),
    );
    _persist();
  }

  int _countFor(PowerUpType type) => switch (type) {
    PowerUpType.fiftyFifty => state.fiftyFiftyCount,
    PowerUpType.timeFreeze => state.timeFreezeCount,
    PowerUpType.radar => state.radarCount,
  };

  PlayerProfile _withCount(PowerUpType type, int newCount) => switch (type) {
    PowerUpType.fiftyFifty => state.copyWith(fiftyFiftyCount: newCount),
    PowerUpType.timeFreeze => state.copyWith(timeFreezeCount: newCount),
    PowerUpType.radar => state.copyWith(radarCount: newCount),
  };

  /// True if this power-up is usable right now — either free stock is
  /// available, or the player can afford to buy one more use on the
  /// spot. The tray uses this to decide whether a tile is tappable.
  bool canUse(PowerUpType type) =>
      _countFor(type) > 0 || state.coins >= type.coinCost;

  /// Spends one use of [type] — from free stock if any remain,
  /// otherwise buying one more with coins on the spot. Returns false
  /// (and changes nothing) if neither is possible.
  bool usePowerUp(PowerUpType type) {
    final count = _countFor(type);
    if (count > 0) {
      state = _withCount(type, count - 1);
      _persist();
      return true;
    }
    if (state.coins >= type.coinCost) {
      state = _withCount(type, 0).copyWith(coins: state.coins - type.coinCost);
      _persist();
      return true;
    }
    return false;
  }
}

final playerProfileProvider =
    NotifierProvider<PlayerProfileNotifier, PlayerProfile>(
      PlayerProfileNotifier.new,
    );
