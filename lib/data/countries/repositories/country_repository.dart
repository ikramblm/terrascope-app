import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/country.dart';

/// Loads and indexes TerraScope's bundled country dataset.
///
/// The dataset ships as an asset (`assets/data/countries.json`) so core
/// gameplay works fully offline; only leaderboards and account sync need
/// connectivity. See that file's provenance notes in
/// `assets/data/README.md`.
class CountryRepository {
  CountryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<Country>? _cache;
  Map<String, Country>? _byCca3;

  static const String _assetPath = 'assets/data/countries.json';

  Future<List<Country>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final countries = decoded
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    _cache = countries;
    _byCca3 = {for (final c in countries) c.cca3: c};
    return countries;
  }

  Future<Country?> byCca3(String cca3) async {
    await loadAll();
    return _byCca3?[cca3];
  }

  Future<List<Country>> byContinent(String continent) async {
    final all = await loadAll();
    return all.where((c) => c.continent == continent).toList(growable: false);
  }

  /// Direct land-bordering neighbors of [country], resolved from its
  /// `borders` cca3 list.
  Future<List<Country>> neighborsOf(Country country) async {
    await loadAll();
    final index = _byCca3;
    if (index == null) return const [];
    return country.borders
        .map((cca3) => index[cca3])
        .whereType<Country>()
        .toList(growable: false);
  }

  int get totalCount => _cache?.length ?? 0;
}
