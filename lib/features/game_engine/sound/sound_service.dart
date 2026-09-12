import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Central place every game-feel sound effect is triggered from.
///
/// Deliberately fails silently if an asset is missing rather than
/// crashing gameplay — sound is enhancement, never a hard dependency.
/// Until real audio assets are added under `assets/audio/` (see
/// `assets/audio/README.md`), every call here is a safe no-op; wiring
/// the actual playback call sites now means adding the files later is a
/// pure asset drop, no code changes.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  bool enabled = true;

  final AudioPlayer _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> playCorrect() => _play('audio/correct.mp3');
  Future<void> playWrong() => _play('audio/wrong.mp3');
  Future<void> playTap() => _play('audio/tap.mp3');
  Future<void> playComplete() => _play('audio/complete.mp3');
  Future<void> playLevelUp() => _play('audio/level_up.mp3');
  Future<void> playAchievement() => _play('audio/achievement.mp3');

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
