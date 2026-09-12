import 'package:flutter/material.dart';

/// TerraScope brand palette.
///
/// Premium, competitive, minimal — not an educational/childish palette.
/// Indigo carries brand/premium moments, emerald carries progress/success
/// (XP, streaks, discovery), amber carries urgency (timers, combos).
abstract class AppColors {
  AppColors._();

  static const Color indigo = Color(0xFF6C5CE7);
  static const Color indigoBright = Color(0xFF8B7CF6);
  static const Color emerald = Color(0xFF00E5A0);
  static const Color emeraldDim = Color(0xFF00B382);
  static const Color amber = Color(0xFFFFB020);
  static const Color coral = Color(0xFFFF5470);

  // Dark theme surfaces (default TerraScope look).
  static const Color darkBackground = Color(0xFF0A0D16);
  static const Color darkSurface = Color(0xFF141926);
  static const Color darkSurfaceRaised = Color(0xFF1C2233);
  static const Color darkBorder = Color(0xFF2A3145);
  static const Color darkTextPrimary = Color(0xFFF4F6FB);
  static const Color darkTextSecondary = Color(0xFF9AA3B8);

  // Light theme surfaces.
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE3E6F0);
  static const Color lightTextPrimary = Color(0xFF13152A);
  static const Color lightTextSecondary = Color(0xFF5C6178);

  /// Continent accent colors, used consistently across map, badges, and
  /// continent-challenge cards so a continent is always recognizable.
  static const Color continentAfrica = Color(0xFFFFB020);
  static const Color continentAsia = Color(0xFFFF5470);
  static const Color continentEurope = Color(0xFF6C5CE7);
  static const Color continentNorthAmerica = Color(0xFF00E5A0);
  static const Color continentSouthAmerica = Color(0xFF2FD5FF);
  static const Color continentOceania = Color(0xFFFF8BD1);
}
