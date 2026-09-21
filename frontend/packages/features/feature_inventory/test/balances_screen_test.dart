import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_inventory_repository.dart';

final _balance = BalanceDto(
  productId: 1,
  locationId: 2,
  productSku: 'CHS-0042',
  productName: 'Chicken Strips',
  locationCode: 'FOOD-WH',
  baseUomCode: 'KG',
  qtyOnHand: Quantity.parse('45'),
  qtyReserved: Quantity.parse('5.5'),
);

Widget host({
  required List<BalanceDto> balances,
  Set<String> permissions = const {},
}) => ProviderScope(
  overrides: [
    inventoryRepositoryProvider.overrideWithValue(
      FakeInventoryRepository(balanceRows: balances),
    ),
    locationListProvider.overrideWith((ref) async => const <LocationDto>[]),
    sessionProvider.overrideWithValue(
      Session(
        accessToken: 'token',
        userId: 'u1',
        username: 'keeper',
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
    home: const BalancesScreen(),
  ),
);

void main() {
  testWidgets('shows available = on hand − reserved, read only', (
    tester,
  ) async {
    await tester.pumpWidget(host(balances: [_balance]));
    await tester.pumpAndSettle();

    expect(find.text('CHS-0042'), findsOneWidget);
    expect(find.text('45,000'), findsOneWidget);
    expect(find.text('5,500'), findsOneWidget);
    expect(find.text('39,500'), findsOneWidget);
    // Balance is a projection: no editable quantity field on this screen.
    expect(find.byType(WmsQtyUomInput), findsNothing);
  });

  testWidgets('value column is hidden without the cost permission', (
    tester,
  ) async {
    await tester.pumpWidget(host(balances: [_balance]));
    await tester.pumpAndSettle();
    expect(find.text('Dəyər'), findsNothing);

    await tester.pumpWidget(
      host(
        balances: [
          _balance.copyWith(totalValue: Money.parse('562.5', currency: 'AZN')),
        ],
        permissions: const {Permissions.productViewCost},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dəyər'), findsOneWidget);
    expect(find.text('562,50 AZN'), findsOneWidget);
  });

  testWidgets('empty state names the reason and the next step', (tester) async {
    await tester.pumpWidget(host(balances: const []));
    await tester.pumpAndSettle();
    expect(find.text('Bu lokasiyada qalıq yoxdur.'), findsOneWidget);
    expect(find.text('Qəbul sənədi yaradın.'), findsOneWidget);
  });
}
