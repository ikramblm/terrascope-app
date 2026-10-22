import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../guess_outline/presentation/widgets/country_outline_shape.dart';
import '../../guess_outline/providers/country_outline_providers.dart';

/// Guess by Emoji's card logo — a themed emoji standing in for "a
/// country, told in emoji", the one deliberate, contained exception to
/// the app's no-emoji rule since this game's entire premise is emoji
/// clues. Nothing else in the app uses emoji glyphs.
class EmojiModeLogo extends StatelessWidget {
  const EmojiModeLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text('🌍', style: TextStyle(fontSize: size, height: 1));
  }
}

/// Guess by Flag's card logo — a real flag instead of a generic outline
/// icon. Brazil's flag was picked for how well its green/yellow/blue
/// happen to sit inside this app's own palette.
class FlagModeLogo extends StatelessWidget {
  const FlagModeLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text('🇧🇷', style: TextStyle(fontSize: size, height: 1));
  }
}

/// Guess by Outline's card logo — a real country silhouette (Italy's,
/// for how instantly recognizable it is at tiny sizes) rendered in
/// white to match every other mode's white-icon-on-color-circle
/// treatment. The colorful green/orange fill the app's palette calls
/// for lives on the actual in-game silhouette instead, where it's the
/// puzzle being solved, not a logo — see [CountryOutlineShape] usage in
/// GuessOutlineScreen.
class OutlineModeLogo extends ConsumerWidget {
  const OutlineModeLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outlinesAsync = ref.watch(countryOutlinesProvider);
    final outline = outlinesAsync.asData?.value['ITA'];
    if (outline == null) {
      return Icon(Icons.public, color: Colors.white, size: size);
    }
    return CountryOutlineShape(
      outline: outline,
      color: Colors.white,
      size: size,
    );
  }
}
