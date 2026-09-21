import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/player/data/player_profile_repository.dart';
import 'features/player/providers/player_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If the platform can't give us SharedPreferences for some reason, the
  // game should still run — just without progress surviving a restart —
  // rather than fail to launch at all.
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    prefs = null;
  }

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
