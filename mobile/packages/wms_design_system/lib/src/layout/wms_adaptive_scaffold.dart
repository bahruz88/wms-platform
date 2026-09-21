import 'package:flutter/material.dart';

import '../tokens/wms_breakpoints.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_typography.dart';

/// One destination of [WmsAdaptiveScaffold].
@immutable
class WmsDestination {
  const WmsDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  /// Unread counter (notifications); `null` or `0` hides the badge.
  final int? badgeCount;
}

/// Bottom navigation below `600px`, navigation rail above it (extended from
/// `1024px`), so the mobile app keeps one widget tree on phones and tablets.
class WmsAdaptiveScaffold extends StatelessWidget {
  const WmsAdaptiveScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    super.key,
  });

  final List<WmsDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final size = WmsBreakpoints.of(context);
    final c = WmsColors.of(context);
    if (size.isCompact) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: _Icon(destination: d, selected: false),
                  selectedIcon: _Icon(destination: d, selected: true),
                  label: d.label,
                  tooltip: d.label,
                ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: c.border)),
            ),
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              extended: size.isExpanded,
              minWidth: 72,
              minExtendedWidth: 220,
              labelType: size.isExpanded ? null : NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: _Icon(destination: d, selected: false),
                    selectedIcon: _Icon(destination: d, selected: true),
                    label: Text(d.label, style: WmsTypography.body),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.destination, required this.selected});

  final WmsDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final icon = Icon(
      selected
          ? (destination.selectedIcon ?? destination.icon)
          : destination.icon,
    );
    final count = destination.badgeCount ?? 0;
    if (count <= 0) return icon;
    return Badge.count(
      count: count,
      backgroundColor: c.danger,
      textColor: c.onDanger,
      child: icon,
    );
  }
}
