import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/features/ads/ad_config.dart';

void main() {
  const realUnit = 'ca-app-pub-7551414300470852/1234567890';

  group('banner unit selection', () {
    test('debug/profile builds always use Google sample ads', () {
      expect(
        AdConfig.resolveBannerId(releaseMode: false, production: realUnit),
        AdConfig.testBannerId,
      );
      expect(
        AdConfig.resolveBannerId(releaseMode: false, production: ''),
        AdConfig.testBannerId,
      );
    });

    test('release builds use the production unit, never the sample', () {
      expect(
        AdConfig.resolveBannerId(releaseMode: true, production: realUnit),
        realUnit,
      );
    });

    test('release builds show no ads until a valid unit is configured', () {
      expect(
        AdConfig.resolveBannerId(releaseMode: true, production: ''),
        isNull,
      );
    });

    test('an AdMob App ID (tilde) is rejected as a banner unit', () {
      const appId = 'ca-app-pub-7551414300470852~9329627811';
      expect(AdConfig.isValidUnitId(appId), isFalse);
      expect(
        AdConfig.resolveBannerId(releaseMode: true, production: appId),
        isNull,
      );
    });

    test('unit-id format check', () {
      expect(AdConfig.isValidUnitId(realUnit), isTrue);
      expect(AdConfig.isValidUnitId(AdConfig.testBannerId), isTrue);
      expect(AdConfig.isValidUnitId('ca-app-pub-XXXX/YYYY'), isFalse);
      expect(AdConfig.isValidUnitId(' $realUnit'), isFalse);
      expect(AdConfig.isValidUnitId(''), isFalse);
    });
  });

  group('shipped configuration', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final appIdMatch = RegExp(
      r'com\.google\.android\.gms\.ads\.APPLICATION_ID"\s+android:value="(ca-app-pub-\d{16})~\d{10}"',
    ).firstMatch(manifest);

    test('manifest carries a well-formed AdMob App ID', () {
      expect(appIdMatch, isNotNull);
    });

    test('manifest App ID is not Google\'s sample App ID', () {
      expect(appIdMatch!.group(1), isNot('ca-app-pub-3940256099942544'));
    });

    test('production banner unit, once set, matches the App ID account', () {
      if (AdConfig.productionBannerId.isEmpty) {
        // Not configured yet: release builds correctly show no ads.
        expect(AdConfig.bannerUnitId, anyOf(isNull, AdConfig.testBannerId));
        return;
      }
      expect(AdConfig.isValidUnitId(AdConfig.productionBannerId), isTrue);
      expect(
        AdConfig.productionBannerId.startsWith('${appIdMatch!.group(1)}/'),
        isTrue,
        reason: 'banner unit and manifest App ID are from different accounts',
      );
    });
    test('production interstitial and rewarded units match the App ID account', () {
      for (final id in [
        AdConfig.productionInterstitialId,
        AdConfig.productionRewardedId,
      ]) {
        if (id.isEmpty) continue; // not created yet: release shows none
        expect(AdConfig.isValidUnitId(id), isTrue);
        expect(
          id.startsWith('${appIdMatch!.group(1)}/'),
          isTrue,
          reason: '$id is from a different AdMob account than the manifest',
        );
      }
      expect(AdConfig.isValidUnitId(AdConfig.productionInterstitialId), isTrue);
    });

    test('debug builds use Google test units for every format', () {
      expect(
        AdConfig.resolveId(
          releaseMode: false,
          production: AdConfig.productionInterstitialId,
          test: AdConfig.testInterstitialId,
        ),
        AdConfig.testInterstitialId,
      );
      expect(
        AdConfig.resolveId(
          releaseMode: true,
          production: '',
          test: AdConfig.testRewardedId,
        ),
        isNull,
      );
    });
  });
}
