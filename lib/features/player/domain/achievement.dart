import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'player_profile.dart';

/// A collectible badge, unlocked purely from real, already-tracked
/// [PlayerProfile] stats — never simulated or pre-unlocked. If a badge
/// shows unlocked, the player actually did the thing.
@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.isUnlockedFor,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final bool Function(PlayerProfile profile) isUnlockedFor;
}

final List<Achievement> kAchievements = [
  Achievement(
    id: 'world_explorer',
    emoji: '🌍',
    title: 'World Explorer',
    description: 'Discover 10 countries',
    color: AppColors.oceanBlue,
    isUnlockedFor: (p) => p.countriesDiscovered >= 10,
  ),
  Achievement(
    id: 'map_master',
    emoji: '🗺️',
    title: 'Map Master',
    description: 'Discover 50 countries',
    color: AppColors.skyBlue,
    isUnlockedFor: (p) => p.countriesDiscovered >= 50,
  ),
  Achievement(
    id: 'geography_genius',
    emoji: '🌎',
    title: 'Geography Genius',
    description: 'Discover 150 countries',
    color: AppColors.purple,
    isUnlockedFor: (p) => p.countriesDiscovered >= 150,
  ),
  Achievement(
    id: 'week_streak',
    emoji: '🔥',
    title: '7-Day Streak',
    description: 'Play 7 days in a row',
    color: AppColors.orange,
    isUnlockedFor: (p) => p.longestStreakDays >= 7,
  ),
  Achievement(
    id: 'rising_star',
    emoji: '⭐',
    title: 'Rising Star',
    description: 'Reach Explorer level',
    color: AppColors.yellow,
    isUnlockedFor: (p) => p.totalXp >= 500,
  ),
  Achievement(
    id: 'world_master',
    emoji: '👑',
    title: 'World Master',
    description: 'Reach the top level',
    color: AppColors.coral,
    isUnlockedFor: (p) => p.totalXp >= 22000,
  ),
  Achievement(
    id: 'sharp_shooter',
    emoji: '🎯',
    title: 'Sharp Shooter',
    description: 'Score 500+ in one game',
    color: AppColors.green,
    isUnlockedFor: (p) => p.bestScore >= 500,
  ),
  Achievement(
    id: 'dedicated_player',
    emoji: '🎮',
    title: 'Dedicated Player',
    description: 'Complete 10 games',
    color: AppColors.oceanBlueDeep,
    isUnlockedFor: (p) => p.gamesPlayed >= 10,
  ),
];
