import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:wms_core/wms_core.dart';

void main() {
  group('Money', () {
    test('round-trips JSON string', () {
      expect(Money.fromJson('1250').toJson(), '1250.0000');
      expect(Money.fromJson('0.005').toJson(), '0.0050');
    });

    test('line total = qty × unit price, rounded away from zero', () {
      final price = Money.parse('3.3333', currency: 'AZN');
      final total = price.multiply(Quantity.parse('3'));
      expect(total.toJson(), '9.9999');
      expect(total.currency, 'AZN');
      final half = Money.parse('0.00005').multiply(Quantity.fromInt(1));
      expect(half.toJson(), '0.0001');
    });

    test('VAT percent and FX conversion', () {
      final net = Money.parse('100', currency: 'USD');
      expect(net.percent(Decimal.parse('18')).toJson(), '18.0000');
      final base = net.toBase(Decimal.parse('1.7'), baseCurrency: 'AZN');
      expect(base.toJson(), '170.0000');
      expect(base.currency, 'AZN');
    });

    test('addition guards currency mismatch', () {
      final a = Money.parse('1', currency: 'AZN');
      final b = Money.parse('2', currency: 'USD');
      expect(() => a + b, throwsArgumentError);
      expect((a + Money.parse('2')).toJson(), '3.0000');
    });

    test('format', () {
      expect(Money.parse('1250.5', currency: 'AZN').format(), '1250.50 AZN');
      expect(Money.parse('1250.5').format(), '1250.50');
    });
  });

  group('DecimalRoundingX', () {
    test('divide rounds and refuses zero divisor', () {
      expect(
        Decimal.fromInt(1).divide(Decimal.fromInt(3), scale: 4),
        Decimal.parse('0.3333'),
      );
      expect(
        Decimal.fromInt(2).divide(Decimal.fromInt(3), scale: 4),
        Decimal.parse('0.6667'),
      );
      expect(() => Decimal.one.divide(Decimal.zero), throwsArgumentError);
    });

    test('percentOf', () {
      expect(
        Decimal.parse('-3').percentOf(Decimal.parse('150')),
        Decimal.parse('-2'),
      );
      expect(Decimal.one.percentOf(Decimal.zero), isNull);
    });
  });
}
