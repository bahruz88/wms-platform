import 'package:flutter/painting.dart';

/// Text styles of the design system (`tokens.json` → `type`).
///
/// * `sans` group: system UI font. `mono` group: tabular monospace figures,
///   mandatory for every number so decimals line up in columns.
/// * `letterSpacing` in `tokens.json` is in `em`; Flutter wants logical
///   pixels, so it is multiplied by the font size here.
/// * `height` is `lineHeight / fontSize`.
abstract final class WmsTypography {
  static const List<String> sansFallback = [
    'Segoe UI',
    'Noto Sans',
    'Arial',
    'sans-serif',
  ];

  static const List<String> monoFallback = [
    'SF Mono',
    'Menlo',
    'Consolas',
    'Roboto Mono',
    'monospace',
  ];

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  // --- Sans ---------------------------------------------------------------

  /// Screen title — once per page.
  static const TextStyle display = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 28,
    fontFamilyFallback: sansFallback,
  );

  /// Modal / document number heading.
  static const TextStyle titleLg = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: sansFallback,
  );

  /// Card / section heading.
  static const TextStyle title = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: sansFallback,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: sansFallback,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: sansFallback,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: sansFallback,
  );

  /// Form label / table header. Never upper-cased (`i`/`İ` rule).
  static const TextStyle label = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02 * 12,
    fontFamilyFallback: sansFallback,
  );

  // --- Mono (figures) -----------------------------------------------------

  /// KPI headline figure.
  static const TextStyle figureLg = TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: monoFallback,
    fontFeatures: tabular,
  );

  /// Quantities and amounts in tables.
  static const TextStyle figure = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFamilyFallback: monoFallback,
    fontFeatures: tabular,
  );

  /// Secondary figure: base UoM equivalent, conversion factor.
  static const TextStyle figureSm = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    fontFamilyFallback: monoFallback,
    fontFeatures: tabular,
  );

  /// Document numbers, SKU, batch numbers, barcodes.
  static const TextStyle docNo = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.01 * 13,
    fontFamilyFallback: monoFallback,
    fontFeatures: tabular,
  );

  /// Style name (as in `tokens.json`) → style, for tests.
  static const Map<String, TextStyle> styleMap = {
    'display': display,
    'title-lg': titleLg,
    'title': title,
    'body': body,
    'body-strong': bodyStrong,
    'caption': caption,
    'label': label,
    'figure-lg': figureLg,
    'figure': figure,
    'figure-sm': figureSm,
    'doc-no': docNo,
  };

  static const Set<String> monoStyles = {
    'figure-lg',
    'figure',
    'figure-sm',
    'doc-no',
  };
}
