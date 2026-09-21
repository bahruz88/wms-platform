import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';

import 'decimal_rounding.dart';

/// A stock quantity. Wraps a [Decimal]; never a `double`.
///
/// Wire format is a JSON string with four fractional digits (`"12.5000"`).
/// Arithmetic is exact; use [rounded] / [toBase] to apply the UoM scale.
@immutable
class Quantity implements Comparable<Quantity> {
  const Quantity(this.value);

  /// Parses a string such as `12.5` or `-3`. Throws [FormatException] on
  /// invalid input.
  factory Quantity.parse(String source) =>
      Quantity(Decimal.parse(source.trim()));

  factory Quantity.fromInt(int value) => Quantity(Decimal.fromInt(value));

  /// JSON deserialisation (`"12.5000"`).
  factory Quantity.fromJson(String json) => Quantity(decimalFromJson(json));

  /// Parses user input; returns `null` for empty or invalid strings.
  /// Accepts `,` as a decimal separator (az/ru locales).
  static Quantity? tryParse(String? source) {
    if (source == null) return null;
    final normalised = source.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (normalised.isEmpty) return null;
    final parsed = Decimal.tryParse(normalised);
    return parsed == null ? null : Quantity(parsed);
  }

  static final Quantity zero = Quantity(Decimal.zero);

  final Decimal value;

  bool get isZero => value == Decimal.zero;
  bool get isNegative => value < Decimal.zero;
  bool get isPositive => value > Decimal.zero;

  /// JSON serialisation with the canonical quantity scale.
  String toJson() => value.toWire(kQuantityScale);

  /// Rounds away from zero to [scale] fractional digits (default: UoM scale 4).
  Quantity rounded([int scale = kQuantityScale]) =>
      Quantity(value.roundAwayFromZero(scale));

  /// `qty_base = entered_qty × conversion_rate`, rounded to the base UoM
  /// [decimals] (spec §12.1).
  Quantity toBase(Decimal factorToBase, {int decimals = kQuantityScale}) =>
      Quantity((value * factorToBase).roundAwayFromZero(decimals));

  /// Variance of `this` (counted) against [book]: `counted − book`.
  Quantity varianceFrom(Quantity book) => this - book;

  /// Variance percentage relative to [book]; `null` when [book] is zero.
  Decimal? variancePctFrom(Quantity book) =>
      varianceFrom(book).value.percentOf(book.value);

  Quantity operator +(Quantity other) => Quantity(value + other.value);
  Quantity operator -(Quantity other) => Quantity(value - other.value);
  Quantity operator -() => Quantity(-value);
  Quantity operator *(Decimal factor) => Quantity(value * factor);
  bool operator <(Quantity other) => value < other.value;
  bool operator <=(Quantity other) => value <= other.value;
  bool operator >(Quantity other) => value > other.value;
  bool operator >=(Quantity other) => value >= other.value;

  Quantity abs() => Quantity(value.abs());

  /// Human readable representation with [decimals] fractional digits.
  String format({int decimals = kQuantityScale}) =>
      value.toStringAsFixed(decimals);

  @override
  int compareTo(Quantity other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is Quantity && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Quantity(${toJson()})';
}
