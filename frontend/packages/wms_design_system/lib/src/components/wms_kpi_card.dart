import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';

/// Direction of a KPI delta. Automatic colouring is not always right — a
/// falling waste figure is good — so the caller can override it.
enum WmsDeltaTone { up, down, flat }

/// `.wms-kpi` — one dashboard figure with its unit and context.
///
/// * [label] says *what* is measured, the unit goes to [unit];
/// * a [delta] without [hint] is meaningless, so [hint] is required with it
///   (asserted);
/// * money KPIs are bound to `master.product.view_cost`: when the permission
///   is missing do not render the card at all (see [WmsKpiCard.permitted]).
class WmsKpiCard extends StatelessWidget {
  const WmsKpiCard({
    required this.label,
    required this.value,
    this.decimals = 0,
    this.unit,
    this.delta,
    this.deltaUnit = '%',
    this.deltaDecimals = 1,
    this.deltaTone,
    this.badge,
    this.hint,
    this.onTap,
    super.key,
  }) : assert(
         delta == null || hint != null,
         'a delta without a comparison base (hint) is meaningless',
       );

  /// Convenience for permission-gated (money) KPIs: returns `null` when the
  /// permission is missing, so the card is not rendered at all.
  static Widget? permitted({
    required bool hasPermission,
    required Widget Function() build,
  }) => hasPermission ? build() : null;

  final String label;

  /// Already-formatted text or a [Decimal] to be formatted with [decimals].
  final Object value;
  final int decimals;
  final String? unit;
  final Decimal? delta;
  final String deltaUnit;
  final int deltaDecimals;
  final WmsDeltaTone? deltaTone;
  final Widget? badge;
  final String? hint;
  final VoidCallback? onTap;

  WmsDeltaTone get effectiveDeltaTone {
    final override = deltaTone;
    if (override != null) return override;
    final d = delta;
    if (d == null || d == Decimal.zero) return WmsDeltaTone.flat;
    return d > Decimal.zero ? WmsDeltaTone.up : WmsDeltaTone.down;
  }

  String get valueText => switch (value) {
    final Decimal d => WmsFormat.number(d, decimals: decimals),
    final Object v => v.toString(),
  };

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final deltaColor = switch (effectiveDeltaTone) {
      WmsDeltaTone.up => c.success,
      WmsDeltaTone.down => c.danger,
      WmsDeltaTone.flat => c.inkMuted,
    };

    final card = Container(
      padding: WmsSpacing.cardPadding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.lgAll,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: WmsTypography.label.copyWith(color: c.inkMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?badge,
            ],
          ),
          const SizedBox(height: WmsSpacing.space1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  valueText,
                  style: WmsTypography.figureLg.copyWith(color: c.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: WmsSpacing.space1),
                Text(
                  unit!,
                  style: WmsTypography.bodyStrong.copyWith(
                    fontSize: 13,
                    color: c.inkMuted,
                  ),
                ),
              ],
            ],
          ),
          if (delta != null || hint != null) ...[
            const SizedBox(height: WmsSpacing.space1),
            Row(
              children: [
                if (delta != null) ...[
                  Text(
                    '${WmsFormat.signed(delta, decimals: deltaDecimals)} $deltaUnit',
                    style: WmsTypography.figureSm.copyWith(
                      color: deltaColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: WmsSpacing.space2),
                ],
                if (hint != null)
                  Expanded(
                    child: Text(
                      hint!,
                      style: WmsTypography.caption.copyWith(color: c.inkMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: WmsRadius.lgAll,
      hoverColor: c.rowHover,
      child: card,
    );
  }
}
