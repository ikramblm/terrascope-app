import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_profile.dart';

/// Persists [PlayerProfile] to on-device storage so progress survives
/// closing the app — streaks, Streak Freezes, and coins only mean
/// anything if they do.
///
/// [prefs] is nullable purely as a test seam: [PlayerProfileNotifier]'s
/// tests construct this with `null` to get a deterministic, always-fresh
/// profile with no platform channel involved, the same way
/// `CountryRepository` takes an injectable `AssetBundle`. Production
/// always provides a real instance from `main()`.
class PlayerProfileRepository {
  const PlayerProfileRepository(this._prefs);

  final SharedPreferences? _prefs;
  static const _key = 'player_profile_v1';

  /// Returns `null` on first launch, or if the saved data can't be read
  /// (an old schema, a corrupted value) — either way the caller falls
  /// back to [PlayerProfile.newPlayer] rather than crashing startup.
  PlayerProfile? load() {
    final raw = _prefs?.getString(_key);
    if (raw == null) return null;
    try {
      return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error, stackTrace) {
      developer.log(
        'Discarding unreadable saved PlayerProfile',
        name: 'PlayerProfileRepository',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> save(PlayerProfile profile) async {
    await _prefs?.setString(_key, jsonEncode(profile.toJson()));
  }
}
