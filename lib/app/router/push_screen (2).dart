import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

/// Pushes [screen] through go_router's generic [RoutePaths.play]
/// destination instead of a raw `Navigator.push(MaterialPageRoute(...))`.
/// A plain `Navigator.push` never touches the browser's history — it
/// rides along on whatever history entry the current screen already
/// has, so the back button (in-app or the real browser one) ends up
/// popping more than one screen at a time. Routing it through go_router
/// gives it its own history entry, so back always undoes exactly one
/// step.
extension PushScreenX on BuildContext {
  Future<T?> pushScreen<T extends Object?>(Widget screen) =>
      push<T>(RoutePaths.play, extra: screen);
}
