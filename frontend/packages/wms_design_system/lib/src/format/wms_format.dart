import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:wms_core/wms_core.dart';

/// Number/date formatting of the design system (`index.d.ts` → `format`).
///
/// * decimal separator is a comma, thousands separator is a narrow no-break
///   space (U+202F): `1 284,5000`;
/// * the minus sign is U+2212 (`−`), never an ASCII hyphen;
/// * numbers are never truncated: `decimals` comes from `base_uom.decimals`
///   and rounding (when needed) is half away from zero like the backend.
///
/// Formatting works on [Decimal] strings directly (not through `double`) so
/// 18-digit amounts keep every digit.
abstract final class WmsFormat {
  static const String thousandsSeparator = ' ';
  static const String decimalSeparator = ',';
  static const String minusSign = '−';
  static const String plusSign = '+';

  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm');

  /// `1234.5` → `1 234,5000`.
  static String number(Decimal? value, {int decimals = kQuantityScale}) {
    if (value == null) return '';
    final rounded = value.roundAwayFromZero(decimals);
    final negative = rounded < Decimal.zero;
    final fixed = rounded.abs().toStringAsFixed(decimals);
    final dot = fixed.indexOf('.');
    final integerPart = dot == -1 ? fixed : fixed.substring(0, dot);
    final fraction = dot == -1 ? '' : fixed.substring(dot + 1);
    final grouped = _group(integerPart);
    final body = fraction.isEmpty
        ? grouped
        : '$grouped$decimalSeparator$fraction';
    return negative ? '$minusSign$body' : body;
  }

  /// `+12,0000` / `−12,0000`; zero is shown without a sign (neutral).
  static String signed(Decimal? value, {int decimals = kQuantityScale}) {
    if (value == null) return '';
    if (value == Decimal.zero) return number(value, decimals: decimals);
    final text = number(value, decimals: decimals);
    return value > Decimal.zero ? '$plusSign$text' : text;
  }

  static String quantity(Quantity? qty, {int decimals = kQuantityScale}) =>
      number(qty?.value, decimals: decimals);

  static String signedQuantity(
    Quantity? qty, {
    int decimals = kQuantityScale,
  }) => signed(qty?.value, decimals: decimals);

  /// `1 250,00 AZN` (currency appended when known).
  static String money(Money? money, {int decimals = 2}) {
    if (money == null) return '';
    final text = number(money.amount, decimals: decimals);
    final currency = money.currency;
    return currency == null ? text : '$text $currency';
  }

  /// `−2,50 %`.
  static String percent(
    Decimal? pct, {
    int decimals = 2,
    bool withSign = false,
  }) {
    if (pct == null) return '';
    final text = withSign
        ? signed(pct, decimals: decimals)
        : number(pct, decimals: decimals);
    return '$text %';
  }

  /// `dd.MM.yyyy`. The caller converts UTC to the tenant timezone first.
  static String date(DateTime? value) =>
      value == null ? '' : _date.format(value);

  /// `dd.MM.yyyy HH:mm`.
  static String dateTime(DateTime? value) =>
      value == null ? '' : _dateTime.format(value);

  /// Number of whole days from [from] (default: today) to [date]; negative
  /// when in the past.
  static int daysUntil(DateTime date, {DateTime? from}) {
    final today = from ?? DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(date.year, date.month, date.day);
    return b.difference(a).inDays;
  }

  static String _group(String digits) {
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    final firstGroup = digits.length % 3;
    if (firstGroup > 0) buffer.write(digits.substring(0, firstGroup));
    for (var i = firstGroup; i < digits.length; i += 3) {
      if (buffer.isNotEmpty) buffer.write(thousandsSeparator);
      buffer.write(digits.substring(i, i + 3));
    }
    return buffer.toString();
  }
}
