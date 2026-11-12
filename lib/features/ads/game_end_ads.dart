import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';
import 'interstitial_policy.dart';

/// Full-screen ads between games. Preloads one so it can appear instantly,
/// shows it a moment after the results screen appears (never mid-game and
/// never at app launch), then loads the next. All failures are silent —
/// a missing ad just means no ad.
class InterstitialManager {
  InterstitialManager._();

  static final InterstitialManager instance = InterstitialManager._();

  static const _showDelay = Duration(milliseconds: 900);
  static const _firstRetry = Duration(seconds: 30);
  static const _maxRetry = Duration(minutes: 5);

  final InterstitialPolicy _policy = InterstitialPolicy();
  InterstitialAd? _ad;
  bool _loading = false;
  bool _listening = false;
  int _failures = 0;
  Timer? _retryTimer;

  /// Hooks into [AdService] so loading starts as soon as ads are allowed.
  void start() {
    if (_listening) return;
    _listening = true;
    AdService.instance.ready.addListener(_load);
    _load();
  }

  void _load() {
    final unitId = AdConfig.interstitialUnitId;
    if (_ad != null ||
        _loading ||
        unitId == null ||
        !AdService.instance.ready.value) {
      return;
    }
    _loading = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _failures = 0;
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _failures++;
          _scheduleRetry();
        },
      ),
    );
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final seconds = math.min(
      _firstRetry.inSeconds * (1 << math.min(_failures - 1, 6)),
      _maxRetry.inSeconds,
    );
    _retryTimer = Timer(Duration(seconds: seconds), _load);
  }

  /// Call once each time a game's results screen appears.
  void onGameFinished() {
    if (AdConfig.interstitialUnitId == null) return;
    final due = _policy.onGameFinished();
    // No timer unless ads are really running (also keeps widget tests clean).
    if (!due || !AdService.instance.ready.value) return;
    Timer(_showDelay, _show);
  }

  void _show() {
    final ad = _ad;
    if (ad == null) {
      // Nothing loaded: stay due for the next game, and try loading again.
      _load();
      return;
    }
    _ad = null;
    _policy.markShown();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _load();
      },
    );
    ad.show();
  }
}

/// "Watch an ad to double your coins". The player chooses to watch; the
/// button only exists while a rewarded ad is actually loaded.
class RewardedManager {
  RewardedManager._();

  static final RewardedManager instance = RewardedManager._();

  static const _firstRetry = Duration(seconds: 30);
  static const _maxRetry = Duration(minutes: 5);

  /// True while a rewarded ad is loaded and ready to show.
  final ValueNotifier<bool> available = ValueNotifier<bool>(false);

  RewardedAd? _ad;
  bool _loading = false;
  bool _listening = false;
  int _failures = 0;
  Timer? _retryTimer;

  void start() {
    if (_listening) return;
    _listening = true;
    AdService.instance.ready.addListener(_load);
    _load();
  }

  void _load() {
    final unitId = AdConfig.rewardedUnitId;
    if (_ad != null ||
        _loading ||
        unitId == null ||
        !AdService.instance.ready.value) {
      return;
    }
    _loading = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _failures = 0;
          _ad = ad;
          available.value = true;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _failures++;
          final seconds = math.min(
            _firstRetry.inSeconds * (1 << math.min(_failures - 1, 6)),
            _maxRetry.inSeconds,
          );
          _retryTimer?.cancel();
          _retryTimer = Timer(Duration(seconds: seconds), _load);
        },
      ),
    );
  }

  /// Shows the ad; [onReward] runs only if the player watched it through.
  /// Returns false if no ad was ready.
  bool show(VoidCallback onReward) {
    final ad = _ad;
    if (ad == null) return false;
    _ad = null;
    available.value = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _load();
      },
    );
    ad.show(onUserEarnedReward: (ad, reward) => onReward());
    return true;
  }
}
