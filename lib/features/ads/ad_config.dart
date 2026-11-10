import 'package:flutter/foundation.dart';

/// AdMob configuration — the ONLY place to edit to go live.
///
/// Debug and profile builds ALWAYS show Google's sample ads, and release
/// builds ALWAYS use [productionBannerId]. There is no flag to forget:
/// you can never ship test ads by accident, and you can never click your
/// own live ads while developing (AdMob bans accounts for that).
///
/// To go live:
/// 1. In AdMob (admob.google.com) → Apps → TerraScope → Ad units → Add ad
///    unit → **Banner**. Copy the unit ID, which looks like
///    `ca-app-pub-1234567890123456/1234567890` (a slash, not a tilde).
/// 2. Paste it into [productionBannerId] below.
/// 3. The App ID in android/app/src/main/AndroidManifest.xml must belong
///    to the same AdMob account (same 16-digit publisher number).
///
/// While [productionBannerId] is empty or malformed, release builds show
/// no ads at all rather than failing to load them forever.
class AdConfig {
  const AdConfig._();

  /// Your real banner ad unit ID from AdMob (format `ca-app-pub-…/…`).
  static const String productionBannerId =
      'ca-app-pub-7551414300470852/4207264235';

  /// Google's official sample banner unit for Android.
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static final RegExp _unitIdPattern = RegExp(r'^ca-app-pub-\d{16}/\d{10}$');

  /// An ad *unit* ID has a slash; an AdMob *App* ID has a tilde
  /// (`ca-app-pub-…~…`) and is not valid here.
  static bool isValidUnitId(String id) => _unitIdPattern.hasMatch(id);

  /// The banner unit to request for the given build mode, or null when no
  /// ads should be shown.
  static String? resolveBannerId({
    required bool releaseMode,
    required String production,
  }) {
    if (!releaseMode) return testBannerId;
    return isValidUnitId(production) ? production : null;
  }

  static String? get bannerUnitId => resolveBannerId(
    releaseMode: kReleaseMode,
    production: productionBannerId,
  );

  static bool get isConfigured => bannerUnitId != null;
}
