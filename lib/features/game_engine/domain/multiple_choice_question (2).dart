import 'package:flutter/foundation.dart';

import '../../../data/countries/models/country.dart';

/// One question in any "show a clue, pick the country from 4 options"
/// mode. `promptText` is deliberately a plain string — for Guess by Flag
/// it's a flag emoji, for Guess by Emoji it's an emoji-clue sequence —
/// both render identically, which is exactly what lets those two modes
/// (and future emoji/symbol-based modes) share this one question shape.
@immutable
class MultipleChoiceQuestion {
  const MultipleChoiceQuestion({
    required this.promptText,
    required this.correctAnswer,
    required this.options,
  }) : assert(options.length >= 2, 'Need at least 2 options'),
       assert(options.length <= 6, 'Too many options for a clean UI');

  final String promptText;
  final Country correctAnswer;

  /// All choices, correct answer included, in the order to display —
  /// already shuffled by the generator.
  final List<Country> options;
}
