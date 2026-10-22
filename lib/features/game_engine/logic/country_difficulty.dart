import '../../../data/countries/models/country.dart';
import '../domain/game_difficulty.dart';

/// Difficulty is about *which countries you get asked*, not about speed.
///
/// - Easy: famous countries almost everyone can place.
/// - Medium: countries most people have heard of but know less well.
/// - Hard: the obscure ones — micro-states, small islands, and lesser-known
///   nations that are genuinely hard to guess.
///
/// Anything not listed in [_easy] or [_medium] is Hard, so a country added
/// to the dataset later is automatically treated as hard.
class CountryDifficulty {
  const CountryDifficulty._();

  /// Seconds per question for the Easy/Medium/Hard games. Every level
  /// uses the same clock — only the countries change.
  static const int standardSeconds = 10;

  static const Set<String> _easy = {
    'USA', 'CAN', 'MEX', 'BRA', 'ARG', 'COL', 'PER', 'CHL', 'GBR', 'FRA',
    'DEU', 'ITA', 'ESP', 'PRT', 'NLD', 'BEL', 'CHE', 'AUT', 'SWE', 'NOR',
    'DNK', 'FIN', 'IRL', 'GRC', 'TUR', 'RUS', 'UKR', 'POL', 'EGY', 'ZAF',
    'NGA', 'KEN', 'MAR', 'DZA', 'TUN', 'ETH', 'CHN', 'JPN', 'KOR', 'PRK',
    'IND', 'PAK', 'IDN', 'THA', 'VNM', 'PHL', 'AUS', 'NZL', 'SAU', 'ARE',
    'ISR', 'IRN', 'IRQ', 'CUB', 'AFG', 'LBY', 'JAM',
  };

  static const Set<String> _medium = {
    'HUN', 'CZE', 'ROU', 'BGR', 'SRB', 'HRV', 'ISL', 'SVK', 'SVN', 'BLR',
    'LTU', 'LVA', 'EST', 'BIH', 'ALB', 'CYP', 'GEO', 'ARM', 'AZE', 'KAZ',
    'UZB', 'MNG', 'MYS', 'SGP', 'MMR', 'KHM', 'LAO', 'NPL', 'LKA', 'BGD',
    'JOR', 'LBN', 'SYR', 'YEM', 'OMN', 'KWT', 'QAT', 'BHR', 'ECU', 'VEN',
    'BOL', 'URY', 'PRY', 'PAN', 'CRI', 'GTM', 'HND', 'NIC', 'SLV', 'DOM',
    'HTI', 'TTO', 'BHS', 'GHA', 'SEN', 'CIV', 'CMR', 'COD', 'AGO', 'TZA',
    'UGA', 'SDN', 'ZWE', 'ZMB', 'MOZ', 'NAM', 'BWA', 'MDG', 'SOM', 'LUX',
    'MLT', 'MKD', 'MNE', 'MDA', 'TKM', 'KGZ', 'TJK', 'ERI', 'MLI', 'NER',
    'TCD', 'MRT',
  };

  /// Which level a country belongs to.
  static GameDifficulty levelOf(String cca3) {
    if (_easy.contains(cca3)) return GameDifficulty.easy;
    if (_medium.contains(cca3)) return GameDifficulty.medium;
    return GameDifficulty.hard;
  }

  /// The countries from [pool] that belong to [difficulty].
  ///
  /// Some games only have data for part of the world (emoji clues,
  /// outlines, borders), so a level can end up with too few countries to
  /// fill a round. In that case the nearest levels top it up — Easy
  /// borrows from Medium first, Hard from Medium first, and Medium from
  /// Easy first — so a round is always full, but it stays as close to
  /// the chosen level as the data allows.
  static List<Country> filter(
    List<Country> pool,
    GameDifficulty difficulty, {
    int minCount = 10,
  }) {
    List<Country> at(GameDifficulty d) =>
        pool.where((c) => levelOf(c.cca3) == d).toList();

    final order = switch (difficulty) {
      GameDifficulty.easy => [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      GameDifficulty.medium => [
        GameDifficulty.medium,
        GameDifficulty.easy,
        GameDifficulty.hard,
      ],
      GameDifficulty.hard => [
        GameDifficulty.hard,
        GameDifficulty.medium,
        GameDifficulty.easy,
      ],
    };

    final result = <Country>[];
    for (final level in order) {
      result.addAll(at(level));
      if (result.length >= minCount) break;
    }
    return result;
  }
}
