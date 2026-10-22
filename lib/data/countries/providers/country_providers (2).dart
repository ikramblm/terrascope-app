import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/country.dart';
import '../repositories/country_repository.dart';

final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  return CountryRepository();
});

/// All 195 TerraScope countries, loaded once from the bundled asset.
final allCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final repo = ref.watch(countryRepositoryProvider);
  return repo.loadAll();
});

final countriesByContinentProvider =
    FutureProvider.family<List<Country>, String>((ref, continent) async {
      final all = await ref.watch(allCountriesProvider.future);
      return all.where((c) => c.continent == continent).toList(growable: false);
    });

final countryByCca3Provider = FutureProvider.family<Country?, String>((
  ref,
  cca3,
) async {
  final all = await ref.watch(allCountriesProvider.future);
  for (final c in all) {
    if (c.cca3 == cca3) return c;
  }
  return null;
});
