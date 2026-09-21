import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  group('Quantity', () {
    test('round-trips JSON string with 4 fractional digits', () {
      final q = Quantity.fromJson('12.5');
      expect(q.toJson(), '12.5000');
      expect(Quantity.fromJson('-23.51').toJson(), '-23.5100');
    });

    test('rejects JSON numbers (must be strings)', () {
      expect(() => decimalFromJson(1.5), throwsFormatException);
      expect(() => Quantity.fromJson('abc'), throwsFormatException);
    });

    test('has no floating point artefacts', () {
      // The Excel failure mode: 0.1 + 0.2 != 0.3 in binary floating point.
      final sum = Quantity.parse('0.1') + Quantity.parse('0.2');
      expect(sum, Quantity.parse('0.3'));
      expect(sum.toJson(), '0.3000');
    });

    test('rounds midpoint away from zero (AwayFromZero)', () {
      expect(Quantity.parse('1.00005').rounded().toJson(), '1.0001');
      expect(Quantity.parse('-1.00005').rounded().toJson(), '-1.0001');
      expect(Quantity.parse('2.5').rounded(0).toJson(), '3.0000');
      expect(Quantity.parse('-2.5').rounded(0).toJson(), '-3.0000');
    });

    test('toBase applies frozen conversion factor with base decimals', () {
      // 1 CASE = 12 PCS
      final entered = Quantity.parse('3');
      final base = entered.toBase(Decimal.parse('12.00000000'), decimals: 0);
      expect(base, Quantity.fromInt(36));
      // 2.5 KG expressed in G with factor 1000, then rounded to 3 decimals
      final g = Quantity.parse('2.5')
          .toBase(Decimal.fromInt(1000), decimals: 3);
      expect(g.toJson(), '2500.0000');
    });

    test('variance and variance percent', () {
      final book = Quantity.parse('100');
      final counted = Quantity.parse('97.5');
      expect(counted.varianceFrom(book).toJson(), '-2.5000');
      expect(counted.variancePctFrom(book), Decimal.parse('-2.5'));
      expect(counted.variancePctFrom(Quantity.zero), isNull);
    });

    test('tryParse accepts comma decimal separator and rejects garbage', () {
      expect(Quantity.tryParse('12,5'), Quantity.parse('12.5'));
      expect(Quantity.tryParse('1 000,25'), Quantity.parse('1000.25'));
      expect(Quantity.tryParse(''), isNull);
      expect(Quantity.tryParse('12.5.1'), isNull);
      expect(Quantity.tryParse(null), isNull);
    });

    test('comparison and equality', () {
      expect(Quantity.parse('1.0') == Quantity.parse('1'), isTrue);
      expect(Quantity.parse('1') < Quantity.parse('2'), isTrue);
      expect(Quantity.zero.isZero, isTrue);
      expect((-Quantity.parse('4')).isNegative, isTrue);
    });
  });
}
