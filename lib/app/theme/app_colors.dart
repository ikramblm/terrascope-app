import 'package:flutter/material.dart';

/// TerraScope brand palette — v3 (dark-first neon, a premium mobile game
/// at night, not a dashboard in daylight).
///
/// Dark is now the primary, fully-designed theme: a deep slate-navy
/// background with a handful of confident, high-saturation colors doing
/// the work, each with one job — never all seven competing on screen at
/// once. Ocean blue is the brand/navigation color; green means
/// correct/success; orange/yellow mean reward and urgency; coral means
/// wrong/warning; purple marks special modes and achievements; sky blue
/// is ocean blue's lighter sibling for secondary accents and geography
/// motifs. `ctaCyan`/`ctaViolet` are the primary-CTA gradient pair;
/// `comboFlame` is the hot end of the combo/timer ramp.
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

  /// Primary-CTA gradient pair (electric cyan → violet) — the
  /// "juiciest" color in the app, reserved for the single most important
  /// action on a screen (Play Again, Start, the quick-play FAB).
  static const Color ctaCyan = Color(0xFF22D3EE);
  static const Color ctaViolet = Color(0xFFA855F7);

  /// Hot end of the combo badge / segmented timer ramp — `coral` is the
  /// general wrong/warning color; `comboFlame` is specifically for
  /// "streak/time running out" urgency, a shade more red.
  static const Color comboFlame = Color(0xFFEF4444);

  /// Success/laser-emerald — a cooler, more saturated green than
  /// `green`, reserved for victory-moment surfaces (the results banner)
  /// rather than everyday correct-answer feedback, which stays `green`.
  static const Color successEmerald = Color(0xFF10E19A);

  // Light theme surfaces (kept for a possible future toggle; unreachable
  // today — see AppTheme, which forces dark).
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE9ECF5);
  static const Color lightTextPrimary = Color(0xFF1A1D29);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightShadow = Color(0xFF1B2559);

  // Dark theme surfaces — the primary look. A deep slate-navy base,
  // glass-like raised surfaces with a translucent neon-cyan hairline
  // border instead of a shadow (a shadow barely reads against a
  // near-black background; a lit border does).
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1A2338);
  static const Color darkSurfaceRaised = Color(0xFF212C47);

  /// Neon-cyan hairline, alpha already baked in (24%) — every border in
  /// the dark theme is this one token, so "glowing border" stays one
  /// consistent hue app-wide rather than a different tint per widget.
  static const Color darkBorder = Color(0x3D38BDF8);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Locked/unavailable-content fill — near-black, distinct from
  /// `darkSurface` so a locked card reads as "off" even next to a
  /// regular glass card.
  static const Color lockedObsidian = Color(0xFF111827);

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
