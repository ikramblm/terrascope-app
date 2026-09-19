import 'package:flutter/material.dart';

import '../../../app/router/route_paths.dart';
import '../domain/game_category.dart';
import '../domain/game_mode.dart';

/// The full catalog of TerraScope game modes.
///
/// Every mode from the product spec is listed here from Phase 1 onward so
/// the Games tab always shows the complete lineup — but `routePath` stays
/// null (rendering as "Coming soon" and disabled) until that mode's real
/// screen ships. Nothing here is a fake/dead button: unavailable modes
/// are visibly and honestly non-interactive.
const List<GameMode> kGameCatalog = [
  // GUESS
  GameMode(
    id: 'guess_emoji',
    category: GameCategory.guess,
    title: 'Guess by Emoji',
    tagline: 'A country, told in emoji',
    icon: Icons.emoji_emotions_outlined,
    routePath: RoutePaths.guessEmoji,
  ),
  GameMode(
    id: 'guess_flag',
    category: GameCategory.guess,
    title: 'Guess by Flag',
    tagline: 'Name the country behind the flag',
    icon: Icons.flag_outlined,
    routePath: RoutePaths.guessFlag,
  ),
  GameMode(
    id: 'guess_outline',
    category: GameCategory.guess,
    title: 'Guess by Outline',
    tagline: 'Recognize a country by its silhouette',
    icon: Icons.crop_free,
    routePath: RoutePaths.guessOutline,
  ),
  GameMode(
    id: 'guess_borders',
    category: GameCategory.guess,
    title: 'Guess by Borders',
    tagline: 'Identify a country from its neighbors',
    icon: Icons.hub_outlined,
    routePath: RoutePaths.guessBorders,
  ),
  GameMode(
    id: 'guess_capital',
    category: GameCategory.guess,
    title: 'Guess by Capital',
    tagline: 'Match a capital to its country',
    icon: Icons.location_city_outlined,
    routePath: RoutePaths.guessCapital,
  ),
  GameMode(
    id: 'guess_clues',
    category: GameCategory.guess,
    title: 'Guess by Clues',
    tagline: 'Fewer clues, more points',
    icon: Icons.lightbulb_outline,
  ),
  GameMode(
    id: 'guess_landmark',
    category: GameCategory.guess,
    title: 'Guess by Landmark',
    tagline: 'Where in the world is this?',
    icon: Icons.account_balance_outlined,
  ),
  GameMode(
    id: 'guess_location',
    category: GameCategory.guess,
    title: 'Guess by Location',
    tagline: 'Tap the map, as close as you can',
    icon: Icons.my_location_outlined,
  ),

  // NAME
  GameMode(
    id: 'name_all',
    category: GameCategory.name,
    title: 'Name All Countries',
    tagline: 'Every country, no clock',
    icon: Icons.public,
    routePath: RoutePaths.nameAll,
  ),
  GameMode(
    id: 'name_continent',
    category: GameCategory.name,
    title: 'Name by Continent',
    tagline: 'One continent at a time',
    icon: Icons.terrain_outlined,
    routePath: RoutePaths.nameContinent,
  ),
  GameMode(
    id: 'name_letter',
    category: GameCategory.name,
    title: 'Name by Letter',
    tagline: 'A country for every letter',
    icon: Icons.abc,
    routePath: RoutePaths.nameLetter,
  ),
  GameMode(
    id: 'name_category',
    category: GameCategory.name,
    title: 'Name by Category',
    tagline: 'Islands, landlocked, and more',
    icon: Icons.category_outlined,
    routePath: RoutePaths.nameCategory,
  ),
  GameMode(
    id: 'name_borders_of',
    category: GameCategory.name,
    title: 'Name the Neighbors',
    tagline: 'Every country bordering one nation',
    icon: Icons.route_outlined,
  ),
  GameMode(
    id: 'name_as_many',
    category: GameCategory.name,
    title: 'Name as Many as Possible',
    tagline: 'No timer, no limit',
    icon: Icons.all_inclusive,
    routePath: RoutePaths.nameAsMany,
  ),

  // SPEED
  GameMode(
    id: 'speed_country',
    category: GameCategory.speed,
    title: 'Country Speed Run',
    tagline: 'Fastest correct streak wins',
    icon: Icons.bolt_outlined,
    routePath: RoutePaths.speedCountry,
  ),
  GameMode(
    id: 'speed_flag',
    category: GameCategory.speed,
    title: 'Flag Speed Run',
    tagline: 'Flags, fast',
    icon: Icons.speed,
    routePath: RoutePaths.speedFlag,
  ),
  GameMode(
    id: 'speed_capital',
    category: GameCategory.speed,
    title: 'Capital Speed Run',
    tagline: 'Capitals, fast',
    icon: Icons.timer_outlined,
    routePath: RoutePaths.speedCapital,
  ),
  GameMode(
    id: 'speed_60s',
    category: GameCategory.speed,
    routePath: RoutePaths.speed60s,
    title: '60-Second Challenge',
    tagline: 'One minute, as many as you can',
    icon: Icons.hourglass_bottom,
  ),
];
