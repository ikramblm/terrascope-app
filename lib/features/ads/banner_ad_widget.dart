import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';

/// A standard 320x50 banner. Takes no space until an ad has actually
/// loaded, so a failed or blocked ad never leaves an empty gap. A failed
/// load (no fill, no signal) is retried with a growing delay, so ads
/// appear on their own once the network or inventory recovers.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const _firstRetry = Duration(seconds: 30);
  static const _maxRetry = Duration(minutes: 5);

  BannerAd? _ad;
  bool _loaded = false;
  int _failures = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    AdService.instance.ready.addListener(_maybeLoad);
    _maybeLoad();
  }

  void _maybeLoad() {
    final unitId = AdConfig.bannerUnitId;
    if (_ad != null || unitId == null || !AdService.instance.ready.value) {
      return;
    }
    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _failures = 0;
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _ad = null;
          if (!mounted) return;
          setState(() => _loaded = false);
          _scheduleRetry();
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final seconds = math.min(
      _firstRetry.inSeconds * (1 << math.min(_failures, 6)),
      _maxRetry.inSeconds,
    );
    _failures++;
    _retryTimer = Timer(Duration(seconds: seconds), _maybeLoad);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    AdService.instance.ready.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
