import 'package:flutter/widgets.dart';

import 'wms_breakpoints.dart';

/// Control sizing by window size.
///
/// The enterprise tables are dense on purpose — a 34 px button keeps a desktop
/// document screen readable without scrolling. A phone is not that: the person
/// holding it is wearing a glove in a freezer, and the mockups had to add
/// `min-height: 48px` to every control themselves with a note saying the design
/// system had no touch size yet. This is that size, so a screen no longer has to
/// restate it.
///
/// 48 logical pixels is the floor both platforms publish (Material's touch
/// target, Apple's 44 pt plus the padding a label needs), and 16 px text is what
/// keeps iOS Safari and the Android keyboard from zooming the field on focus.
abstract final class WmsTouch {
  /// Minimum height of a button, input, select or row that can be tapped.
  static const double target = 48;

  /// Text size inside a control on a phone. Below 16 the platform zooms.
  static const double controlFontSize = 16;

  /// `true` on a phone-width window, where [target] applies.
  static bool isTouch(BuildContext context) =>
      WmsBreakpoints.of(context).isCompact;

  /// [target] on a phone, [dense] on a pointer-sized window.
  static double height(BuildContext context, {required double dense}) =>
      isTouch(context) ? target : dense;
}
