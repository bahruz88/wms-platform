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

/// Root navigator of the app. The barcode scanner pushes its full screen
/// camera route through this key, because `BarcodeScanner.scan()` has no
/// `BuildContext`.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'wms-mobile-root',
);

/// Bottom-navigation shell of the mobile app:
/// Anbar (balances + scan), Sənədlər, Filial (ADR-012 consumption),
/// Bildirişlər, Profil.
final goRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final guard = AuthGuard(
    repository: repository,
    homePath: InventoryRoutes.balancesPath,
  );
  ref.onDispose(guard.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: InventoryRoutes.balancesPath,
    redirect: guard.redirect,
    refreshListenable: guard,
    routes: [
      ...identityRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _MobileShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: inventoryStockRoutes()),
          StatefulShellBranch(routes: inventoryDocumentRoutes()),
          // Branch workplace: daily sales entry and yesterday's consumption.
          StatefulShellBranch(routes: consumptionBranchRoutes()),
          StatefulShellBranch(routes: notificationsRoutes()),
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

class _MobileShell extends ConsumerWidget {
  const _MobileShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadBadgeProvider);
    return WmsAdaptiveScaffold(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        WmsDestination(
          label: l10n.navWarehouse,
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
        ),
        WmsDestination(
          label: l10n.navDocuments,
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
        ),
        WmsDestination(
          label: l10n.navBranch,
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
        ),
        WmsDestination(
          label: l10n.navNotifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          badgeCount: unread,
        ),
        WmsDestination(
          label: l10n.navProfile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
      ],
      body: navigationShell,
    );
  }
}
