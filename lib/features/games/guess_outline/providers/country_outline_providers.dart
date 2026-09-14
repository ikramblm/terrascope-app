import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/country_outline_repository.dart';

final countryOutlineRepositoryProvider = Provider<CountryOutlineRepository>((ref) {
  return CountryOutlineRepository();
});

final countryOutlinesProvider = FutureProvider<Map<String, CountryOutline>>((ref) async {
  final repo = ref.watch(countryOutlineRepositoryProvider);
  return repo.loadAll();
});
