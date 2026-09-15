import 'package:flutter/material.dart';

/// TerraScope brand palette — v2 (premium mobile game, not a dashboard).
///
/// Light-first: a soft off-white base with a handful of confident,
/// saturated colors doing the work, each with one job — never all seven
/// competing on screen at once. Ocean blue is the brand/navigation
/// color; green means correct/success; orange/yellow mean reward and
/// urgency; coral means wrong/warning; purple marks special modes and
/// achievements; sky blue is ocean blue's lighter sibling for secondary
/// accents and geography motifs.
abstract class AppColors {
  AppColors._();

  static const Color oceanBlue = Color(0xFF2F6FED);
  static const Color oceanBlueDeep = Color(0xFF1B4FC4);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color green = Color(0xFF22C55E);
  static const Color greenDeep = Color(0xFF16A34A);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFFB923C);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color purple = Color(0xFF8B5CF6);

  // Light theme surfaces (the primary, fully-designed look).
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE9ECF5);
  static const Color lightTextPrimary = Color(0xFF1A1D29);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightShadow = Color(0xFF1B2559);

  // Dark theme surfaces (same language, inverted — secondary look).
  static const Color darkBackground = Color(0xFF0F1220);
  static const Color darkSurface = Color(0xFF171B2C);
  static const Color darkSurfaceRaised = Color(0xFF1F2438);
  static const Color darkBorder = Color(0xFF2C3350);
  static const Color darkTextPrimary = Color(0xFFF4F6FB);
  static const Color darkTextSecondary = Color(0xFFA1A8C3);

  /// Continent accent colors, used consistently across map and
  /// continent-challenge cards so a continent is always recognizable.
  static const Color continentAfrica = orange;
  static const Color continentAsia = coral;
  static const Color continentEurope = oceanBlue;
  static const Color continentNorthAmerica = green;
  static const Color continentSouthAmerica = skyBlue;
  static const Color continentOceania = purple;

  /// Difficulty color-coding, shared by every difficulty picker so Easy
  /// is always green, Medium always orange, Hard always coral — a
  /// traffic-light convention players recognize instantly.
  static const Color difficultyEasy = green;
  static const Color difficultyMedium = orange;
  static const Color difficultyHard = coral;

  /// The four Kahoot-style answer-slot colors, in fixed order — every
  /// multiple-choice question's options get these regardless of content,
  /// so shape+color become a second, instant way to tell options apart.
  static const List<Color> answerSlotColors = [oceanBlue, coral, yellow, green];
  static const List<IconData> answerSlotIcons = [
    Icons.change_history_rounded, // triangle
    Icons.diamond_rounded, // diamond
    Icons.circle_rounded, // circle
    Icons.square_rounded, // square
  ];
}
