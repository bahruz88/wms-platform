import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:feature_procurement/feature_procurement.dart';
import 'package:feature_reporting/feature_reporting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'admin_screen.dart';
import 'callback_screen.dart';

/// NavigationRail shell of the web app: Dashboard, Satınalma, Anbar,
/// İstehlak (ADR-012), Master Data, Hesabatlar, Admin, Bildirişlər.
final goRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final guard = AuthGuard(
    repository: repository,
    homePath: ReportingRoutes.dashboardPath,
    // The OIDC redirect lands here before a session exists.
    publicPaths: const {CallbackRoutes.path},
  );
  ref.onDispose(guard.dispose);

  final router = GoRouter(
    initialLocation: ReportingRoutes.dashboardPath,
    redirect: guard.redirect,
    refreshListenable: guard,
    routes: [
      ...identityRoutes(),
      ...callbackRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _WebShell(navigationShell: navigationShell),
        branches: [
          // 0 Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: ReportingRoutes.dashboardName,
                path: ReportingRoutes.dashboardPath,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1 Satınalma
          StatefulShellBranch(routes: procurementRoutes()),
          // 2 Anbar
          StatefulShellBranch(
            routes: [...inventoryStockRoutes(), ...inventoryDocumentRoutes()],
          ),
          // 3 İstehlak (recipes, sales imports, runs, variance)
          StatefulShellBranch(routes: consumptionManagerRoutes()),
          // 4 Master Data
          StatefulShellBranch(routes: masterDataRoutes()),
          // 5 Hesabatlar
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: ReportingRoutes.reportsName,
                path: ReportingRoutes.reportsPath,
                builder: (context, state) => const ReportListScreen(),
              ),
            ],
          ),
          // 6 Admin (users / roles / settings)
          StatefulShellBranch(routes: adminRoutes()),
          // 7 Bildirişlər
          StatefulShellBranch(routes: notificationsRoutes()),
          // 8 Profil (reachable from the rail footer)
          StatefulShellBranch(routes: identityShellRoutes()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: WmsEmptyState(
        reason: 'Səhifə tapılmadı: ${state.uri}',
        nextStep: 'Sol menyudan bölmə seçin.',
        icon: Icons.error_outline,
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

class _WebShell extends ConsumerWidget {
  const _WebShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final session = ref.watch(sessionProvider);
    final unread = ref.watch(unreadBadgeProvider);

    return WmsAdaptiveScaffold(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      railLeading: Padding(
        padding: const EdgeInsets.symmetric(vertical: WmsSpacing.space4),
        child: Icon(Icons.inventory_2_outlined, color: c.accent),
      ),
      railTrailing: session == null
          ? null
          : Tooltip(
              message: session.displayName,
              child: WmsIconButton(
                icon: Icons.person_outline,
                label: l10n.navProfile,
                onPressed: () => navigationShell.goBranch(8),
              ),
            ),
      destinations: [
        WmsDestination(
          label: l10n.navDashboard,
          icon: Icons.space_dashboard_outlined,
        ),
        WmsDestination(
          label: l10n.navProcurement,
          icon: Icons.shopping_cart_outlined,
        ),
        WmsDestination(
          label: l10n.navWarehouse,
          icon: Icons.inventory_2_outlined,
        ),
        WmsDestination(
          label: l10n.navConsumption,
          icon: Icons.restaurant_outlined,
        ),
        WmsDestination(
          label: l10n.navMasterData,
          icon: Icons.category_outlined,
        ),
        WmsDestination(label: l10n.navReports, icon: Icons.bar_chart_outlined),
        WmsDestination(
          label: l10n.navAdmin,
          icon: Icons.admin_panel_settings_outlined,
        ),
        WmsDestination(
          label: l10n.navNotifications,
          icon: Icons.notifications_outlined,
          badgeCount: unread,
        ),
        WmsDestination(label: l10n.navProfile, icon: Icons.person_outline),
      ],
      body: navigationShell,
    );
  }
}
