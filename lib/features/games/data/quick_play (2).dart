import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import 'game_catalog.dart';

/// Launches a random available game mode — the single "Play" action
/// behind both the Home screen's hero button and the bottom nav's
/// floating Play button, so the two never drift out of sync.
void launchQuickPlay(BuildContext context) {
  final available = kGameCatalog.where((m) => m.isAvailable).toList();
  if (available.isEmpty) {
    context.go(RoutePaths.games);
    return;
  }
  final pick = available[Random().nextInt(available.length)];
  context.push(pick.routePath!);
}
