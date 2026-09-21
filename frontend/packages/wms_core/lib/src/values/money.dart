import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

import 'decimal_rounding.dart';
import 'quantity.dart';

/// A monetary amount. Wraps a [Decimal]; never a `double`.
///
/// The API transports amounts as strings (`"1250.0000"`) with the currency in
/// a sibling field, therefore [Money.fromJson] takes only the amount and
/// [currency] is optional. Use [withCurrency] once the sibling is known.
@immutable
class Money implements Comparable<Money> {
  const Money(this.amount, {this.currency});

  factory Money.parse(String source, {String? currency}) =>
      Money(Decimal.parse(source.trim()), currency: currency);

  factory Money.fromInt(int value, {String? currency}) =>
      Money(Decimal.fromInt(value), currency: currency);

  /// JSON deserialisation (`"1250.0000"`).
  factory Money.fromJson(String json) => Money(decimalFromJson(json));

  static Money? tryParse(String? source, {String? currency}) {
    if (source == null) return null;
    final normalised = source.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (normalised.isEmpty) return null;
    final parsed = Decimal.tryParse(normalised);
    return parsed == null ? null : Money(parsed, currency: currency);
  }

  static final Money zero = Money(Decimal.zero);

  final Decimal amount;

  /// ISO 4217 code (`AZN`, `USD`...), `null` when unknown at parse time.
  final String? currency;

  bool get isZero => amount == Decimal.zero;
  bool get isNegative => amount < Decimal.zero;

  /// JSON serialisation with the canonical money scale.
  String toJson() => amount.toWire(kMoneyScale);

  Money withCurrency(String code) => Money(amount, currency: code);

  Money rounded([int scale = kMoneyScale]) =>
      Money(amount.roundAwayFromZero(scale), currency: currency);

  /// `line_total = qty × unit_price`, rounded away from zero.
  Money multiply(Quantity qty) => Money(
    (amount * qty.value).roundAwayFromZero(kMoneyScale),
    currency: currency,
  );

  /// Applies a percentage (e.g. VAT 18 → `amount × 0.18`).
  Money percent(Decimal pct) => Money(
    (amount * pct).divide(Decimal.fromInt(100), scale: kMoneyScale),
    currency: currency,
  );

  /// Converts to base currency using an FX rate (`unit_cost_base = price × fx`).
  Money toBase(Decimal fxRate, {required String baseCurrency}) => Money(
    (amount * fxRate).roundAwayFromZero(kMoneyScale),
    currency: baseCurrency,
  );

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount + other.amount, currency: currency ?? other.currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount - other.amount, currency: currency ?? other.currency);
  }

  Money operator -() => Money(-amount, currency: currency);
  bool operator <(Money other) => amount < other.amount;
  bool operator >(Money other) => amount > other.amount;

  void _assertSameCurrency(Money other) {
    if (currency != null &&
        other.currency != null &&
        currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
  }

  /// Human readable, e.g. `1250.00 AZN`.
  String format({int decimals = 2}) {
    final text = amount.toStringAsFixed(decimals);
    return currency == null ? text : '$text $currency';
  }

  @override
  int compareTo(Money other) => amount.compareTo(other.amount);

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() =>
      'Money(${toJson()}${currency == null ? '' : ' $currency'})';
}
