import 'package:flutter/material.dart';

/// TerraScope's one logo asset — the exact same image used as the app
/// icon (favicon, Android launcher, iOS, desktop) everywhere it's
/// rendered in-app, instead of a separately hand-drawn Icon that only
/// resembles it. Every in-app "logo" (splash, Home's banner) should go
/// through this widget rather than embedding the asset path directly,
/// so there's exactly one place that ever changes if the logo does.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  static const assetPath = 'assets/branding/logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, width: size, height: size);
  }
}
