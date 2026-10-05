import 'package:flutter/material.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/config/app_route.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/layout/adaptive_layout.dart';
import 'package:live_score/src/core/widgets/app_search_bar.dart';

import '../../../../core/l10n/app_l10n.dart';

class SoccerLayout extends StatelessWidget {
  const SoccerLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final l10n = context.l10n;
    final useRailNavigation = !context.isCompactWindow;

    final int currentIndex = switch (location) {
      Routes.soccer => 0,
      Routes.fixtures => 1,
      Routes.standings => 2,
      Routes.predictor => 3,
      Routes.favorites => 4,
      _ => 0,
    };

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 56,
        elevation: 0,
        backgroundColor: context.colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {},
        ),
        title: SizedBox(
          height: 40,
          child: AppSearchBar(
            hintText: 'Tìm kiếm...',
            padding: EdgeInsets.zero,
            onChanged: (val) {},
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Row(
        children: [
          if (useRailNavigation) ...[
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onTap(context, index),
              extended: context.isExpandedWindow,
              backgroundColor: Colors.transparent,
              labelType:
                  context.isExpandedWindow
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: Text(l10n.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.sports_soccer_outlined),
                  selectedIcon: const Icon(Icons.sports_soccer),
                  label: Text(l10n.fixtures),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bar_chart_rounded),
                  selectedIcon: const Icon(Icons.bar_chart_rounded),
                  label: Text(l10n.standings),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.sports_esports_outlined),
                  selectedIcon: const Icon(Icons.sports_esports),
                  label: const Text('Dự đoán'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.star_border_rounded),
                  selectedIcon: const Icon(Icons.star_rounded),
                  label: const Text('Favorites'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: AdaptiveContentArea(child: child)),
        ],
      ),
    ),
      bottomNavigationBar:
          useRailNavigation
              ? null
              : _FloatingBottomNav(
                currentIndex: currentIndex,
                onTap: (index) => _onTap(context, index),
              ),
    );
  }

  void _onTap(BuildContext context, int index) => switch (index) {
    0 => context.go(Routes.soccer),
    1 => context.go(Routes.fixtures),
    2 => context.go(Routes.standings),
    3 => context.go(Routes.predictor),
    4 => context.go(Routes.favorites),
    _ => null,
  };
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          bottom: AppSpacing.l,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: context.colorsExt.dividerSubtle,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - AppSpacing.l * 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: l10n.home,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.sports_soccer_outlined,
                    activeIcon: Icons.sports_soccer,
                    label: l10n.fixtures,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    activeIcon: Icons.bar_chart_rounded,
                    label: l10n.standings,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.sports_esports_outlined,
                    activeIcon: Icons.sports_esports,
                    label: 'Fantasy',
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: Icons.star_border_rounded,
                    activeIcon: Icons.star_rounded,
                    label: 'Yêu thích',
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                  ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? context.colors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color:
                  isSelected
                      ? context.colors.primary
                      : context.colorsExt.textMuted,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

