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

  /// Separate from [_sfxPlayer] on purpose — the global UI tap blip (see
  /// [playTap]) can fire in the same instant as a gameplay sound (e.g.
  /// tapping an answer that's also the moment `playCorrect` fires), and
  /// sharing one player would have each cut the other off mid-sample.
  final AudioPlayer _tapPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  /// [comboLevel] steps the pitch up for consecutive correct answers —
  /// the same one `correct.wav` sample, just played back faster (which
  /// raises its pitch along with it), rather than five separate
  /// pre-rendered files. Caps at a 5-step ramp so a long streak doesn't
  /// end up an inaudible chipmunk squeal.
  Future<void> playCorrect({int comboLevel = 0}) {
    final steps = comboLevel.clamp(0, 5);
    return _play('audio/correct.wav', rate: 1.0 + steps * 0.08);
  }

  Future<void> playWrong() => _play('audio/wrong.wav');
  Future<void> playComplete() => _play('audio/complete.wav');
  Future<void> playLevelUp() => _play('audio/level_up.wav');
  Future<void> playAchievement() => _play('audio/achievement.wav');

  /// The global UI click — fired once per tap, anywhere in the app (see
  /// the root [Listener] in `TerraScopeApp`), so it uses [_tapPlayer]
  /// rather than [_sfxPlayer].
  Future<void> playTap() async {
    if (!enabled) return;
    try {
      await _tapPlayer.play(AssetSource('audio/tap.wav'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SoundService: could not play tap.wav ($e)');
      }
    }
  }

  Future<void> _play(String assetPath, {double rate = 1.0}) async {
    if (!enabled) return;
    try {
      // setPlaybackRate persists on the shared player until changed
      // again, so every call sets it explicitly — including the plain
      // 1.0 calls — rather than assuming the previous rate reset itself.
      await _sfxPlayer.setPlaybackRate(rate);
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
