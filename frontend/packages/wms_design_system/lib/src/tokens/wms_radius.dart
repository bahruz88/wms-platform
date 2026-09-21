import 'package:flutter/painting.dart';

/// Corner radii (`tokens.json` → `radius`). Small on purpose: dense data UI.
abstract final class WmsRadius {
  /// Badge, checkbox, small marker.
  static const double sm = 4;

  /// Button, input, select.
  static const double md = 6;

  /// Card, panel, modal.
  static const double lg = 10;

  /// Status dot, counter badge.
  static const double pill = 999;

  static const Map<String, double> tokenMap = {
    'radius-sm': sm,
    'radius-md': md,
    'radius-lg': lg,
    'radius-pill': pill,
  };

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
