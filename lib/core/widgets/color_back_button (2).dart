import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A colored, raised circular back button — every `AppBar` in the app
/// uses this instead of the default plain back arrow, part of the
/// app-wide 3D redesign. Hides itself when there's nothing to pop back
/// to, same as the default `BackButton` would.
class ColorBackButton extends StatelessWidget {
  const ColorBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Material(
        color: AppColors.oceanBlue,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: AppColors.oceanBlueDeep.withValues(alpha: 0.5),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
