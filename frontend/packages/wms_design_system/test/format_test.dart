import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

void main() {
  group('WmsFormat.number', () {
    test('uses a comma decimal separator and U+202F thousands separator', () {
      final text = WmsFormat.number(Decimal.parse('1234.5'));
      expect(text, '1 234,5000');
      expect(text.contains(','), isTrue);
      expect(text.contains(' '), isTrue);
      expect(
        text.contains(' '),
        isFalse,
        reason: 'must be a narrow no-break space',
      );
    });

    test('groups by three from the right', () {
      expect(WmsFormat.number(Decimal.parse('1284'), decimals: 0), '1 284');
      expect(
        WmsFormat.number(Decimal.parse('12345678.9'), decimals: 1),
        '12 345 678,9',
      );
      expect(WmsFormat.number(Decimal.parse('999'), decimals: 0), '999');
      expect(WmsFormat.number(Decimal.parse('0.5')), '0,5000');
    });

    test('uses U+2212 for the minus sign, never an ASCII hyphen', () {
      final text = WmsFormat.number(Decimal.parse('-23.5'));
      expect(text, '−23,5000');
      expect(text.startsWith('−'), isTrue);
      expect(text.contains('-'), isFalse);
    });

    test('never truncates: decimals come from base_uom.decimals', () {
      expect(WmsFormat.number(Decimal.parse('2.5')), '2,5000');
      expect(WmsFormat.number(Decimal.parse('2.123456'), decimals: 3), '2,123');
      // Rounding is half away from zero, like the backend.
      expect(WmsFormat.number(Decimal.parse('2.1235'), decimals: 3), '2,124');
      expect(WmsFormat.number(Decimal.parse('-2.1235'), decimals: 3), '−2,124');
      expect(WmsFormat.number(Decimal.parse('0'), decimals: 0), '0');
      expect(WmsFormat.number(null), '');
    });

    test(
      'keeps full precision of 18-digit decimals (no double round-trip)',
      () {
        expect(
          WmsFormat.number(Decimal.parse('12345678901234.5678')),
          '12 345 678 901 234,5678',
        );
      },
    );
  });

  group('WmsFormat.signed', () {
    test('adds + for positive and U+2212 for negative, zero stays neutral', () {
      expect(WmsFormat.signed(Decimal.parse('12')), '+12,0000');
      expect(WmsFormat.signed(Decimal.parse('-12')), '−12,0000');
      expect(WmsFormat.signed(Decimal.zero), '0,0000');
      expect(
        WmsFormat.signedQuantity(Quantity.parse('6'), decimals: 3),
        '+6,000',
      );
    });
  });

  group('dates and derived helpers', () {
    test('date is dd.MM.yyyy and dateTime adds HH:mm', () {
      final value = DateTime(2026, 9, 20, 14, 5);
      expect(WmsFormat.date(value), '20.09.2026');
      expect(WmsFormat.dateTime(value), '20.09.2026 14:05');
      expect(WmsFormat.date(null), '');
    });

    test('money appends the currency, percent appends %', () {
      expect(
        WmsFormat.money(Money.parse('1250.5', currency: 'AZN')),
        '1 250,50 AZN',
      );
      expect(WmsFormat.money(Money.parse('10')), '10,00');
      expect(WmsFormat.percent(Decimal.parse('-2.5')), '−2,50 %');
      expect(
        WmsFormat.percent(Decimal.parse('2.5'), withSign: true),
        '+2,50 %',
      );
    });

    test('daysUntil counts whole calendar days', () {
      final today = DateTime(2026, 9, 20, 23);
      expect(WmsFormat.daysUntil(DateTime(2026, 9, 27), from: today), 7);
      expect(WmsFormat.daysUntil(DateTime(2026, 9, 18), from: today), -2);
      expect(WmsFormat.daysUntil(DateTime(2026, 9, 20, 1), from: today), 0);
    });
  });
}
