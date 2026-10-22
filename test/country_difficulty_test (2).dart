import 'package:flutter_test/flutter_test.dart';
import 'package:terrascope_app/data/countries/models/country.dart';
import 'package:terrascope_app/features/game_engine/domain/game_difficulty.dart';
import 'package:terrascope_app/features/game_engine/logic/country_difficulty.dart';

Country _c(String cca3) => Country(
  cca2: cca3.substring(0, 2),
  cca3: cca3,
  nameCommon: cca3,
  nameOfficial: cca3,
  capital: null,
  region: '',
  subregion: '',
  continent: '',
  latitude: null,
  longitude: null,
  area: null,
  population: null,
  flagEmoji: '',
  currencies: const [],
  languages: const [],
  borders: const [],
  landlocked: false,
  independent: true,
  unMember: true,
  altSpellings: const [],
  landmarks: const [],
  emojiClues: const [],
);

void main() {
  // 10 famous, 10 middling, 10 obscure.
  final easy = [
    'USA', 'FRA', 'BRA', 'JPN', 'EGY', 'ITA', 'IND', 'CHN', 'DZA', 'AUS',
  ].map(_c).toList();
  final medium = [
    'HUN', 'NPL', 'GHA', 'ECU', 'QAT', 'BLR', 'MNG', 'URY', 'LUX', 'MLT',
  ].map(_c).toList();
  final hard = [
    'TUV', 'NRU', 'PLW', 'VAT', 'SMR', 'KIR', 'BTN', 'LSO', 'COM', 'MHL',
  ].map(_c).toList();
  final all = [...easy, ...medium, ...hard];

  test('each level returns only its own countries when there are enough', () {
    expect(
      CountryDifficulty.filter(all, GameDifficulty.easy).map((c) => c.cca3),
      easy.map((c) => c.cca3),
    );
    expect(
      CountryDifficulty.filter(all, GameDifficulty.medium).map((c) => c.cca3),
      medium.map((c) => c.cca3),
    );
    expect(
      CountryDifficulty.filter(all, GameDifficulty.hard).map((c) => c.cca3),
      hard.map((c) => c.cca3),
    );
  });

  test('unlisted countries count as hard', () {
    expect(CountryDifficulty.levelOf('ZZZ'), GameDifficulty.hard);
  });

  test('a thin level is topped up from the nearest level', () {
    // Only 3 hard countries available: Hard borrows from Medium first.
    final pool = [...hard.take(3), ...medium, ...easy];
    final picked = CountryDifficulty.filter(pool, GameDifficulty.hard);
    expect(picked.length, greaterThanOrEqualTo(10));
    expect(picked.take(3).map((c) => c.cca3), ['TUV', 'NRU', 'PLW']);
    expect(picked.skip(3).every((c) => medium.contains(c)), isTrue);
  });
}
