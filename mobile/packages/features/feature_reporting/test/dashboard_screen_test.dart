import 'package:feature_reporting/feature_reporting.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

// KPIs, not named counters: the server sends whatever this caller is entitled to, and a cost
// figure is left out entirely rather than nulled (spec §16).
final _summary = DashboardSummaryDto(
  generatedAt: DateTime(2026, 9, 20, 9),
  kpis: const [
    KpiDto(key: 'stockValueTotal', label: 'Anbar dəyəri', value: '128450.75', unit: 'AZN', isCost: true),
    KpiDto(key: 'expiringBatches', label: 'Vaxtı yaxınlaşan partiyalar', value: '12'),
    KpiDto(key: 'expiredBatches', label: 'Vaxtı keçmiş partiyalar', value: '3'),
    KpiDto(key: 'lowStockProducts', label: 'Aşağı qalıq', value: '7'),
    KpiDto(key: 'pendingApprovals', label: 'Təsdiq gözləyənlər', value: '4'),
    KpiDto(key: 'openPurchaseOrders', label: 'Açıq sifarişlər', value: '9'),
    KpiDto(key: 'inTransitIssues', label: 'Yolda olan sənədlər', value: '2'),
  ],
  // The server composes the alert text, because only it knows the tenant's thresholds.
  alerts: const [
    DashboardAlertDto(
      type: 'BATCH_EXPIRED',
      severity: 'CRITICAL',
      title: '3 partiyanın vaxtı keçib',
      count: 3,
    ),
  ],
);

Widget host({
  required DashboardSummaryDto summary,
  Set<String> permissions = const {},
}) => ProviderScope(
  overrides: [
    dashboardProvider.overrideWith((ref) async => summary),
    sessionProvider.overrideWithValue(
      Session(
        accessToken: 'token',
        userId: 'u1',
        username: 'manager',
        tenantId: 1,
        permissions: permissions,
      ),
    ),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: const DashboardScreen(),
  ),
);

void main() {
  testWidgets('renders the placeholder KPI cards', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(summary: _summary));
    await tester.pumpAndSettle();

    expect(find.text('Vaxtı yaxınlaşan partiyalar'), findsOneWidget);
    expect(find.text('Aşağı qalıq'), findsOneWidget);
    expect(find.text('Təsdiq gözləyənlər'), findsOneWidget);
    expect(find.text('3 partiyanın vaxtı keçib'), findsOneWidget);
  });

  testWidgets('stock value card is not rendered without view_cost', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(summary: _summary));
    await tester.pumpAndSettle();
    expect(find.text('Anbar dəyəri'), findsNothing);

    await tester.pumpWidget(
      host(summary: _summary, permissions: const {Permissions.productViewCost}),
    );
    await tester.pumpAndSettle();
    expect(find.text('Anbar dəyəri'), findsOneWidget);
    expect(find.text('128 450,75'), findsOneWidget);
  });
}
