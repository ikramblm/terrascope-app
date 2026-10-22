import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Starts the Google Mobile Ads SDK — after the user has been through
/// Google's consent flow (UMP), which is required for users in the EU,
/// UK and some other regions. [ready] flips to true only once ads may
/// legally be requested; until then (and always in tests, on web, and
/// when [AdConfig] isn't configured) no ad code runs at all.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final ValueNotifier<bool> ready = ValueNotifier<bool>(false);

  bool _started = false;

  Future<void> initialize() async {
    if (_started) return;
    _started = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (!AdConfig.isConfigured) return;

    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (FormError error) => updated.complete(),
      );
      await updated.future;

      final dismissed = Completer<void>();
      ConsentForm.loadAndShowConsentFormIfRequired(
        (FormError? error) => dismissed.complete(),
      );
      await dismissed.future;

      if (!await ConsentInformation.instance.canRequestAds()) return;

      // A family-friendly quiz: only allow ads rated suitable for
      // general audiences.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      await MobileAds.instance.initialize();
      ready.value = true;
    } catch (_) {
      // Ads are a bonus: any failure just means no ads, never a crash.
    }
  }
}
