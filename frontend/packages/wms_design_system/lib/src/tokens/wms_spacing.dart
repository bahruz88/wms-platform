import 'package:flutter/widgets.dart';

/// 4px grid (`tokens.json` → `spacing`).
abstract final class WmsSpacing {
  /// Icon-to-text gap, badge vertical padding.
  static const double space1 = 4;

  /// Dense table cell vertical padding, button vertical padding.
  static const double space2 = 8;

  /// Standard table cell padding, input horizontal padding.
  static const double space3 = 12;

  /// Card padding, gap between form rows.
  static const double space4 = 16;

  /// Modal padding, gap between card blocks.
  static const double space5 = 24;

  /// Gap between page sections.
  static const double space6 = 32;

  /// Page top padding, empty-state surround.
  static const double space7 = 48;

  static const Map<String, double> tokenMap = {
    'space-1': space1,
    'space-2': space2,
    'space-3': space3,
    'space-4': space4,
    'space-5': space5,
    'space-6': space6,
    'space-7': space7,
  };

  static const EdgeInsets cardPadding = EdgeInsets.all(space4);
  static const EdgeInsets dialogPadding = EdgeInsets.all(space5);
  static const EdgeInsets denseCell = EdgeInsets.symmetric(
    vertical: space2,
    horizontal: space3,
  );
  static const EdgeInsets cell = EdgeInsets.all(space3);
  static const EdgeInsets control = EdgeInsets.symmetric(
    vertical: space2,
    horizontal: space3,
  );
}
