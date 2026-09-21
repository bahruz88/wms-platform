import 'package:flutter/material.dart';

/// `.wms-spinner` — 14px ring, 2px stroke, inherits the text colour.
/// Static when the platform asks for reduced motion.
class WmsSpinner extends StatelessWidget {
  const WmsSpinner({this.size = 14, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        DefaultTextStyle.of(context).style.color ??
        IconTheme.of(context).color;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: resolved,
        value: reduced ? 0.75 : null,
      ),
    );
  }
}
