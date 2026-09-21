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
    required this.bestScore,
    required this.gamesPlayed,
    required this.totalCorrectAnswers,
    required this.totalQuestionsAnswered,
    this.lastPlayedAt,
  });

  factory PlayerProfile.newPlayer() => const PlayerProfile(
    totalXp: 0,
    currentStreakDays: 0,
    longestStreakDays: 0,
    discoveredCountryCodes: {},
    bestScore: 0,
    gamesPlayed: 0,
    totalCorrectAnswers: 0,
    totalQuestionsAnswered: 0,
  );

  final int totalXp;
  final int currentStreakDays;
  final int longestStreakDays;

  /// Highest `totalScore` from any single completed session.
  final int bestScore;

  /// Total completed game sessions, across every mode.
  final int gamesPlayed;

  /// Career totals behind [overallAccuracy] — summed across every
  /// session, every mode.
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;

  /// cca3 codes of every country this player has answered correctly at
  /// least once, across all game modes.
  final Set<String> discoveredCountryCodes;

  final DateTime? lastPlayedAt;

  int get countriesDiscovered => discoveredCountryCodes.length;

  PlayerLevel get level => PlayerLevel.forXp(totalXp);

  /// Career accuracy across every question ever answered, in [0, 1].
  /// `0` (not null) before the first game — displayed as "—" by the UI
  /// rather than a misleading 0%.
  double get overallAccuracy => totalQuestionsAnswered == 0
      ? 0
      : totalCorrectAnswers / totalQuestionsAnswered;

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
    int? bestScore,
    int? gamesPlayed,
    int? totalCorrectAnswers,
    int? totalQuestionsAnswered,
    DateTime? lastPlayedAt,
  }) {
    return PlayerProfile(
      totalXp: totalXp ?? this.totalXp,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      discoveredCountryCodes:
          discoveredCountryCodes ?? this.discoveredCountryCodes,
      bestScore: bestScore ?? this.bestScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  /// Schema version this shape serializes as — bump alongside a
  /// breaking field change so [PlayerProfileRepository] can tell an old
  /// save apart from a corrupt one instead of guessing.
  static const int schemaVersion = 1;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'totalXp': totalXp,
    'currentStreakDays': currentStreakDays,
    'longestStreakDays': longestStreakDays,
    'discoveredCountryCodes': discoveredCountryCodes.toList(),
    'bestScore': bestScore,
    'gamesPlayed': gamesPlayed,
    'totalCorrectAnswers': totalCorrectAnswers,
    'totalQuestionsAnswered': totalQuestionsAnswered,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
  };

  /// Throws on anything unreadable — [PlayerProfileRepository] treats a
  /// failure here the same as no saved profile at all, rather than
  /// crashing app startup over a corrupt or unrecognized save.
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unrecognized PlayerProfile schema version');
    }
    return PlayerProfile(
      totalXp: json['totalXp'] as int,
      currentStreakDays: json['currentStreakDays'] as int,
      longestStreakDays: json['longestStreakDays'] as int,
      discoveredCountryCodes: (json['discoveredCountryCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      bestScore: json['bestScore'] as int,
      gamesPlayed: json['gamesPlayed'] as int,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int,
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.parse(json['lastPlayedAt'] as String),
    );
  }
}
