import 'package:feature_inventory/feature_inventory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  group('ReceiptLineDraft', () {
    test('requires a variance note when received differs from ordered', () {
      final line = ReceiptLineDraft(
        productId: 1,
        uomId: 1,
        orderedQty: Quantity.parse('100'),
        receivedQty: Quantity.parse('97.5'),
      );
      expect(line.variance, Quantity.parse('-2.5'));
      expect(line.requiresVarianceNote, isTrue);
      expect(line.varianceNoteMissing, isTrue);
      expect(line.isValid, isFalse);

      line.varianceNote = 'Qutu zədəli';
      expect(line.varianceNoteMissing, isFalse);
      expect(line.isValid, isTrue);
    });

    test('equal quantities need no note', () {
      final line = ReceiptLineDraft(
        productId: 1,
        uomId: 1,
        orderedQty: Quantity.parse('100'),
        receivedQty: Quantity.parse('100'),
      );
      expect(line.variance, Quantity.zero);
      expect(line.requiresVarianceNote, isFalse);
      expect(line.isValid, isTrue);
    });

    test('lines without a PO have no variance requirement', () {
      final line = ReceiptLineDraft(
        productId: 1,
        uomId: 1,
        receivedQty: Quantity.parse('5'),
      );
      expect(line.variance, isNull);
      expect(line.requiresVarianceNote, isFalse);
      expect(line.isValid, isTrue);
    });

    test('a negative received quantity is never valid', () {
      final line = ReceiptLineDraft(
        productId: 1,
        uomId: 1,
        receivedQty: Quantity.parse('-1'),
      );
      expect(line.isValid, isFalse);
    });
  });

  group('BarcodeScanner', () {
    test('the default implementation reports no camera', () async {
      const scanner = UnsupportedBarcodeScanner();
      expect(scanner.isAvailable, isFalse);
      expect(await scanner.scan(), isNull);
    });
  });

  group('BalanceFilter', () {
    test('copyWith can clear the location', () {
      const filter = BalanceFilter(locationId: 3, search: 'chs');
      expect(filter.copyWith(clearLocation: true).locationId, isNull);
      expect(filter.copyWith(search: 'brd').search, 'brd');
      expect(filter.copyWith(locationId: 4).locationId, 4);
      expect(const BalanceFilter(locationId: 3, search: 'chs'), filter);
    });
  });
}
