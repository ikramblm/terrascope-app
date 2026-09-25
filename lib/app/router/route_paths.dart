/// Centralized route path constants so screens never hardcode strings.
abstract class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String games = '/games';
  static const String lists = '/lists';
  static const String profile = '/profile';
  static const String dailyChallenge = '/daily-challenge';
  static const String duel = '/duel';

  /// One generic destination for "the screen a difficulty/mode pick
  /// leads to" — the actual widget travels via `extra` on the push, so
  /// every game-launch flow gets its own real browser-history entry
  /// instead of an invisible-to-go_router `Navigator.push`.
  static const String play = '/play';

  /// Nested under [games] (inside its shell branch) so browsing a
  /// category keeps the bottom nav reachable, while still being a real
  /// go_router location that resets when the tab is re-selected.
  static const String gamesCategory = '/games/category';

  static const String guessFlag = '/games/guess-flag';
  static const String guessEmoji = '/games/guess-emoji';
  static const String guessOutline = '/games/guess-outline';
  static const String guessCapital = '/games/guess-capital';
  static const String guessBorders = '/games/guess-borders';
  static const String guessClues = '/games/guess-clues';
  static const String guessLocation = '/games/guess-location';

  static const String nameAll = '/games/name-all';
  static const String nameAsMany = '/games/name-as-many';
  static const String nameContinent = '/games/name-continent';
  static const String nameCategory = '/games/name-category';
  static const String nameLetter = '/games/name-letter';
  static const String nameAlphabet = '/games/name-alphabet';
  static const String nameBordersOf = '/games/name-borders-of';

  static const String speedFlag = '/games/speed-flag';
  static const String speedCapital = '/games/speed-capital';
  static const String speedCountry = '/games/speed-country';
  static const String speed60s = '/games/speed-60s';
}
