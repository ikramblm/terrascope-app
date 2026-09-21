import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_engine/domain/game_result.dart';
import '../data/player_profile_repository.dart';
import '../domain/player_profile.dart';

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

  /// Applies a completed game session's outcome: XP and newly-discovered
  /// countries. Called once per session by every game mode via the shared
  /// game engine — the single place player progression is updated from
  /// gameplay.
  void recordSession(GameResult result) {
    state = state.copyWith(
      totalXp: state.totalXp + result.xpEarned,
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
}

final playerProfileProvider =
    NotifierProvider<PlayerProfileNotifier, PlayerProfile>(
      PlayerProfileNotifier.new,
    );
