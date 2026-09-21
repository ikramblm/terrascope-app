import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/async_state_views.dart';
import '../../../../core/widgets/max_width_box.dart';
import '../../../../data/countries/providers/country_providers.dart';

/// Lists tab: every country, browsable three ways — by name, by
/// capital, or just its flag. Real data throughout (the bundled
/// 195-country dataset), never placeholder rows.
class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: MaxWidthBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lists', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Every country, at a glance.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Countries'),
                    Tab(text: 'Capitals'),
                    Tab(text: 'Flags'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _CountriesTab(),
                      _CapitalsTab(),
                      _FlagsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountriesTab extends ConsumerWidget {
  const _CountriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final sorted = [...countries]
          ..sort((a, b) => a.nameCommon.compareTo(b.nameCommon));
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final country = sorted[index];
            return _CountryRow(
              flagEmoji: country.flagEmoji,
              title: country.nameCommon,
              subtitle: country.capital ?? 'No capital',
            );
          },
        );
      },
    );
  }
}

class _CapitalsTab extends ConsumerWidget {
  const _CapitalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final withCapital = countries.where((c) => c.capital != null).toList()
          ..sort((a, b) => a.capital!.compareTo(b.capital!));
        final withoutCapital =
            countries.where((c) => c.capital == null).toList()
              ..sort((a, b) => a.nameCommon.compareTo(b.nameCommon));
        final sorted = [...withCapital, ...withoutCapital];
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final country = sorted[index];
            return _CountryRow(
              flagEmoji: country.flagEmoji,
              title: country.capital ?? 'No capital',
              subtitle: country.nameCommon,
            );
          },
        );
      },
    );
  }
}

class _FlagsTab extends ConsumerWidget {
  const _FlagsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(allCountriesProvider);
    return countriesAsync.when(
      loading: () => const LoadingView(message: 'Loading countries…'),
      error: (err, st) => ErrorView(message: '$err'),
      data: (countries) {
        final sorted = [...countries]
          ..sort((a, b) => a.nameCommon.compareTo(b.nameCommon));
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 96,
          ),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final country = sorted[index];
            return _FlagTile(
              flagEmoji: country.flagEmoji,
              name: country.nameCommon,
            );
          },
        );
      },
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.flagEmoji,
    required this.title,
    required this.subtitle,
  });

  final String flagEmoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagTile extends StatelessWidget {
  const _FlagTile({required this.flagEmoji, required this.name});

  final String flagEmoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
