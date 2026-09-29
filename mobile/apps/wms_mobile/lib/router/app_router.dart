import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../tasks/tasks_routes.dart';

/// Root navigator of the app. The barcode scanner pushes its full screen
/// camera route through this key, because `BarcodeScanner.scan()` has no
/// `BuildContext`.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'wms-mobile-root',
);

/// Bottom-navigation shell.
///
/// Four destinations, as the screen designs lay them out: **Tapşırıq**,
/// **Əməliyyat**, **Qalıq**, **Bildiriş**. The app opens on the task list, not
/// on the balances: a balance table answers "how much is there", and the
/// question someone opens this app to ask is "what should I do next".
///
/// Two things sit outside those four on purpose. The profile is reached from the
/// person's own name in the task header — an account screen is not work, and it
/// does not earn a permanent tab. The branch workplace (ADR-012 daily sales) is
/// a fifth destination shown only to an account that can actually use it: the
/// designs cover the warehouse keeper, and for a keeper the bar is exactly the
/// four. A branch user would otherwise have no way in at all.
final goRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final guard = AuthGuard(
    repository: repository,
    homePath: TasksRoutes.tasksPath,
  );
  ref.onDispose(guard.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: TasksRoutes.tasksPath,
    redirect: guard.redirect,
    refreshListenable: guard,
    routes: [
      ...identityRoutes(),
      // Outside the shell on purpose: a document someone is working covers the
      // navigation bar rather than sitting inside it.
      ...inventoryFocusedRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _MobileShell(navigationShell: navigationShell),
        // Every branch is always mounted, so the router never has to be rebuilt
        // when permissions arrive from `/identity/me`; which of them the bar
        // offers is decided below.
        branches: [
          StatefulShellBranch(routes: tasksRoutes()),
          StatefulShellBranch(routes: inventoryDocumentRoutes()),
          StatefulShellBranch(routes: inventoryStockRoutes()),
          StatefulShellBranch(routes: notificationsRoutes()),
          StatefulShellBranch(routes: consumptionBranchRoutes()),
          StatefulShellBranch(routes: identityShellRoutes()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: WmsEmptyState(
        reason: 'Səhifə tapılmadı: ${state.uri}',
        nextStep: 'Aşağıdakı naviqasiyadan bölmə seçin.',
        icon: Icons.error_outline,
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

/// One entry of the bottom bar, bound to the shell branch it opens.
@immutable
class _Tab {
  const _Tab({
    required this.branch,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });

  final int branch;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
}

class _MobileShell extends ConsumerWidget {
  const _MobileShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadBadgeProvider);
    final permissions =
        ref.watch(sessionProvider)?.permissions ?? const <String>{};

    final tabs = <_Tab>[
      _Tab(
        branch: 0,
        label: l10n.navTasks,
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist,
      ),
      _Tab(
        branch: 1,
        label: l10n.navOperations,
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
      ),
      _Tab(
        branch: 2,
        label: l10n.navStock,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
      ),
      _Tab(
        branch: 3,
        label: l10n.navAlerts,
        icon: Icons.notifications_outlined,
        selectedIcon: Icons.notifications,
        badgeCount: unread,
      ),
      if (permissions.contains(Permissions.salesImport))
        _Tab(
          branch: 4,
          label: l10n.navBranch,
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
        ),
    ];

    // The profile is not a tab; while it is open nothing in the bar is selected,
    // which is what `NavigationBar` shows for an index outside its range.
    final selected = tabs.indexWhere(
      (tab) => tab.branch == navigationShell.currentIndex,
    );

    return WmsAdaptiveScaffold(
      selectedIndex: selected < 0 ? tabs.length : selected,
      onDestinationSelected: (index) => navigationShell.goBranch(
        tabs[index].branch,
        initialLocation: tabs[index].branch == navigationShell.currentIndex,
      ),
      destinations: [
        for (final tab in tabs)
          WmsDestination(
            label: tab.label,
            icon: tab.icon,
            selectedIcon: tab.selectedIcon,
            badgeCount: tab.badgeCount,
          ),
      ],
      body: navigationShell,
    );
  }
}
