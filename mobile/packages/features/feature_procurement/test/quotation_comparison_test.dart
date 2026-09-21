import 'package:feature_procurement/feature_procurement.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

QuotationDto _quote({
  required int id,
  required String supplier,
  required String total,
}) => QuotationDto(
  id: id,
  supplierId: id,
  supplierName: supplier,
  quoteDate: DateTime(2026, 9, 10),
  currency: 'AZN',
  totalAmount: Money.parse(total, currency: 'AZN'),
  totalAmountBase: Money.parse(total, currency: 'AZN'),
);

final _quotes = [
  _quote(id: 1, supplier: 'Alfa MMC', total: '1200'),
  _quote(id: 2, supplier: 'Beta MMC', total: '980'),
];

Widget host({Set<String> permissions = const {Permissions.quotationSelect}}) =>
    ProviderScope(
      overrides: [
        quotationListProvider(7).overrideWith((ref) async => _quotes),
        sessionProvider.overrideWithValue(
          Session(
            accessToken: 'token',
            userId: 'u1',
            username: 'officer',
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
        home: const QuotationComparisonScreen(rfqId: 7),
      ),
    );

void main() {
  setUp(() {
    // The comparison grid is a desktop surface (web app).
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1600, 1200)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('marks the cheapest quotation', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Ən ucuz'), findsOneWidget);
    expect(find.text('Alfa MMC'), findsOneWidget);
    expect(find.text('Beta MMC'), findsOneWidget);
  });

  testWidgets('selecting a dearer quote demands a justification', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // Nothing selected yet: no note field, confirm disabled.
    expect(find.text('Seçim əsaslandırması'), findsNothing);
    var confirm = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Seç'),
    );
    expect(confirm.isDisabled, isTrue);

    await tester.tap(find.text('Alfa MMC'));
    await tester.pumpAndSettle();
    expect(find.text('Seçilib'), findsOneWidget);

    expect(find.text('Ən ucuz təklif seçilmədi'), findsOneWidget);
    expect(find.text('Seçim əsaslandırması'), findsOneWidget);
    confirm = tester.widget<WmsButton>(find.widgetWithText(WmsButton, 'Seç'));
    expect(confirm.isDisabled, isTrue, reason: 'note still empty');

    await tester.enterText(
      find.descendant(
        of: find.ancestor(
          of: find.text('Seçim əsaslandırması'),
          matching: find.byType(WmsTextField),
        ),
        matching: find.byType(TextField),
      ),
      'Çatdırılma müddəti 3 gün qısadır',
    );
    await tester.pumpAndSettle();
    confirm = tester.widget<WmsButton>(find.widgetWithText(WmsButton, 'Seç'));
    expect(confirm.isDisabled, isFalse);
  });

  testWidgets('choosing the cheapest needs no justification', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta MMC'));
    await tester.pumpAndSettle();
    expect(find.text('Seçim əsaslandırması'), findsNothing);
    final confirm = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Seç'),
    );
    expect(confirm.isDisabled, isFalse);
  });

  testWidgets('without proc.quotation.select the action stays disabled', (
    tester,
  ) async {
    await tester.pumpWidget(host(permissions: const {}));
    await tester.pumpAndSettle();
    final confirm = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Seç'),
    );
    expect(confirm.isDisabled, isTrue);
    expect(confirm.disabledReason, 'Bu əməliyyat üçün icazəniz yoxdur');
  });
}
