import 'package:flutter/widgets.dart';

/// Window size classes used by the adaptive scaffold.
enum WmsWindowSize {
  /// `< 600` — phones: bottom navigation.
  compact,

  /// `600..1023` — tablets: navigation rail.
  medium,

  /// `>= 1024` — desktop/web: extended navigation rail.
  expanded;

  bool get isCompact => this == WmsWindowSize.compact;
  bool get isExpanded => this == WmsWindowSize.expanded;
}

abstract final class WmsBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;

  static WmsWindowSize fromWidth(double width) {
    if (width < compact) return WmsWindowSize.compact;
    if (width < medium) return WmsWindowSize.medium;
    return WmsWindowSize.expanded;
  }

  static WmsWindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
