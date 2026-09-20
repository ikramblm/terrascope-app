import 'package:flutter/foundation.dart';

/// A currency used by a country.
@immutable
class Currency {
  const Currency({required this.code, this.name, this.symbol});

  final String code;
  final String? name;
  final String? symbol;

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: json['code'] as String,
    name: json['name'] as String?,
    symbol: json['symbol'] as String?,
  );
}

/// A single reusable emoji clue for "Guess by Emoji" — kept as its own
/// type (rather than a bare String) so future phases can attach metadata
/// (e.g. difficulty, category) without a breaking model change.
@immutable
class EmojiClue {
  const EmojiClue({required this.emojis, this.difficulty});

  final String emojis;
  final int? difficulty;

  factory EmojiClue.fromJson(Map<String, dynamic> json) => EmojiClue(
    emojis: json['emojis'] as String,
    difficulty: json['difficulty'] as int?,
  );
}

/// A reference to a landmark image/illustration used by "Guess by
/// Landmark" — extensible so landmark assets can be added later without
/// touching the country schema.
@immutable
class LandmarkRef {
  const LandmarkRef({
    required this.name,
    required this.assetPath,
    this.attribution,
  });

  final String name;
  final String assetPath;
  final String? attribution;

  factory LandmarkRef.fromJson(Map<String, dynamic> json) => LandmarkRef(
    name: json['name'] as String,
    assetPath: json['assetPath'] as String,
    attribution: json['attribution'] as String?,
  );
}

/// A single country in TerraScope's canonical dataset.
///
/// TerraScope's "195 countries" is a fixed, documented list: the 193 UN
/// member states plus the 2 UN General Assembly observer states (the Holy
/// See and the State of Palestine). See `assets/data/countries.json`,
/// generated from the mledoze/countries open dataset — see
/// `assets/data/README.md` for provenance and regeneration instructions.
@immutable
class Country {
  const Country({
    required this.cca2,
    required this.cca3,
    required this.nameCommon,
    required this.nameOfficial,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.continent,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.population,
    required this.flagEmoji,
    required this.currencies,
    required this.languages,
    required this.borders,
    required this.landlocked,
    required this.independent,
    required this.unMember,
    required this.altSpellings,
    required this.landmarks,
    required this.emojiClues,
  });

  /// ISO 3166-1 alpha-2 code, e.g. "FR".
  final String cca2;

  /// ISO 3166-1 alpha-3 code, e.g. "FRA". Used as the canonical id
  /// throughout the app (border lists, GeoJSON feature ids, providers).
  final String cca3;

  final String nameCommon;
  final String nameOfficial;

  /// Null only for entries with no formally recognized capital.
  final String? capital;

  final String region;
  final String subregion;

  /// One of: Africa, Asia, Europe, North America, South America, Oceania.
  final String continent;

  final double? latitude;
  final double? longitude;

  /// Square kilometers.
  final double? area;

  /// Not present in the source dataset yet — nullable until backfilled
  /// from a maintained population source (tracked for a later phase).
  final int? population;

  final String flagEmoji;
  final List<Currency> currencies;
  final List<String> languages;

  /// cca3 codes of directly bordering countries. Empty for islands and
  /// other countries with no land border — not a data-loading error.
  final List<String> borders;

  final bool landlocked;
  final bool independent;
  final bool unMember;

  /// Alternate names/spellings accepted as correct answers in typed
  /// answer validation (in addition to common/official names).
  final List<String> altSpellings;

  final List<LandmarkRef> landmarks;
  final List<EmojiClue> emojiClues;

  bool get isIsland => borders.isEmpty;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      cca2: json['cca2'] as String,
      cca3: json['cca3'] as String,
      nameCommon: json['nameCommon'] as String,
      nameOfficial: json['nameOfficial'] as String,
      capital: json['capital'] as String?,
      region: json['region'] as String? ?? '',
      subregion: json['subregion'] as String? ?? '',
      continent: json['continent'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      population: json['population'] as int?,
      flagEmoji: json['flagEmoji'] as String? ?? '',
      currencies: (json['currencies'] as List<dynamic>? ?? const [])
          .map((e) => Currency.fromJson(e as Map<String, dynamic>))
          .toList(),
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      borders: (json['borders'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      landlocked: json['landlocked'] as bool? ?? false,
      independent: json['independent'] as bool? ?? false,
      unMember: json['unMember'] as bool? ?? false,
      altSpellings: (json['altSpellings'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      landmarks: (json['landmarks'] as List<dynamic>? ?? const [])
          .map((e) => LandmarkRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      emojiClues: (json['emojiClues'] as List<dynamic>? ?? const [])
          .map((e) => EmojiClue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) => other is Country && other.cca3 == cca3;

  @override
  int get hashCode => cca3.hashCode;

  @override
  String toString() => 'Country($nameCommon, $cca3)';
}
