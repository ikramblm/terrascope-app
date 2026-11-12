import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player/providers/player_providers.dart';
import 'game_end_ads.dart';

/// Dropped into every results screen. Does two things:
/// 1. tells [InterstitialManager] a game just finished (it decides whether
///    a full-screen ad is due — see `InterstitialPolicy`), and
/// 2. shows an opt-in "Watch an ad to double your coins" button, only while
///    a rewarded ad is loaded and this game's bonus hasn't been claimed.
class GameEndAds extends ConsumerStatefulWidget {
  const GameEndAds({super.key});

  @override
  ConsumerState<GameEndAds> createState() => _GameEndAdsState();
}

class _GameEndAdsState extends ConsumerState<GameEndAds> {
  @override
  void initState() {
    super.initState();
    InterstitialManager.instance.onGameFinished();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the profile changes so the button disappears (and the
    // coin count updates) right after the bonus is claimed.
    ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);
    final bonus = notifier.lastSessionCoins;

    return ValueListenableBuilder<bool>(
      valueListenable: RewardedManager.instance.available,
      builder: (context, available, _) {
        if (!available || bonus <= 0 || notifier.lastSessionBonusClaimed) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton.icon(
            onPressed: () {
              RewardedManager.instance.show(() {
                notifier.claimDoubleCoins();
              });
            },
            icon: const Icon(Icons.play_circle_outline),
            label: Text('Watch an ad · double your coins (+$bonus)'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        );
      },
    );
  }
}
