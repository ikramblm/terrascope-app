import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// One country's silhouette: one or more polygon parts (a mainland plus
/// any islands/exclaves), each part a list of rings in `[lon, lat]`
/// degrees — ring 0 is the exterior, any further rings are holes (an
/// enclave like Lesotho inside South Africa).
typedef CountryOutline = List<List<List<Offset>>>;

/// Loads the curated `country_outlines.json` dataset — simplified country
/// boundary polygons converted from Natural Earth's public-domain 110m
/// dataset (see `assets/data/README.md` for provenance and coverage).
class CountryOutlineRepository {
  CountryOutlineRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const String _assetPath = 'assets/data/country_outlines.json';

  Map<String, CountryOutline>? _cache;

  Future<Map<String, CountryOutline>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = decoded.map((cca3, polygons) {
      final outline = (polygons as List<dynamic>).map((poly) {
        return (poly as List<dynamic>).map((ring) {
          return (ring as List<dynamic>)
              .map((point) => Offset((point[0] as num).toDouble(), (point[1] as num).toDouble()))
              .toList();
        }).toList();
      }).toList();
      return MapEntry(cca3, outline);
    });
    _cache = result;
    return result;
  }

  /// cca3 codes that have outline data.
  Future<Set<String>> availableCca3s() async {
    final all = await loadAll();
    return all.keys.toSet();
  }
}
