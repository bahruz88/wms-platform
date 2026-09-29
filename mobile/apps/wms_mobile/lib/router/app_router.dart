import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../menu/menu_routes.dart';
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
/// **Menyu** is the home: the tiles of everything this person may do. It is what
/// makes the app legible to someone who is not an administrator — the keeper's
/// menu, the branch's menu and the buyer's menu are the same screen showing
/// different tiles, because each tile is gated on the permission behind it.
///
/// The bar itself carries only what someone returns to over and over: the menu,
/// the queue of documents waiting on them, the stock they look things up in, and
/// their alerts. Everything else — writing off stock, entering a count, the
/// branch's daily sales, the buyer's requisitions — is a tile, reached and then
/// finished with. The profile is behind the person's own name on the menu: an
/// account screen is not work and does not earn a permanent tab.
final goRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final guard = AuthGuard(
    repository: repository,
    homePath: MenuRoutes.menuPath,
  );
  ref.onDispose(guard.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: MenuRoutes.menuPath,
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
          StatefulShellBranch(routes: menuRoutes()),
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
    // Loading `/identity/me` is what puts the effective permissions on the
    // session: the access token carries roles, not permissions. Watching it here
    // means they arrive once, as soon as anything is on screen. Before this, the
    // only screen that asked was the profile — so until someone opened it every
    // permission read as denied: the task list came back empty and the branch
    // tab never appeared.
    ref.watch(currentUserProvider);

    final tabs = <_Tab>[
      _Tab(
        branch: 0,
        label: l10n.navMenu,
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view,
      ),
      _Tab(
        branch: 1,
        label: l10n.navTasks,
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist,
      ),
      _Tab(
        branch: 3,
        label: l10n.navStock,
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
      ),
      _Tab(
        branch: 4,
        label: l10n.navAlerts,
        icon: Icons.notifications_outlined,
        selectedIcon: Icons.notifications,
        badgeCount: unread,
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
