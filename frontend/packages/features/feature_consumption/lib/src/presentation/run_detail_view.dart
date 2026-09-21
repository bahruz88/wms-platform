import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'consumption_providers.dart';

/// One consumption document, shown the same way to the branch and to the
/// manager: theoretical against posted per product, the shortfall spelled
/// out, and the double-entry lines of the movement group underneath.
class ConsumptionRunDetailView extends ConsumerWidget {
  const ConsumptionRunDetailView({required this.runId, super.key});

  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(consumptionRunProvider(runId));
    return AsyncView<ConsumptionRunDetailDto>(
      value: detail,
      onRetry: () => ref.invalidate(consumptionRunProvider(runId)),
      builder: (run) => _RunBody(run: run),
    );
  }
}

class _RunBody extends ConsumerWidget {
  const _RunBody({required this.run});

  final ConsumptionRunDetailDto run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final canSeeCost = ref.hasPermission(Permissions.productViewCost);

    return ListView(
      padding: const EdgeInsets.all(WmsSpacing.space4),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                run.docNo,
                style: WmsTypography.titleLg.copyWith(color: c.ink),
              ),
            ),
            WmsDocStatusBadge(status: run.status.wire),
          ],
        ),
        const SizedBox(height: WmsSpacing.space1),
        Text(
          '${WmsFormat.date(run.businessDate)}'
          ' · ${run.locationName ?? '#${run.locationId}'}',
          style: WmsTypography.body.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: WmsSpacing.space4),

        // A shortfall is a warning, not an error: the stock simply ran out.
        // The message names the likely cause so nobody has to guess.
        if (run.hasShortfall) ...[
          WmsAlert(
            key: const ValueKey('cons-shortfall-alert'),
            tone: WmsAlertTone.warning,
            title: l10n.consShortfallTitle,
            message: l10n.consShortfallExplained,
            child: _ShortfallList(lines: run.shortfallLines),
          ),
          const SizedBox(height: WmsSpacing.space3),
        ],
        if (run.hasUnmapped) ...[
          WmsAlert(
            key: const ValueKey('cons-unmapped-run-alert'),
            title: '${run.unmappedCount} sətir · ${l10n.consUnmappedTitle}',
            message: l10n.consUnmappedExplained,
          ),
          const SizedBox(height: WmsSpacing.space3),
        ],
        if (run.failureReason != null) ...[
          WmsAlert(
            tone: WmsAlertTone.danger,
            title: 'Hesablama uğursuz oldu',
            message: run.failureReason,
            code: run.status.wire,
          ),
          const SizedBox(height: WmsSpacing.space3),
        ],

        WmsDataTable<ConsumptionRunLineDto>(
          caption: '${l10n.consLabelTheoretical} / ${l10n.consLabelPosted}',
          rowKey: (row, _) => row.productId,
          minWidth: 620,
          permissions: {if (canSeeCost) Permissions.productViewCost},
          emptyReason: 'Bu sənəddə məhsul sətri yoxdur.',
          emptyNextStep:
              'Satış sətirlərinin resepti yoxdursa nəzəri məxaric yaranmır.',
          columns: [
            WmsColumn(
              key: 'product',
              header: l10n.labelProduct,
              flex: 3,
              render: (row, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.label,
                    style: WmsTypography.bodyStrong.copyWith(color: c.ink),
                  ),
                  if (row.productSku != null)
                    Text(
                      row.productSku!,
                      style: WmsTypography.docNo.copyWith(color: c.inkMuted),
                    ),
                ],
              ),
            ),
            WmsColumn(
              key: 'theoretical',
              header: l10n.consLabelTheoretical,
              flex: 2,
              numeric: true,
              cell: (row) => WmsFormat.quantity(row.theoreticalQtyBase),
            ),
            WmsColumn(
              key: 'posted',
              header: l10n.consLabelPosted,
              flex: 2,
              numeric: true,
              cell: (row) => WmsFormat.quantity(row.postedQtyBase),
            ),
            WmsColumn(
              key: 'shortfall',
              header: l10n.consLabelShortfall,
              flex: 2,
              numeric: true,
              render: (row, _) => Text(
                WmsFormat.quantity(row.shortfallQtyBase),
                key: ValueKey('cons-shortfall-${row.productId}'),
                textAlign: TextAlign.right,
                style: WmsTypography.figure.copyWith(
                  color: row.hasShortfall ? c.warning : c.inkMuted,
                  fontWeight: row.hasShortfall
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            WmsColumn(
              key: 'uom',
              header: 'Vahid',
              width: 70,
              cell: (row) => row.baseUomCode ?? '',
            ),
            WmsColumn(
              key: 'cost',
              header: 'Maya',
              flex: 2,
              numeric: true,
              permission: Permissions.productViewCost,
              cell: (row) => WmsFormat.money(row.costAmount),
            ),
          ],
          rows: run.lines,
        ),
        const SizedBox(height: WmsSpacing.space4),

        // The document itself: RESTAURANT −qty / V_CONSUMPTION +qty.
        if (run.status.isPosted)
          WmsLedgerTable(
            label: 'Hərəkət qrupu · ${DocType.consumption.wire}',
            showCost: canSeeCost,
            lines: buildConsumptionLedgerLines(
              run,
              branchName: run.locationName ?? '#${run.locationId}',
            ),
          )
        else
          const WmsEmptyState(
            reason: 'Sənəd hələ post edilməyib.',
            nextStep: 'Post edildikdən sonra hərəkət sətirləri burada görünür.',
            icon: Icons.pending_outlined,
          ),
      ],
    );
  }
}

/// The double-entry lines behind a posted consumption document: every
/// product leaves the branch and lands in `V_CONSUMPTION`, so the group
/// sums to zero (ADR-003). Lines with nothing posted are skipped — they
/// would be zero rows in the ledger.
List<WmsLedgerLine> buildConsumptionLedgerLines(
  ConsumptionRunDetailDto run, {
  required String branchName,
}) {
  final lines = <WmsLedgerLine>[];
  var lineNo = 1;
  for (final line in run.lines) {
    if (line.postedQtyBase.isZero) continue;
    lines
      ..add(
        WmsLedgerLine(
          lineNo: lineNo++,
          product: line.label,
          sku: line.productSku,
          location: branchName,
          locationType: LocationType.restaurant,
          qtyBase: -line.postedQtyBase,
          uom: line.baseUomCode,
          unitCost: line.unitCost,
        ),
      )
      ..add(
        WmsLedgerLine(
          lineNo: lineNo++,
          product: line.label,
          sku: line.productSku,
          location: 'İstehlak',
          locationType: LocationType.vConsumption,
          qtyBase: line.postedQtyBase,
          uom: line.baseUomCode,
          unitCost: line.unitCost,
        ),
      );
  }
  return lines;
}

class _ShortfallList extends StatelessWidget {
  const _ShortfallList({required this.lines});

  final List<ConsumptionRunLineDto> lines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final line in lines)
        Text(
          '${line.label}: '
          '${WmsFormat.quantity(line.shortfallQtyBase)}'
          '${line.baseUomCode == null ? '' : ' ${line.baseUomCode}'}',
        ),
    ],
  );
}
