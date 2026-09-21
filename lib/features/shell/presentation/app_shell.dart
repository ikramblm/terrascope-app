import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../games/data/quick_play.dart';

/// Bottom-navigation shell shared by the four tab destinations, plus a
/// floating "Play" button docked in a notch between them — the single
/// most important action in the app gets its own unmissable shape and
/// color instead of competing as a fifth equal tab.
///
/// Wraps a [StatefulShellRoute] branch so each tab keeps its own
/// navigation stack and scroll position when switching tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Not wrapped in AppBackground here: each tab owns its own Scaffold
      // (Home, Explore, Lists, Profile), and a nested Scaffold paints an
      // opaque `scaffoldBackgroundColor` that would hide anything behind
      // it — the globe-grid texture is applied inside each of those
      // instead, where it's actually visible.
      body: navigationShell,
      floatingActionButton: _PlayFab(onTap: () => launchQuickPlay(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _PlayFab extends StatelessWidget {
  const _PlayFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ctaCyan, AppColors.ctaViolet],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ctaCyan.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.explore_rounded, label: 'Explore'),
    (icon: Icons.menu_book_rounded, label: 'Lists'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      height: 68,
      padding: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      elevation: 0,
      child: Row(
        children: [
          _navItem(context, index: 0),
          _navItem(context, index: 1),
          const Spacer(),
          _navItem(context, index: 2),
          _navItem(context, index: 3),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, {required int index}) {
    final theme = Theme.of(context);
    final item = _items[index];
    final selected = index == currentIndex;
    // One consistent accent color for the whole nav area — selection is
    // shown by the rounded-square container filling in, not by a
    // different color per item.
    final color = selected
        ? AppColors.oceanBlue
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.oceanBlue.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
