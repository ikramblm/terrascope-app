import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_engine/domain/game_result.dart';
import '../../game_engine/sound/sound_service.dart';
import '../../notifications/services/notification_service.dart';
import '../data/player_profile_repository.dart';
import '../domain/chest_reward.dart';
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

/// Coins to buy one more Streak Freeze once the free stock is at zero.
const streakFreezeCoinCost = 30;

/// Holds the current player's progression state, backed by on-device
/// storage via [PlayerProfileRepository] — every mutation here is
/// persisted immediately after, so progress survives an app restart.
class PlayerProfileNotifier extends Notifier<PlayerProfile> {
  late final PlayerProfileRepository _repository;

  @override
  PlayerProfile build() {
    _repository = ref.watch(playerProfileRepositoryProvider);
    final profile = _repository.load() ?? PlayerProfile.newPlayer();
    _syncStreakReminder(profile);
    SoundService.instance.enabled = profile.soundEnabled;
    return profile;
  }

  /// The only place [PlayerProfile.soundEnabled] ever changes — flips
  /// the persisted preference and [SoundService]'s live mute flag
  /// together, so they can never drift out of sync.
  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    SoundService.instance.enabled = value;
    _persist();
  }

  /// Schedules (or clears) today's streak-expiry reminder to match
  /// [profile] — called on every app start and after every completed
  /// session, so the reminder never drifts from what's actually true.
  void _syncStreakReminder(PlayerProfile profile) {
    final today = DateTime.now();
    if (profile.currentStreakDays <= 0 || profile.hasPlayedOn(today)) {
      unawaited(NotificationService.instance.cancelStreakReminder());
    } else {
      unawaited(
        NotificationService.instance.scheduleStreakReminder(
          streakDays: profile.currentStreakDays,
        ),
      );
    }
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

  /// Set by [recordSession] for the caller to read right after —
  /// true if this session's day-boundary streak update consumed a
  /// Streak Freeze to bridge a missed day rather than resetting.
  bool lastSessionUsedStreakFreeze = false;

  /// Set by [recordSession] for the results screen to read right after
  /// — this session's mystery-chest roll, already fully applied to
  /// [state] below (coins/title/freeze), never just a cosmetic claim.
  ChestReward? lastChestReward;

  /// Applies a completed game session's outcome: XP, coins, streak, a
  /// mystery-chest roll, and newly-discovered countries. Called once
  /// per session by every game mode via the shared game engine — the
  /// single place player progression is updated from gameplay.
  void recordSession(GameResult result) {
    final now = DateTime.now();
    final streak = _nextStreak(now);
    lastSessionUsedStreakFreeze = streak.freezeUsed;

    // Coins track XP at a flat 1-for-5 rate — no separate balancing
    // pass, just enough that a solid round buys roughly one power-up.
    final coinsEarned = (result.xpEarned / 5).round();

    final chest = ChestReward.roll(
      xpEarned: result.xpEarned,
      ownedTitles: state.unlockedCosmeticTitles,
    );
    lastChestReward = chest;

    state = state.copyWith(
      totalXp: state.totalXp + result.xpEarned,
      coins: state.coins + coinsEarned + chest.bonusCoins,
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
      currentStreakDays: streak.currentStreakDays,
      longestStreakDays: streak.longestStreakDays,
      streakFreezesAvailable:
          streak.streakFreezesAvailable + (chest.grantedStreakFreeze ? 1 : 0),
      unlockedCosmeticTitles: chest.unlockedTitle == null
          ? state.unlockedCosmeticTitles
          : {...state.unlockedCosmeticTitles, chest.unlockedTitle!},
      lastPlayedAt: now,
    );
    _persist();
    _syncStreakReminder(state);
  }

  /// Marks today's Daily Challenge as played — separate from
  /// [recordSession] (which still runs first, for XP/coins/stats) so
  /// the one-attempt-per-day gate lives in exactly one place.
  void recordDailyChallengeCompletion(DateTime date) {
    state = state.copyWith(lastDailyChallengeDate: date);
    _persist();
  }

  /// Buys one more Streak Freeze for [streakFreezeCoinCost] coins.
  /// Returns false (no change) if the player can't afford it.
  bool buyStreakFreeze() {
    if (state.coins < streakFreezeCoinCost) return false;
    state = state.copyWith(
      coins: state.coins - streakFreezeCoinCost,
      streakFreezesAvailable: state.streakFreezesAvailable + 1,
    );
    _persist();
    return true;
  }

  /// The day-boundary streak rule: same calendar day as last played ->
  /// unchanged; exactly one day later -> streak continues; more than
  /// one day later -> broken, UNLESS a Streak Freeze is available and
  /// exactly one day was missed, in which case one freeze is spent to
  /// bridge the gap instead. Never silently applies more than one
  /// freeze for a longer gap — that's a real broken streak, not a
  /// one-day slip.
  ({
    int currentStreakDays,
    int longestStreakDays,
    int streakFreezesAvailable,
    bool freezeUsed,
  })
  _nextStreak(DateTime now) {
    final last = state.lastPlayedAt;
    if (last == null) {
      return (
        currentStreakDays: 1,
        longestStreakDays: state.longestStreakDays < 1
            ? 1
            : state.longestStreakDays,
        streakFreezesAvailable: state.streakFreezesAvailable,
        freezeUsed: false,
      );
    }

    final lastDate = DateTime(last.year, last.month, last.day);
    final today = DateTime(now.year, now.month, now.day);
    final dayGap = today.difference(lastDate).inDays;

    if (dayGap <= 0) {
      // Same day (or a clock oddity putting "now" before the last
      // recorded date) — no change to the streak either way.
      final current = state.currentStreakDays < 1 ? 1 : state.currentStreakDays;
      return (
        currentStreakDays: current,
        longestStreakDays: current > state.longestStreakDays
            ? current
            : state.longestStreakDays,
        streakFreezesAvailable: state.streakFreezesAvailable,
        freezeUsed: false,
      );
    }

    if (dayGap == 1) {
      final next = state.currentStreakDays + 1;
      return (
        currentStreakDays: next,
        longestStreakDays: next > state.longestStreakDays
            ? next
            : state.longestStreakDays,
        streakFreezesAvailable: state.streakFreezesAvailable,
        freezeUsed: false,
      );
    }

    if (dayGap == 2 && state.streakFreezesAvailable > 0) {
      final next = state.currentStreakDays + 1;
      return (
        currentStreakDays: next,
        longestStreakDays: next > state.longestStreakDays
            ? next
            : state.longestStreakDays,
        streakFreezesAvailable: state.streakFreezesAvailable - 1,
        freezeUsed: true,
      );
    }

    return (
      currentStreakDays: 1,
      longestStreakDays: state.longestStreakDays,
      streakFreezesAvailable: state.streakFreezesAvailable,
      freezeUsed: false,
    );
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
