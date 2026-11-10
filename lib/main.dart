import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/ads/ad_service.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/player/data/player_profile_repository.dart';
import 'features/player/providers/player_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fredoka is bundled in assets/google_fonts/, so never hit the network
  // for fonts (a runtime download causes a slow first frame and text that
  // reflows once the font arrives).
  GoogleFonts.config.allowRuntimeFetching = false;
  // If the platform can't give us SharedPreferences for some reason, the
  // game should still run — just without progress surviving a restart —
  // rather than fail to launch at all.
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    prefs = null;
  }

  // Must finish before the player profile loads and tries to sync a
  // streak reminder — see NotificationService's own fail-silent
  // handling for why this is still safe if it doesn't.
  await NotificationService.instance.initialize();

  // Consent form + ads SDK start in the background; the app never waits
  // for them (and never fails if they do).
  unawaited(AdService.instance.initialize());

  runApp(
    ProviderScope(
      overrides: [
        playerProfileRepositoryProvider.overrideWithValue(
          PlayerProfileRepository(prefs),
        ),
      ],
      child: const TerraScopeApp(),
    ),
  );
}
