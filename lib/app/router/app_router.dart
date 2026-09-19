import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/games/guess_borders/presentation/screens/guess_borders_screen.dart';
import '../../features/games/guess_capital/presentation/screens/guess_capital_screen.dart';
import '../../features/games/guess_emoji/presentation/screens/guess_emoji_screen.dart';
import '../../features/games/guess_flag/presentation/screens/guess_flag_screen.dart';
import '../../features/games/guess_outline/presentation/screens/guess_outline_screen.dart';
import '../../features/games/name_all/presentation/screens/name_all_screen.dart';
import '../../features/games/name_as_many/presentation/screens/name_as_many_screen.dart';
import '../../features/games/name_category/presentation/screens/name_category_screen.dart';
import '../../features/games/name_continent/presentation/screens/name_continent_screen.dart';
import '../../features/games/name_letter/presentation/screens/name_letter_screen.dart';
import '../../features/games/presentation/screens/games_screen.dart';
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
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.guessOutline,
      builder: (context, state) => const GuessOutlineScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.guessCapital,
      builder: (context, state) => const GuessCapitalScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.guessBorders,
      builder: (context, state) => const GuessBordersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.nameAll,
      builder: (context, state) => const NameAllScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.nameAsMany,
      builder: (context, state) => const NameAsManyScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.nameContinent,
      builder: (context, state) => const NameContinentScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.nameCategory,
      builder: (context, state) => const NameCategoryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: RoutePaths.nameLetter,
      builder: (context, state) => const NameLetterScreen(),
    ),
  ],
  );
}

/// One [GoRouter] per `ProviderScope` — see [buildAppRouter].
final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());
