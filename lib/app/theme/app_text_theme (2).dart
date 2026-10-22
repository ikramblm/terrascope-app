import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds TerraScope's Material 3 [TextTheme].
///
/// Fredoka everywhere — a rounded, chunky, unmistakably "game" font,
/// used for headings and body copy alike rather than pairing it with a
/// neutral sans, so the whole app reads as one consistent playful
/// identity rather than a game title over a spreadsheet's body text.
TextTheme buildAppTextTheme(Color primaryTextColor, Color secondaryTextColor) {
  final base = TextTheme(
    displayLarge: GoogleFonts.fredoka(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: primaryTextColor,
    ),
    displayMedium: GoogleFonts.fredoka(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: primaryTextColor,
    ),
    headlineLarge: GoogleFonts.fredoka(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    headlineMedium: GoogleFonts.fredoka(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    titleLarge: GoogleFonts.fredoka(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    titleMedium: GoogleFonts.fredoka(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    titleSmall: GoogleFonts.fredoka(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    bodyLarge: GoogleFonts.fredoka(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primaryTextColor,
    ),
    bodyMedium: GoogleFonts.fredoka(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
    ),
    bodySmall: GoogleFonts.fredoka(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
    ),
    labelLarge: GoogleFonts.fredoka(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
    ),
    labelMedium: GoogleFonts.fredoka(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: secondaryTextColor,
      letterSpacing: 0.4,
    ),
    labelSmall: GoogleFonts.fredoka(
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
TextStyle scoreDisplayStyle(Color color) => GoogleFonts.fredoka(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  color: color,
  fontFeatures: const [FontFeature.tabularFigures()],
);
