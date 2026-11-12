import 'package:flutter/foundation.dart';

/// AdMob configuration — the ONLY place to edit to go live.
///
/// Debug and profile builds ALWAYS show Google's sample ads, and release
/// builds ALWAYS use the production IDs below. There is no flag to forget:
/// you can never ship test ads by accident, and you can never click your
/// own live ads while developing (AdMob bans accounts for that).
///
/// To add or change a format: in AdMob (admob.google.com) → Apps →
/// TerraScope → Ad units → Add ad unit, copy the unit ID, which looks like
/// `ca-app-pub-1234567890123456/1234567890` (a slash, not a tilde), and
/// paste it below. The App ID in android/app/src/main/AndroidManifest.xml
/// must belong to the same AdMob account (same 16-digit publisher number).
///
/// While a production ID is empty or malformed, release builds simply
/// show no ads of that format rather than failing to load them forever.
class AdConfig {
  const AdConfig._();

  /// Real banner unit (tab screens).
  static const String productionBannerId =
      'ca-app-pub-7551414300470852/4207264235';

  /// Real interstitial unit (full-screen, after some finished games).
  static const String productionInterstitialId =
      'ca-app-pub-7551414300470852/1127010605';

  /// Real rewarded unit ("watch an ad to double your coins"). If this is
  /// ever emptied, the button is simply hidden in release builds.
  static const String productionRewardedId =
      'ca-app-pub-7551414300470852/6088352388';

  /// Google's official sample units for Android.
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  static final RegExp _unitIdPattern = RegExp(r'^ca-app-pub-\d{16}/\d{10}$');

  /// An ad *unit* ID has a slash; an AdMob *App* ID has a tilde
  /// (`ca-app-pub-…~…`) and is not valid here.
  static bool isValidUnitId(String id) => _unitIdPattern.hasMatch(id);

  /// The unit to request for the given build mode, or null when no ads of
  /// that format should be shown.
  static String? resolveId({
    required bool releaseMode,
    required String production,
    required String test,
  }) {
    if (!releaseMode) return test;
    return isValidUnitId(production) ? production : null;
  }

  static String? resolveBannerId({
    required bool releaseMode,
    required String production,
  }) => resolveId(
    releaseMode: releaseMode,
    production: production,
    test: testBannerId,
  );

  static String? get bannerUnitId => resolveBannerId(
    releaseMode: kReleaseMode,
    production: productionBannerId,
  );

  static String? get interstitialUnitId => resolveId(
    releaseMode: kReleaseMode,
    production: productionInterstitialId,
    test: testInterstitialId,
  );

  static String? get rewardedUnitId => resolveId(
    releaseMode: kReleaseMode,
    production: productionRewardedId,
    test: testRewardedId,
  );

  static bool get isConfigured => bannerUnitId != null;
}
