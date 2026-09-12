import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/games/presentation/screens/games_screen.dart';
import '../../features/games/guess_emoji/presentation/screens/guess_emoji_screen.dart';
import '../../features/games/guess_flag/presentation/screens/guess_flag_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import 'route_paths.dart';

/// Builds one [GoRouter] instance, owned by [appRouterProvider].
///
/// Deliberately not a top-level `final` singleton: GoRouter holds mutable
/// navigation state (current location, per-branch stacks) independent of
/// the widget tree, so a module-level singleton would leak that state
/// across separate `ProviderScope`s — invisible in the running app (one
/// scope for its whole lifetime) but silently breaks test isolation
/// between `testWidgets` cases. Scoping it to the provider gives every
/// `ProviderScope` (including each test's) a fresh router.
GoRouter buildAppRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.games,
            builder: (context, state) => const GamesScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.leaderboard,
            builder: (context, state) => const LeaderboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ]),
      ],
    ),
    // Full-screen gameplay routes: pushed over the bottom-nav shell (not a
    // shell branch) since a game session isn't a tab destination.
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.guessFlag,
      builder: (context, state) => const GuessFlagScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.guessEmoji,
      builder: (context, state) => const GuessEmojiScreen(),
    ),
  ],
  );
}

/// One [GoRouter] per `ProviderScope` — see [buildAppRouter].
final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());
