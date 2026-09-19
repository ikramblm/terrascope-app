import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game_engine/domain/game_result.dart';
import '../domain/player_profile.dart';

/// Holds the current player's progression state in memory.
///
/// TODO(phase-6): back this with local persistence (so progress survives
/// an app restart) and optional account sync.
class PlayerProfileNotifier extends Notifier<PlayerProfile> {
  @override
  PlayerProfile build() => PlayerProfile.newPlayer();

  void addXp(int amount) {
    state = state.copyWith(totalXp: state.totalXp + amount);
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
      bestScore: result.totalScore > state.bestScore ? result.totalScore : state.bestScore,
      gamesPlayed: state.gamesPlayed + 1,
      totalCorrectAnswers: state.totalCorrectAnswers + result.correctCount,
      totalQuestionsAnswered: state.totalQuestionsAnswered + result.totalQuestions,
      lastPlayedAt: DateTime.now(),
    );
  }
}

final playerProfileProvider =
    NotifierProvider<PlayerProfileNotifier, PlayerProfile>(
  PlayerProfileNotifier.new,
);
