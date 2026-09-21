import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../games/guess_outline/presentation/widgets/country_outline_shape.dart';
import '../../../games/guess_outline/providers/country_outline_providers.dart';

/// A small "here's where it is" reveal shown once a multiple-choice
/// question is answered — the correct country's real silhouette inside
/// a minimized globe, so the question resolves as a geography moment
/// instead of just a right/wrong readout. Never shown before an answer
/// is locked in (it would hand away modes like Guess by Flag, whose
/// whole challenge this outline would otherwise spoil), and it quietly
/// renders nothing for the ~15% of countries outside the curated
/// outline dataset rather than fake a shape.
class AnswerRevealInset extends ConsumerWidget {
  const AnswerRevealInset({super.key, required this.cca3});

  final String cca3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outlinesAsync = ref.watch(countryOutlinesProvider);
    final outline = outlinesAsync.asData?.value[cca3];
    if (outline == null) return const SizedBox.shrink();

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.oceanBlue.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.oceanBlue.withValues(alpha: 0.25)),
      ),
      alignment: Alignment.center,
      child: CountryOutlineShape(
        outline: outline,
        color: AppColors.green,
        size: 48,
      ),
    );
  }
}
