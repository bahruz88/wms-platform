import 'dart:typed_data';

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

import 'fake_attachment_repository.dart';
import 'fake_inventory_repository.dart';

const _location = LocationDto(
  id: 3,
  code: 'FOOD-WH',
  name: 'Qida anbarı',
  locationType: LocationType.centralWarehouse,
  isVirtual: false,
);

final _product = ProductDto(
  id: 1,
  sku: 'CHS-0042',
  name: 'Chicken Strips',
  categoryId: 2,
  baseUomId: 5,
  baseUomCode: 'KG',
  vatRate: Decimal.zero,
);

const _uom = UomDto(
  id: 5,
  code: 'KG',
  name: 'Kiloqram',
  uomClass: UomClass.mass,
);

ReasonCodeDto _reason({required bool requiresPhoto}) => ReasonCodeDto(
  id: 9,
  code: 'WST-EXP',
  name: 'Vaxtı keçib',
  reasonGroup: ReasonGroup.waste,
  requiresPhoto: requiresPhoto,
);

PickedAttachment _photo() => PickedAttachment(
  fileName: 'tullanti.jpg',
  contentType: 'image/jpeg',
  bytes: Uint8List.fromList(List<int>.filled(1024, 3)),
);

Widget host({
  required FakeInventoryRepository inventory,
  required bool requiresPhoto,
  AttachmentPicker picker = const UnsupportedAttachmentPicker(),
}) => ProviderScope(
  overrides: [
    inventoryRepositoryProvider.overrideWithValue(inventory),
    attachmentRepositoryProvider.overrideWithValue(FakeAttachmentRepository()),
    attachmentPickerProvider.overrideWithValue(picker),
    locationListProvider.overrideWith((ref) async => const [_location]),
    uomListProvider.overrideWith((ref) async => const [_uom]),
    productListProvider.overrideWith(() => _StaticProductList([_product])),
    reasonCodeListProvider(ReasonGroup.waste)
        .overrideWith((ref) async => [_reason(requiresPhoto: requiresPhoto)]),
  ],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: const WasteFormScreen(),
  ),
);

/// Fills location, reason, product and quantity so only the photo rule is
/// left to decide whether the document can be created.
Future<void> fillForm(WidgetTester tester) async {
  Future<void> pick(String label, String option) async {
    await tester.tap(find.byType(WmsSelect<int>).at(_selectIndex(label)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  await pick('Lokasiya', 'FOOD-WH · Qida anbarı');
  await pick('Səbəb kodu', 'WST-EXP · Vaxtı keçib');
  await pick('Məhsul', 'CHS-0042 · Chicken Strips');

  await tester.enterText(find.byType(TextField).last, '2,5');
  await tester.pumpAndSettle();
}

int _selectIndex(String label) => switch (label) {
  'Lokasiya' => 0,
  'Səbəb kodu' => 1,
  _ => 2,
};

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          ..physicalSize = const Size(1400, 2200)
          ..devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('a reason code with requiresPhoto blocks the create button', (
    tester,
  ) async {
    final inventory = FakeInventoryRepository();
    await tester.pumpWidget(
      host(
        inventory: inventory,
        requiresPhoto: true,
        picker: StaticAttachmentPicker(_photo()),
      ),
    );
    await tester.pumpAndSettle();
    await fillForm(tester);

    final create = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Yarat'),
    );
    expect(create.enabled, isFalse);
    expect(create.disabledReason, 'Bu səbəb kodu foto tələb edir');
    expect(find.text('Foto *'), findsOneWidget);
  });

  testWidgets('after the upload the document is created with attachmentIds', (
    tester,
  ) async {
    final inventory = FakeInventoryRepository();
    await tester.pumpWidget(
      host(
        inventory: inventory,
        requiresPhoto: true,
        picker: StaticAttachmentPicker(_photo()),
      ),
    );
    await tester.pumpAndSettle();
    await fillForm(tester);

    await tester.tap(find.text('Foto əlavə et'));
    await tester.pumpAndSettle();
    expect(find.text('tullanti.jpg'), findsOneWidget);

    final create = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Yarat'),
    );
    expect(create.enabled, isTrue);

    await tester.tap(find.widgetWithText(WmsButton, 'Yarat'));
    await tester.pumpAndSettle();

    expect(inventory.createdWaste, hasLength(1));
    final request = inventory.createdWaste.single;
    expect(request.attachmentIds, [42]);
    expect(request.reasonCodeId, 9);
    expect(request.locationId, 3);
    expect(request.lines.single.qty, Quantity.parse('2.5'));
    expect(find.textContaining('WS-2026-00001'), findsOneWidget);
    // The attachment block starts empty for the next draft.
    expect(find.text('tullanti.jpg'), findsNothing);
    expect(find.text('Foto əlavə et'), findsOneWidget);
  });

  testWidgets('without requiresPhoto the block is optional', (tester) async {
    await tester.pumpWidget(
      host(
        inventory: FakeInventoryRepository(),
        requiresPhoto: false,
        picker: StaticAttachmentPicker(_photo()),
      ),
    );
    await tester.pumpAndSettle();
    await fillForm(tester);

    expect(find.text('Foto'), findsOneWidget);
    expect(find.text('Foto *'), findsNothing);
    final create = tester.widget<WmsButton>(
      find.widgetWithText(WmsButton, 'Yarat'),
    );
    expect(create.enabled, isTrue);
  });
}

class _StaticProductList extends ProductListNotifier {
  _StaticProductList(this.items);

  final List<ProductDto> items;

  @override
  Future<Page<ProductDto>> build() async =>
      Page<ProductDto>(items: items, page: 1, size: 50, total: items.length);
}
