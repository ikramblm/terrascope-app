import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../games/guess_outline/data/country_outline_repository.dart';
import '../../../games/guess_outline/presentation/widgets/country_outline_shape.dart';
import '../../../games/guess_outline/providers/country_outline_providers.dart';

/// A completionist's-eye view of world coverage — one real country
/// silhouette per discovered/undiscovered country, gold once found,
/// grayed out until then. Not a geographically placed map (the curated
/// outline dataset covers 166 of 195 countries, not enough to lay out
/// accurately) but a mosaic built from the same real shapes used in
/// Guess by Outline — still something to visibly fill in, which is the
/// point.
class CountryMapMosaic extends ConsumerWidget {
  const CountryMapMosaic({super.key, required this.discoveredCca3s});

  final Set<String> discoveredCca3s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outlinesAsync = ref.watch(countryOutlinesProvider);
    final outlines = outlinesAsync.asData?.value;
    if (outlines == null || outlines.isEmpty) {
      return const SizedBox(height: 96);
    }

    final entries = outlines.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in entries)
          _MosaicChip(
            outline: entry.value,
            discovered: discoveredCca3s.contains(entry.key),
          ),
      ],
    );
  }
}

class _MosaicChip extends StatelessWidget {
  const _MosaicChip({required this.outline, required this.discovered});

  final CountryOutline outline;
  final bool discovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: discovered
            ? AppColors.yellow.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: CountryOutlineShape(
        outline: outline,
        color: discovered
            ? AppColors.yellow
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
        size: 24,
      ),
    );
  }
}
