import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds TerraScope's Material 3 [TextTheme].
///
/// Headings use Sora (geometric, confident — reads as a game, not a
/// classroom app); body copy uses Inter for readability at small sizes.
TextTheme buildAppTextTheme(Color primaryTextColor, Color secondaryTextColor) {
  final base = TextTheme(
    displayLarge: GoogleFonts.sora(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: primaryTextColor,
    ),
    displayMedium: GoogleFonts.sora(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: primaryTextColor,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: primaryTextColor,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: primaryTextColor,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: primaryTextColor,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primaryTextColor,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: secondaryTextColor,
      letterSpacing: 0.4,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: secondaryTextColor,
      letterSpacing: 0.4,
    ),
  );
  return base;
}

/// Convenience accessors kept off [TextTheme] itself (e.g. numeric/score
/// displays that want tabular figures) — used by widgets like score
/// counters and the country-found tally.
TextStyle scoreDisplayStyle(Color color) => GoogleFonts.sora(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
