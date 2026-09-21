import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_spinner.dart';

/// Blocks interaction while a document operation is in flight. The content
/// stays visible underneath (no layout jump).
class WmsLoadingOverlay extends StatelessWidget {
  const WmsLoadingOverlay({
    required this.loading,
    required this.child,
    this.message,
    super.key,
  });

  final bool loading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: Semantics(
              liveRegion: true,
              label: message ?? 'Yüklənir',
              child: ColoredBox(
                color: c.scrim,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: WmsSpacing.space3,
                      horizontal: WmsSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      borderRadius: WmsRadius.mdAll,
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WmsSpinner(color: c.accent),
                        const SizedBox(width: WmsSpacing.space3),
                        Text(
                          message ?? 'Yüklənir…',
                          style: WmsTypography.body.copyWith(color: c.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
