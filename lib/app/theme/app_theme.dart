import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';

/// TerraScope's Material 3 theme definitions — light is the primary,
/// fully-designed experience (a bright, colorful mobile game, not a
/// dashboard, and not stark white either — see `AppBackground`'s
/// blue-to-green gradient backdrop); dark is kept defined for a
/// possible future toggle but isn't reachable today — see
/// [TerraScopeApp], which forces `ThemeMode.light`.
abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    // Matches the top of AppBackground's gradient, so the sliver of
    // scaffold/app-bar it doesn't cover (the app bar strip) blends into
    // the gradient below it rather than seaming against a mismatched
    // solid color.
    background: AppColors.bgGradientTop,
    surface: AppColors.lightSurface,
    surfaceRaised: AppColors.lightSurfaceRaised,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    shadowColor: AppColors.lightShadow,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceRaised: AppColors.darkSurfaceRaised,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    shadowColor: Colors.black,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceRaised,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color shadowColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.ctaCyan : AppColors.oceanBlue,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      secondary: AppColors.green,
      onSecondary: Colors.white,
      tertiary: AppColors.orange,
      onTertiary: Colors.white,
      error: isDark ? AppColors.comboFlame : AppColors.coral,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceRaised,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border.withValues(alpha: border.a * 0.6),
      shadow: shadowColor,
      scrim: Colors.black,
      inverseSurface: textPrimary,
      onInverseSurface: background,
      inversePrimary: AppColors.skyBlue,
    );

    final textTheme = buildAppTextTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: textTheme.bodyMedium?.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      // The "glass card" look in dark mode: a translucent fill plus a lit
      // neon hairline instead of a shadow. In light mode, a real chunky
      // drop shadow instead — the "3D" look: every card sits visibly
      // raised off the background rather than flat against it.
      cardTheme: CardThemeData(
        color: isDark ? surfaceRaised.withValues(alpha: 0.65) : surfaceRaised,
        elevation: isDark ? 0 : 10,
        shadowColor: shadowColor.withValues(alpha: isDark ? 0 : 0.22),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isDark ? BorderSide(color: border, width: 1) : BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.oceanBlue.withValues(
          alpha: isDark ? 0.35 : 0.12,
        ),
        elevation: isDark ? 0 : 12,
        shadowColor: shadowColor.withValues(alpha: isDark ? 0 : 0.18),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.oceanBlue : textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.oceanBlue : textSecondary,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.ctaCyan : AppColors.oceanBlue,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          disabledBackgroundColor: border,
          disabledForegroundColor: textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          // A chunky, visibly-raised button in light mode — part of the
          // app-wide 3D pass; dark mode keeps the flat glass look since a
          // drop shadow doesn't read against near-black.
          elevation: isDark ? 0 : 8,
          shadowColor: isDark
              ? Colors.transparent
              : AppColors.oceanBlueDeep.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green,
        linearTrackColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceRaised,
        side: BorderSide(color: border),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
