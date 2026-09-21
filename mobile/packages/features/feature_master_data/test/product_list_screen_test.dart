import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_master_data_repository.dart';

final _productWithoutCost = ProductDto(
  id: 1,
  sku: 'CHS-0042',
  name: 'Chicken Strips',
  categoryId: 1,
  baseUomId: 1,
  baseUomCode: 'KG',
  vatRate: Decimal.parse('18'),
  minStock: Quantity.parse('10'),
);

final _productWithCost = _productWithoutCost.copyWith(
  avgUnitCost: Money.parse('12.5'),
);

Widget host({required ProductDto product, required Set<String> permissions}) =>
    ProviderScope(
      overrides: [
        masterDataRepositoryProvider.overrideWithValue(
          FakeMasterDataRepository(allProducts: [product]),
        ),
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
        home: const ProductListScreen(),
      ),
    );

void main() {
  testWidgets('cost column is absent without master.product.view_cost', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(product: _productWithoutCost, permissions: const {}),
    );
    await tester.pumpAndSettle();

    expect(find.text('CHS-0042'), findsOneWidget);
    expect(find.text('Orta maya'), findsNothing);
    expect(find.textContaining('12,50'), findsNothing);
    expect(find.textContaining('***'), findsNothing);
  });

  testWidgets('cost column appears with the permission', (tester) async {
    await tester.pumpWidget(
      host(
        product: _productWithCost,
        permissions: const {Permissions.productViewCost},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orta maya'), findsOneWidget);
    expect(find.text('12,50'), findsOneWidget);
  });

  testWidgets('quantities are formatted with comma decimals', (tester) async {
    await tester.pumpWidget(
      host(product: _productWithoutCost, permissions: const {}),
    );
    await tester.pumpAndSettle();
    expect(find.text('10,000'), findsOneWidget);
  });
}
