import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/duels/presentation/screens/duel_screen.dart';
import '../../features/games/daily_challenge/presentation/screens/daily_challenge_screen.dart';
import '../../features/games/guess_borders/presentation/screens/guess_borders_screen.dart';
import '../../features/games/guess_capital/presentation/screens/guess_capital_screen.dart';
import '../../features/games/guess_clues/presentation/screens/guess_clues_screen.dart';
import '../../features/games/guess_emoji/presentation/screens/guess_emoji_screen.dart';
import '../../features/games/guess_flag/presentation/screens/guess_flag_screen.dart';
import '../../features/games/guess_location/presentation/screens/guess_location_screen.dart';
import '../../features/games/guess_outline/presentation/screens/guess_outline_screen.dart';
import '../../features/games/name_all/presentation/screens/name_all_screen.dart';
import '../../features/games/name_alphabet/presentation/screens/name_alphabet_screen.dart';
import '../../features/games/name_as_many/presentation/screens/name_as_many_screen.dart';
import '../../features/games/name_borders_of/presentation/screens/name_borders_of_screen.dart';
import '../../features/games/name_category/presentation/screens/name_category_screen.dart';
import '../../features/games/name_continent/presentation/screens/name_continent_screen.dart';
import '../../features/games/name_letter/presentation/screens/name_letter_screen.dart';
import '../../features/games/presentation/screens/games_screen.dart';
import '../../features/games/speed_60s/presentation/screens/speed_60s_screen.dart';
import '../../features/games/speed_capital/presentation/screens/speed_capital_screen.dart';
import '../../features/games/speed_country/presentation/screens/speed_country_screen.dart';
import '../../features/games/speed_flag/presentation/screens/speed_flag_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lists/presentation/screens/lists_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
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
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.games,
                builder: (context, state) => const GamesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.lists,
                builder: (context, state) => const ListsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen gameplay routes: pushed over the bottom-nav shell (not a
      // shell branch) since a game session isn't a tab destination.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.dailyChallenge,
        builder: (context, state) => const DailyChallengeScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.duel,
        builder: (context, state) => const DuelScreen(),
      ),
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
        path: RoutePaths.guessClues,
        builder: (context, state) => const GuessCluesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.guessLocation,
        builder: (context, state) => const GuessLocationScreen(),
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
        path: RoutePaths.nameBordersOf,
        builder: (context, state) => const NameBordersOfScreen(),
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
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.nameAlphabet,
        builder: (context, state) => const NameAlphabetScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.speedFlag,
        builder: (context, state) => const SpeedFlagScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.speedCapital,
        builder: (context, state) => const SpeedCapitalScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.speedCountry,
        builder: (context, state) => const SpeedCountryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.speed60s,
        builder: (context, state) => const Speed60sScreen(),
      ),
    ],
  );
}

/// One [GoRouter] per `ProviderScope` — see [buildAppRouter].
final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());
