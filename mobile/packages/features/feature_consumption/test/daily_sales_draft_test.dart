import 'package:feature_consumption/feature_consumption.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

MenuItemDto _item(int id, String name) =>
    MenuItemDto(id: id, code: 'M$id', name: name);

final _items = [
  _item(1, 'Italian BMT 15 sm'),
  _item(2, 'Tuna 30 sm'),
  _item(3, 'Chicken Teriyaki 15 sm'),
];

void main() {
  group('DailySalesDraft', () {
    test('starts empty and reports a zero total', () {
      const draft = DailySalesDraft();
      expect(draft.isEmpty, isTrue);
      expect(draft.enteredCount, 0);
      expect(draft.totalUnits, Quantity.zero);
      expect(draft.toLines(), isEmpty);
    });

    test('keeps a running total across items', () {
      final draft = const DailySalesDraft()
          .withQuantity(1, Quantity.fromInt(120))
          .withQuantity(2, Quantity.fromInt(35));
      expect(draft.enteredCount, 2);
      expect(draft.totalUnits, Quantity.fromInt(155));
    });

    test('clearing an item removes it instead of sending a zero', () {
      final draft = const DailySalesDraft()
          .withQuantity(1, Quantity.fromInt(10))
          .withQuantity(2, Quantity.zero)
          .withQuantity(1, null);
      expect(draft.isEmpty, isTrue);
      expect(draft.quantityOf(2), isNull);
    });

    test('a negative quantity is never stored', () {
      final draft = const DailySalesDraft().withQuantity(
        1,
        Quantity.parse('-5'),
      );
      expect(draft.isEmpty, isTrue);
    });

    test(
      'recently used items float to the top, the rest keep server order',
      () {
        final draft = const DailySalesDraft()
            .withQuantity(3, Quantity.fromInt(4))
            .withQuantity(1, Quantity.fromInt(9));
        final sorted = draft.sort(_items);
        expect(sorted.map((i) => i.id).toList(), [1, 3, 2]);
      },
    );

    test('sorting an untouched draft leaves the server order alone', () {
      expect(const DailySalesDraft().sort(_items).map((i) => i.id).toList(), [
        1,
        2,
        3,
      ]);
    });

    test('toLines follows the recent order and carries only menu item ids', () {
      final draft = const DailySalesDraft()
          .withQuantity(2, Quantity.fromInt(7))
          .withQuantity(1, Quantity.fromInt(3));
      final lines = draft.toLines();
      expect(lines.map((l) => l.menuItemId).toList(), [1, 2]);
      expect(lines.first.qtySold, Quantity.fromInt(3));
      expect(lines.first.posCode, isNull);
    });

    test('seeds itself from an existing DRAFT import', () {
      final draft = DailySalesDraft.fromImport(
        SalesImportDetailDto(
          id: 5,
          locationId: 1,
          businessDate: DateTime(2026, 9, 21),
          source: SalesSource.manual,
          status: SalesImportStatus.draft,
          rowVersion: 2,
          lines: [
            SalesLineDto(menuItemId: 2, qtySold: Quantity.fromInt(11)),
            SalesLineDto(menuItemId: 1, qtySold: Quantity.fromInt(4)),
            // Unmapped line: no menu item, so nothing to seed.
            SalesLineDto(
              rawPosCode: 'PLU-77',
              qtySold: Quantity.fromInt(2),
              isMapped: false,
            ),
          ],
        ),
      );
      expect(draft.enteredCount, 2);
      expect(draft.totalUnits, Quantity.fromInt(15));
      expect(draft.sort(_items).first.id, 2);
    });
  });

  group('planDailySales', () {
    SalesImportDto importWith(SalesImportStatus status) => SalesImportDto(
      id: 42,
      locationId: 1,
      businessDate: DateTime(2026, 9, 21),
      source: SalesSource.manual,
      status: status,
      rowVersion: 3,
    );

    test('no document for the day means create then submit', () {
      expect(planDailySales(null), isA<CreateAndSubmit>());
    });

    test('a DRAFT is replaced, carrying its row version', () {
      final action = planDailySales(importWith(SalesImportStatus.draft));
      expect(action, isA<ReplaceAndSubmit>());
      expect((action as ReplaceAndSubmit).importId, 42);
      expect(action.rowVersion, 3);
    });

    test('an already submitted or consumed day is blocked', () {
      for (final status in [
        SalesImportStatus.submitted,
        SalesImportStatus.consumed,
        SalesImportStatus.cancelled,
      ]) {
        final action = planDailySales(importWith(status));
        expect(action, isA<DailySalesBlocked>(), reason: status.wire);
        expect((action as DailySalesBlocked).status, status);
      }
    });
  });
}
