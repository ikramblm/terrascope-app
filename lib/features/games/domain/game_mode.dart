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
    this.logoBuilder,
    this.requiredLevel,
  });

  final String id;
  final GameCategory category;
  final String title;
  final String tagline;
  final IconData icon;

  /// Non-null only once this mode has a real, working screen wired up.
  final String? routePath;

  /// An optional bespoke visual for this mode's card/button — a real
  /// flag, a colored country outline, a themed emoji — used in place of
  /// the plain [icon] wherever this mode is shown. Null falls back to
  /// [icon], which is why every mode still declares one.
  final Widget Function(BuildContext context)? logoBuilder;

  /// Non-null only for a mode the team has chosen to ship *behind* a
  /// numeric player level rather than open immediately — see
  /// [PlayerProfile.numericLevel]. Distinct from [routePath] being
  /// null: a level-gated mode is fully built and honestly unlocks the
  /// moment the player reaches this level, never a claim on a mode
  /// that isn't built yet.
  final int? requiredLevel;

  bool get isAvailable => routePath != null;
}
