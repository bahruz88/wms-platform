import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_badge.dart';
import 'wms_data_table.dart';

/// One `inv_movement` line.
@immutable
class WmsLedgerLine {
  const WmsLedgerLine({
    required this.lineNo,
    required this.product,
    required this.location,
    required this.qtyBase,
    this.sku,
    this.batchNo,
    this.locationType,
    this.uom,
    this.unitCost,
  });

  final int lineNo;
  final String product;
  final String? sku;
  final String? batchNo;
  final String location;
  final LocationType? locationType;

  /// Signed base quantity: `+` inbound, `−` outbound.
  final Quantity qtyBase;
  final String? uom;
  final Money? unitCost;

  bool get isVirtual => locationType?.isVirtual ?? false;
}

/// `.wms-ledger` — double-entry lines of one movement group. The sign is
/// always visible (colour is secondary), virtual locations get a `virtual`
/// badge, and the zero-sum check row is always shown. No edit button:
/// corrections are `REVERSAL` groups.
class WmsLedgerTable extends StatelessWidget {
  const WmsLedgerTable({
    required this.lines,
    this.decimals = 4,
    this.showCost = false,
    this.showBalanceCheck = true,
    this.label,
    super.key,
  });

  final List<WmsLedgerLine> lines;
  final int decimals;

  /// Only when the user has `master.product.view_cost`.
  final bool showCost;
  final bool showBalanceCheck;
  final String? label;

  static const String balancedText = 'Cəm: 0 — sənəd balanslaşıb';

  Quantity get total => lines.fold(Quantity.zero, (sum, l) => sum + l.qtyBase);

  bool get isBalanced => total.isZero;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final permissions = {if (showCost) Permissions.productViewCost};
    final columns = <WmsColumn<WmsLedgerLine>>[
      WmsColumn(
        key: 'lineNo',
        header: '№',
        width: 44,
        cell: (l) => '${l.lineNo}',
        align: WmsColumnAlign.right,
      ),
      WmsColumn(
        key: 'product',
        header: 'Məhsul',
        flex: 3,
        render: (l, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.product,
              style: WmsTypography.bodyStrong.copyWith(color: c.ink),
            ),
            if (l.sku != null)
              Text(
                l.sku!,
                style: WmsTypography.docNo.copyWith(color: c.inkMuted),
              ),
          ],
        ),
      ),
      WmsColumn(
        key: 'batch',
        header: 'Partiya',
        flex: 2,
        render: (l, _) => Text(
          l.batchNo ?? '—',
          style: WmsTypography.docNo.copyWith(color: c.ink),
        ),
      ),
      WmsColumn(
        key: 'location',
        header: 'Lokasiya',
        flex: 3,
        render: (l, _) => Wrap(
          spacing: WmsSpacing.space2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l.location, style: WmsTypography.body.copyWith(color: c.ink)),
            if (l.isVirtual)
              WmsBadge(
                text: l.locationType!.wire,
                tone: WmsTone.virtual,
                tooltip: 'Virtual lokasiya',
              ),
          ],
        ),
      ),
      WmsColumn(
        key: 'qty',
        header: 'Miqdar',
        flex: 2,
        numeric: true,
        render: (l, _) => Text(
          WmsFormat.signedQuantity(l.qtyBase, decimals: decimals),
          textAlign: TextAlign.right,
          style: WmsTypography.figure.copyWith(
            color: l.qtyBase.isNegative
                ? c.ledgerOut
                : (l.qtyBase.isPositive ? c.ledgerIn : c.inkMuted),
          ),
        ),
      ),
      WmsColumn(
        key: 'uom',
        header: 'Vahid',
        width: 64,
        cell: (l) => l.uom ?? '',
      ),
      WmsColumn(
        key: 'cost',
        header: 'Maya',
        flex: 2,
        numeric: true,
        permission: Permissions.productViewCost,
        cell: (l) => WmsFormat.money(l.unitCost),
      ),
    ];

    final sum = total;
    final balanced = sum.isZero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        WmsDataTable<WmsLedgerLine>(
          columns: columns,
          rows: lines,
          permissions: permissions,
          caption: label,
          rowKey: (l, _) => l.lineNo,
          emptyReason: 'Bu qrupda hərəkət sətri yoxdur.',
          emptyNextStep: 'Sənəd post edildikdən sonra sətirlər burada görünür.',
        ),
        if (showBalanceCheck)
          Container(
            key: const ValueKey('wms-ledger-check'),
            padding: const EdgeInsets.symmetric(
              vertical: WmsSpacing.space2,
              horizontal: WmsSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              border: Border(top: BorderSide(color: c.borderControl)),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(WmsRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  balanced ? Icons.check_circle_outline : Icons.error_outline,
                  size: 16,
                  color: balanced ? c.success : c.danger,
                ),
                const SizedBox(width: WmsSpacing.space2),
                Expanded(
                  child: Text(
                    balanced
                        ? balancedText
                        : 'Cəm: ${WmsFormat.signedQuantity(sum, decimals: decimals)} — sıfır deyil, sənəd post edilə bilməz',
                    style: WmsTypography.caption.copyWith(
                      color: balanced ? c.success : c.danger,
                      fontWeight: balanced ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
