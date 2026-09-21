import 'package:decimal/decimal.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'fake_inventory_repository.dart';

final _product = ProductDto(
  id: 1,
  sku: 'CHS-0042',
  name: 'Chicken Strips',
  categoryId: 2,
  baseUomId: 5,
  baseUomCode: 'KG',
  barcode: '4600000000000',
  vatRate: Decimal.zero,
);

const _uom = UomDto(
  id: 5,
  code: 'KG',
  name: 'Kiloqram',
  uomClass: UomClass.mass,
);

/// Scanner double: reports a camera and yields [code] once.
class FakeScanner implements BarcodeScanner {
  FakeScanner(this.code, {this.available = true});

  final String? code;
  final bool available;
  int scans = 0;

  @override
  bool get isAvailable => available;

  @override
  Future<String?> scan() async {
    scans++;
    return code;
  }
}

/// Only [productByBarcode] matters here; the rest is never called.
class FakeBarcodeMasterData implements MasterDataRepository {
  FakeBarcodeMasterData({this.known});

  /// Product the barcode resolves to; `null` means "not linked".
  final ProductDto? known;
  final List<String> lookups = [];

  @override
  Future<Result<ProductDto>> productByBarcode(String barcode) async {
    lookups.add(barcode);
    final found = known;
    if (found == null) {
      return Err<ProductDto>(
        NotFoundFailure(
          ProblemDetails.local(
            code: ProblemCodes.notFound,
            title: 'Barkod tapılmadı',
            status: 404,
          ),
        ),
      );
    }
    return Ok<ProductDto>(found);
  }

  @override
  Future<Result<Page<ProductDto>>> products({
    String? search,
    int? categoryId,
    ProductType? productType,
    PageRequest page = const PageRequest(),
  }) async => throw UnimplementedError();

  @override
  Future<Result<ProductDto>> product(int id) async =>
      throw UnimplementedError();

  @override
  Future<Result<Page<SupplierDto>>> suppliers({
    String? search,
    PageRequest page = const PageRequest(),
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<LocationDto>>> locations({
    LocationType? locationType,
    bool includeVirtual = false,
  }) async => throw UnimplementedError();

  @override
  Future<Result<List<UomDto>>> uoms() async => throw UnimplementedError();

  @override
  Future<Result<List<ReasonCodeDto>>> reasonCodes({ReasonGroup? group}) async =>
      throw UnimplementedError();
}

Widget host({
  required Widget child,
  required BarcodeScanner scanner,
  required MasterDataRepository masterData,
}) => ProviderScope(
  overrides: [
    barcodeScannerProvider.overrideWithValue(scanner),
    masterDataRepositoryProvider.overrideWithValue(masterData),
    inventoryRepositoryProvider.overrideWithValue(FakeInventoryRepository()),
    locationListProvider.overrideWith((ref) async => const <LocationDto>[]),
    supplierListProvider.overrideWith(
      (ref) async => const Page<SupplierDto>(
        items: <SupplierDto>[],
        page: 1,
        size: 50,
        total: 0,
      ),
    ),
    uomListProvider.overrideWith((ref) async => const [_uom]),
    productListProvider.overrideWith(() => _StaticProductList([_product])),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: child,
  ),
);

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1400, 2000)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  group('barcode entry screen', () {
    testWidgets('without a camera only manual entry is offered', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const BarcodeEntryScreen(),
          scanner: FakeScanner(null, available: false),
          masterData: FakeBarcodeMasterData(known: _product),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Bu cihazda kamera ilə skan mövcud deyil'),
        findsOneWidget,
      );
      expect(find.text('Barkodu əl ilə daxil edin.'), findsOneWidget);
      expect(find.widgetWithText(WmsButton, 'Barkod skan et'), findsNothing);
      expect(find.widgetWithText(WmsButton, 'Axtar'), findsOneWidget);
    });

    testWidgets('a scanned code is resolved to a product', (tester) async {
      final scanner = FakeScanner('4600000000000');
      final masterData = FakeBarcodeMasterData(known: _product);
      var resolved = 0;

      await tester.pumpWidget(
        host(
          child: BarcodeEntryScreen(onResolved: (id) => resolved = id),
          scanner: scanner,
          masterData: masterData,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(WmsButton, 'Barkod skan et'));
      await tester.pumpAndSettle();

      expect(scanner.scans, 1);
      expect(masterData.lookups, ['4600000000000']);
      expect(resolved, 1);
    });

    testWidgets('an unknown barcode shows the server problem', (tester) async {
      await tester.pumpWidget(
        host(
          child: const BarcodeEntryScreen(),
          scanner: FakeScanner('0000000000000'),
          masterData: FakeBarcodeMasterData(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(WmsButton, 'Barkod skan et'));
      await tester.pumpAndSettle();

      expect(find.text('Barkod tapılmadı'), findsOneWidget);
      expect(find.textContaining(ProblemCodes.notFound), findsOneWidget);
    });
  });

  group('goods receipt line scanning', () {
    testWidgets('the scan button fills the product of the line', (
      tester,
    ) async {
      final scanner = FakeScanner('4600000000000');
      final masterData = FakeBarcodeMasterData(known: _product);

      await tester.pumpWidget(
        host(
          child: const GoodsReceiptFormScreen(),
          scanner: scanner,
          masterData: masterData,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(WmsButton, 'Barkod skan et'));
      await tester.pumpAndSettle();

      expect(scanner.scans, 1);
      expect(masterData.lookups, ['4600000000000']);
      // The product select now shows the scanned product.
      expect(find.text('CHS-0042 · Chicken Strips'), findsOneWidget);
    });

    testWidgets('an unknown barcode points at the SKU search instead', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          child: const GoodsReceiptFormScreen(),
          scanner: FakeScanner('1111111111111'),
          masterData: FakeBarcodeMasterData(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(WmsButton, 'Barkod skan et'));
      await tester.pumpAndSettle();

      expect(
        find.text('Bu barkod məhsula bağlı deyil: 1111111111111'),
        findsOneWidget,
      );
      expect(find.text('Məhsulu SKU ilə siyahıdan seçin.'), findsOneWidget);
    });

    testWidgets('no camera means no scan button on the line', (tester) async {
      await tester.pumpWidget(
        host(
          child: const GoodsReceiptFormScreen(),
          scanner: FakeScanner(null, available: false),
          masterData: FakeBarcodeMasterData(known: _product),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(WmsButton, 'Barkod skan et'), findsNothing);
    });
  });
}

class _StaticProductList extends ProductListNotifier {
  _StaticProductList(this.items);

  final List<ProductDto> items;

  @override
  Future<Page<ProductDto>> build() async =>
      Page<ProductDto>(items: items, page: 1, size: 50, total: items.length);
}
