import 'package:feature_reporting/feature_reporting.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

final _summary = DashboardSummaryDto(
  asOf: DateTime(2026, 9, 20, 9),
  stockValue: Money.parse('128450.75', currency: 'AZN'),
  expiringBatches: 12,
  expiredBatches: 3,
  lowStockProducts: 7,
  pendingApprovals: 4,
  openPurchaseOrders: 9,
  inTransitIssues: 2,
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
    expect(find.text('3 vaxtı keçib'), findsOneWidget);
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
