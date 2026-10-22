/// AdMob configuration — the ONLY place you need to edit to go live.
///
/// 1. Create an AdMob account (admob.google.com) and add the app
///    "TerraScope" (Android, package com.terrascope.terrascope_app).
/// 2. Copy the **App ID** (ca-app-pub-…~…) into
///    android/app/src/main/AndroidManifest.xml (the APPLICATION_ID tag).
/// 3. Create one **Banner** ad unit and paste its ID below.
/// 4. Set [useTestAds] to false, then build the release bundle.
///
/// While [useTestAds] is true the app shows Google's sample ads, which
/// are safe to click and earn nothing. Never ship the production build
/// with test ads, and never click your own live ads (AdMob bans
/// accounts for it).
class AdConfig {
  const AdConfig._();

  /// Flip to false for the real, paying release build.
  static const bool useTestAds = true;

  /// Your real banner ad unit ID from AdMob.
  static const String _productionBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  /// Google's official sample banner unit for Android.
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static String get bannerUnitId =>
      useTestAds ? _testBannerId : _productionBannerId;

  /// False while the production ID is still the placeholder, so a build
  /// made before step 3 simply shows no ads instead of failing.
  static bool get isConfigured =>
      useTestAds || !_productionBannerId.contains('XXXX');
}
