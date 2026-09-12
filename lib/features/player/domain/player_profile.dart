import 'package:flutter/foundation.dart';

import 'player_level.dart';

/// A player's progression state.
///
/// Phase 1 shipped this starting at zero for a new player; Phase 2 wires
/// it up to real game sessions via [PlayerProfileNotifier.recordSession],
/// so every field stays an honest reflection of games actually played —
/// nothing here is seeded or simulated.
@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.totalXp,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.discoveredCountryCodes,
    this.lastPlayedAt,
  });

  factory PlayerProfile.newPlayer() => const PlayerProfile(
        totalXp: 0,
        currentStreakDays: 0,
        longestStreakDays: 0,
        discoveredCountryCodes: {},
      );

  final int totalXp;
  final int currentStreakDays;
  final int longestStreakDays;

  /// cca3 codes of every country this player has answered correctly at
  /// least once, across all game modes.
  final Set<String> discoveredCountryCodes;

  final DateTime? lastPlayedAt;

  int get countriesDiscovered => discoveredCountryCodes.length;

  PlayerLevel get level => PlayerLevel.forXp(totalXp);

  /// Progress toward the next level, in [0, 1]. 1.0 (maxed) at the top tier.
  double get levelProgress {
    final next = level.next;
    if (next == null) return 1.0;
    final span = next.minXp - level.minXp;
    if (span <= 0) return 1.0;
    return ((totalXp - level.minXp) / span).clamp(0.0, 1.0);
  }

  PlayerProfile copyWith({
    int? totalXp,
    int? currentStreakDays,
    int? longestStreakDays,
    Set<String>? discoveredCountryCodes,
    DateTime? lastPlayedAt,
  }) {
    return PlayerProfile(
      totalXp: totalXp ?? this.totalXp,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      discoveredCountryCodes: discoveredCountryCodes ?? this.discoveredCountryCodes,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}
