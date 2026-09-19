/// Centralized route path constants so screens never hardcode strings.
abstract class RoutePaths {
  RoutePaths._();

  static const String home = '/home';
  static const String games = '/games';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';

  static const String guessFlag = '/games/guess-flag';
  static const String guessEmoji = '/games/guess-emoji';
  static const String guessOutline = '/games/guess-outline';
  static const String guessCapital = '/games/guess-capital';
  static const String guessBorders = '/games/guess-borders';

  static const String nameAll = '/games/name-all';
  static const String nameAsMany = '/games/name-as-many';
  static const String nameContinent = '/games/name-continent';
  static const String nameCategory = '/games/name-category';
  static const String nameLetter = '/games/name-letter';
}
