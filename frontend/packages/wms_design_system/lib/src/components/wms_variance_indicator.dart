import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_badge.dart';

/// `.wms-variance` — counted vs book difference with its percentage and the
/// procedure it triggers.
///
/// * the difference is always signed (`+6,000` / `−2 600,000`);
/// * above [thresholdPct] an «Təsdiq tələb edir» badge appears (the document
///   cannot be posted directly, `inv.adjustment.approve` is required);
/// * a non-zero variance without [reasonCode] shows «Səbəb kodu yoxdur»;
/// * zero variance is neutral, never green — it is the expected outcome;
/// * `book == 0` counts as 100% and always requires approval.
class WmsVarianceIndicator extends StatelessWidget {
  const WmsVarianceIndicator({
    required this.book,
    required this.counted,
    this.uom,
    this.decimals = 3,
    this.thresholdPct,
    this.reasonCode,
    super.key,
  });

  final Quantity book;
  final Quantity counted;
  final String? uom;
  final int decimals;

  /// `inv_setting.count_variance_approval_threshold_pct`.
  final Decimal? thresholdPct;

  /// Selected `reason_code_id` label; `null`/empty means "not chosen".
  final String? reasonCode;

  static const String approvalText = 'Təsdiq tələb edir';
  static const String missingReasonText = 'Səbəb kodu yoxdur';

  Quantity get variance => counted - book;

  bool get isZero => variance.isZero;

  /// Percentage of the book quantity; 100% when the book quantity is zero
  /// (stock counted that the system does not know about).
  Decimal? get variancePct {
    if (isZero) return Decimal.zero;
    if (book.isZero) return Decimal.fromInt(100);
    return counted.variancePctFrom(book);
  }

  bool get requiresApproval {
    if (isZero) return false;
    if (book.isZero) return true;
    final threshold = thresholdPct;
    final pct = variancePct;
    if (threshold == null || pct == null) return false;
    return pct.abs() > threshold;
  }

  bool get missingReason =>
      !isZero && (reasonCode == null || reasonCode!.isEmpty);

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final color = isZero
        ? c.inkMuted
        : (variance.isNegative ? c.danger : c.success);
    return Wrap(
      spacing: WmsSpacing.space2,
      runSpacing: WmsSpacing.space1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${WmsFormat.signedQuantity(variance, decimals: decimals)}'
          '${uom == null ? '' : ' $uom'}',
          style: WmsTypography.figure.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          WmsFormat.percent(variancePct, withSign: !isZero),
          style: WmsTypography.figureSm.copyWith(color: c.inkMuted),
        ),
        if (requiresApproval)
          const WmsBadge(
            text: approvalText,
            tone: WmsTone.warning,
            icon: Icons.schedule_outlined,
          ),
        if (missingReason)
          const WmsBadge(
            text: missingReasonText,
            tone: WmsTone.danger,
            icon: Icons.error_outline,
          ),
      ],
    );
  }
}
