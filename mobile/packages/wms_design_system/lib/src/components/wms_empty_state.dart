import 'package:flutter/material.dart';

import '../tokens/wms_colors.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';

/// `.wms-table__empty` — states the reason and the next step
/// («Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.»). Never a bare
/// «Məlumat yoxdur».
class WmsEmptyState extends StatelessWidget {
  const WmsEmptyState({
    required this.reason,
    this.nextStep,
    this.action,
    this.icon,
    super.key,
  });

  final String reason;
  final String? nextStep;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: WmsSpacing.space6,
        horizontal: WmsSpacing.space4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: c.inkMuted),
            const SizedBox(height: WmsSpacing.space2),
          ],
          Text(
            reason,
            textAlign: TextAlign.center,
            style: WmsTypography.body.copyWith(color: c.inkMuted),
          ),
          if (nextStep != null) ...[
            const SizedBox(height: WmsSpacing.space1),
            Text(
              nextStep!,
              textAlign: TextAlign.center,
              style: WmsTypography.caption.copyWith(color: c.inkMuted),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: WmsSpacing.space3),
            action!,
          ],
        ],
      ),
    );
  }
}
