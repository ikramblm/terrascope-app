import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Central place every game-feel sound effect is triggered from.
///
/// Deliberately fails silently if an asset is missing or a platform's
/// audio subsystem errors out, rather than crashing gameplay — sound is
/// enhancement, never a hard dependency. See `assets/audio/README.md`
/// for what each file is and its (CC0) provenance.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  bool enabled = true;

  final AudioPlayer _sfxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  Future<void> playCorrect() => _play('audio/correct.wav');
  Future<void> playWrong() => _play('audio/wrong.wav');
  Future<void> playTap() => _play('audio/tap.wav');
  Future<void> playComplete() => _play('audio/complete.wav');
  Future<void> playLevelUp() => _play('audio/level_up.wav');
  Future<void> playAchievement() => _play('audio/achievement.wav');

  Future<void> _play(String assetPath) async {
    if (!enabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Missing asset or platform audio issue — never let sound break
      // gameplay. Surfaced only in debug builds.
      if (kDebugMode) {
        debugPrint('SoundService: could not play $assetPath ($e)');
      }
    }
  }
}
