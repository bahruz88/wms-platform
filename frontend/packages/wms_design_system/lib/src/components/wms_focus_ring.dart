import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';

/// Keyboard focus ring: `2px solid focus-ring`, `2px` offset. Every
/// focusable component wraps itself in this; the ring is never removed.
class WmsFocusRing extends StatelessWidget {
  const WmsFocusRing({
    required this.focused,
    required this.child,
    this.borderRadius = WmsRadius.mdAll,
    super.key,
  });

  final bool focused;
  final Widget child;
  final BorderRadius borderRadius;

  static const double width = 2;
  static const double offset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = WmsColors.of(context);
    return Container(
      padding: const EdgeInsets.all(offset),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius.topLeft.x + offset),
        ),
        border: Border.all(
          color: focused ? colors.focusRing : Colors.transparent,
          width: width,
        ),
      ),
      child: child,
    );
  }
}
