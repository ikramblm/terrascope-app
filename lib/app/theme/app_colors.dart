import 'package:flutter/material.dart';

/// TerraScope brand palette.
///
/// Vivid and playful on purpose — this is a game, not an analytics
/// dashboard. Several saturated hues are used together rather than one
/// muted "brand color" plus grayscale: blue carries brand/navigation,
/// green carries progress/success (XP, streaks, correct answers), orange
/// carries urgency/energy (timers, combos), and pink/purple/cyan add
/// variety across categories, continents, and difficulty tiers so no two
/// sections of the app read as visually identical.
abstract class AppColors {
  AppColors._();

  static const Color indigo = Color(0xFF5B5BF7);
  static const Color indigoBright = Color(0xFF8C8CFF);
  static const Color emerald = Color(0xFF00E08A);
  static const Color emeraldDim = Color(0xFF00B876);
  static const Color amber = Color(0xFFFF9F1C);
  static const Color coral = Color(0xFFFF3D68);

  /// Extra accents for variety across category/difficulty/continent
  /// color-coding — deliberately not funneled through just primary/
  /// secondary/tertiary, so the app reads as colorful throughout, not
  /// just at a couple of "branded" touchpoints.
  static const Color skyBlue = Color(0xFF00C2FF);
  static const Color sunYellow = Color(0xFFFFD60A);
  static const Color grapePurple = Color(0xFFB44DFF);
  static const Color pink = Color(0xFFFF6EC7);

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
  static const Color continentAfrica = Color(0xFFFF9F1C);
  static const Color continentAsia = Color(0xFFFF3D68);
  static const Color continentEurope = Color(0xFF5B5BF7);
  static const Color continentNorthAmerica = Color(0xFF00E08A);
  static const Color continentSouthAmerica = Color(0xFF00C2FF);
  static const Color continentOceania = Color(0xFFFF6EC7);

  /// Difficulty color-coding, shared by every difficulty picker so Easy
  /// is always green, Medium always orange, Hard always red — a
  /// traffic-light convention players recognize instantly.
  static const Color difficultyEasy = Color(0xFF00E08A);
  static const Color difficultyMedium = Color(0xFFFF9F1C);
  static const Color difficultyHard = Color(0xFFFF3D68);
}
