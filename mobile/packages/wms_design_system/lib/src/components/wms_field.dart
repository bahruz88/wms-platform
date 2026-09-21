import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';

/// `.wms-field` — label + control + hint/error shell. When [error] is set the
/// hint is hidden and the control (child) should paint a `danger` border.
class WmsField extends StatelessWidget {
  const WmsField({
    required this.child,
    this.label,
    this.required = false,
    this.hint,
    this.error,
    super.key,
  });

  final Widget child;
  final String? label;
  final bool required;
  final String? hint;
  final String? error;

  bool get hasError => error != null && error!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          // Two plain Texts (not Text.rich) so `find.text` keeps working in
          // app tests and screen readers announce the label cleanly.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label!,
                  style: WmsTypography.label.copyWith(color: c.ink),
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: WmsTypography.label.copyWith(color: c.danger),
                  semanticsLabel: 'məcburi',
                ),
            ],
          ),
          const SizedBox(height: WmsSpacing.space1),
        ],
        child,
        if (hasError) ...[
          const SizedBox(height: WmsSpacing.space1),
          Text(error!, style: WmsTypography.caption.copyWith(color: c.danger)),
        ] else if (hint != null && hint!.isNotEmpty) ...[
          const SizedBox(height: WmsSpacing.space1),
          Text(hint!, style: WmsTypography.caption.copyWith(color: c.inkMuted)),
        ],
      ],
    );
  }
}
