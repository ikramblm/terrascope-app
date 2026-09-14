import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/game_category.dart';

/// Shared per-category accent color — used by category headers and
/// mode cards so "Guess" is always blue, "Name" always green, "Speed"
/// always orange, everywhere in the Games tab.
Color accentForCategory(GameCategory category) => switch (category) {
      GameCategory.guess => AppColors.indigoBright,
      GameCategory.name => AppColors.emerald,
      GameCategory.speed => AppColors.amber,
    };
