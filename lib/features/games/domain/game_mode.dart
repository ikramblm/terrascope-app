import 'package:flutter/material.dart';

import 'game_category.dart';

/// Describes one playable game mode's identity and catalog metadata.
///
/// This is intentionally decoupled from any single game's rules — the
/// shared game engine (timer/score/XP/combo/streak) is built once new
/// modes plug into, rather than duplicated per mode. `routePath` is null
/// until a mode's screen actually exists; the catalog UI must never
/// present a mode as playable before that's true.
@immutable
class GameMode {
  const GameMode({
    required this.id,
    required this.category,
    required this.title,
    required this.tagline,
    required this.icon,
    this.routePath,
  });

  final String id;
  final GameCategory category;
  final String title;
  final String tagline;
  final IconData icon;

  /// Non-null only once this mode has a real, working screen wired up.
  final String? routePath;

  bool get isAvailable => routePath != null;
}
