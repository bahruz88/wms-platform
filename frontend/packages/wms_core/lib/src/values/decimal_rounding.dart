import 'package:decimal/decimal.dart';

/// Scale used for quantities (`DECIMAL(18,4)` in the spec).
const int kQuantityScale = 4;

/// Scale used for money amounts (`DECIMAL(18,4)` in the spec).
const int kMoneyScale = 4;

/// Scale used for UoM conversion factors and FX rates (`DECIMAL(18,8)`).
const int kFactorScale = 8;

/// Scale used for percentages (`DECIMAL(9,4)`).
const int kPercentScale = 4;

/// Scale used when a division has an infinite decimal expansion.
const int kDivisionScale = 10;

/// Rounding helpers matching the backend (`MidpointRounding.AwayFromZero`).
///
/// `decimal`'s [Decimal.round] already rounds half away from zero
/// (`(3.5).round() == 4`, `(-3.5).round() == -4`), these helpers only make the
/// intent explicit and centralise the scales.
extension DecimalRoundingX on Decimal {
  /// Rounds to [scale] fractional digits, midpoint away from zero.
  Decimal roundAwayFromZero(int scale) => round(scale: scale);

  /// Renders the value with exactly [scale] fractional digits
  /// (e.g. `12.5` → `"12.5000"`), which is the JSON wire format.
  String toWire(int scale) => roundAwayFromZero(scale).toStringAsFixed(scale);

  /// Divides by [divisor] returning a [Decimal] rounded away from zero at
  /// [scale]. Throws [ArgumentError] when [divisor] is zero.
  Decimal divide(Decimal divisor, {int scale = kDivisionScale}) {
    if (divisor == Decimal.zero) {
      throw ArgumentError.value(divisor, 'divisor', 'must not be zero');
    }
    return (this / divisor)
        .toDecimal(scaleOnInfinitePrecision: scale + 2)
        .roundAwayFromZero(scale);
  }

  /// Percentage of `this` relative to [whole] (`this / whole * 100`),
  /// rounded to [kPercentScale]. Returns `null` when [whole] is zero.
  Decimal? percentOf(Decimal whole) {
    if (whole == Decimal.zero) return null;
    return (this * Decimal.fromInt(100)).divide(whole, scale: kPercentScale);
  }
}

/// Parses a JSON string (`"12.5000"`) into a [Decimal].
///
/// Numbers are never accepted: the API contract says all quantities/amounts
/// are strings, and accepting a JSON number would silently re-introduce
/// binary floating point artefacts.
Decimal decimalFromJson(Object? json) {
  if (json is String) {
    final parsed = Decimal.tryParse(json.trim());
    if (parsed != null) return parsed;
    throw FormatException('Invalid decimal string', json);
  }
  if (json is int) return Decimal.fromInt(json);
  throw FormatException(
    'Decimal JSON values must be strings, got ${json.runtimeType}',
    json,
  );
}

/// Serialises a [Decimal] as a JSON string with [scale] fractional digits.
String decimalToJson(Decimal value, {int scale = kQuantityScale}) =>
    value.toWire(scale);
