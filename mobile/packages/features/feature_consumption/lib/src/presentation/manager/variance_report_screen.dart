import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../consumption_providers.dart';
import '../date_field.dart';

/// «Fərq hesabatı» — theoretical against actual consumption, per product
/// and location, for the period between two counts.
///
/// `expected = opening + received − theoretical − waste − sample ± transfer`
/// and `variance = counted − expected`. Every quantity column carries its
/// sign, because a variance of «12» means nothing until you know whether
/// twelve kilos appeared or disappeared.
///
/// The money column exists only for holders of `master.product.view_cost`:
/// `WmsDataTable` drops a permission-gated column entirely — it is never
/// blanked or masked.
class VarianceReportScreen extends ConsumerWidget {
  const VarianceReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consVarianceReport)),
      body: RequirePermission.withNotice(
        permission: Permissions.varianceView,
        child: ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: const [
            _Filters(),
            SizedBox(height: WmsSpacing.space4),
            _VarianceTable(),
            SizedBox(height: WmsSpacing.space6),
            _PortionCompliance(),
          ],
        ),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(varianceFilterProvider);
    final notifier = ref.read(varianceFilterProvider.notifier);
    final locations = ref.watch(locationListProvider).value ?? const [];

    return Wrap(
      spacing: WmsSpacing.space4,
      runSpacing: WmsSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 210,
          child: ConsumptionDateField(
            label: l10n.consLabelPeriodFrom,
            value: filter.periodFrom,
            hint: 'Adətən əvvəlki sayımın tarixi',
            onChanged: (value) => notifier.setPeriod(value, filter.periodTo),
          ),
        ),
        SizedBox(
          width: 210,
          child: ConsumptionDateField(
            label: l10n.consLabelPeriodTo,
            value: filter.periodTo,
            hint: 'Adətən son sayımın tarixi',
            onChanged: (value) => notifier.setPeriod(filter.periodFrom, value),
          ),
        ),
        SizedBox(
          width: 280,
          child: WmsSelect<int>(
            label: l10n.labelLocation,
            value: filter.locationId,
            placeholder: l10n.labelAll,
            options: [
              for (final location in locations)
                if (!location.isVirtual)
                  WmsSelectOption(
                    value: location.id,
                    label: '${location.code} · ${location.name}',
                  ),
            ],
            onChanged: notifier.setLocation,
          ),
        ),
      ],
    );
  }
}

class _VarianceTable extends ConsumerWidget {
  const _VarianceTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final filter = ref.watch(varianceFilterProvider);
    if (!filter.isValid) {
      return const WmsAlert(
        tone: WmsAlertTone.warning,
        title: 'Dövr tərsinə seçilib',
        message: 'Başlanğıc tarixi son tarixdən sonra ola bilməz.',
      );
    }
    final canSeeCost = ref.hasPermission(Permissions.productViewCost);
    final report = ref.watch(varianceReportProvider);

    return AsyncView<ConsumptionVariancePageDto>(
      value: report,
      onRetry: () => ref.invalidate(varianceReportProvider),
      builder: (data) => WmsDataTable<ConsumptionVarianceLineDto>(
        caption:
            '${WmsFormat.date(data.periodFrom)} — '
            '${WmsFormat.date(data.periodTo)}',
        rowKey: (row, _) => '${row.productId}-${row.locationId}',
        minWidth: 1180,
        permissions: {if (canSeeCost) Permissions.productViewCost},
        emptyReason: l10n.consEmptyVarianceReason,
        emptyNextStep: l10n.consEmptyVarianceNext,
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
            key: 'location',
            header: l10n.labelLocation,
            flex: 2,
            cell: (row) => row.locationName ?? '#${row.locationId}',
          ),
          WmsColumn(
            key: 'opening',
            header: l10n.consLabelOpening,
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.quantity(row.openingQty),
          ),
          WmsColumn(
            key: 'received',
            header: l10n.labelReceived,
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.signedQuantity(row.receivedQty),
          ),
          WmsColumn(
            key: 'theoretical',
            header: l10n.consLabelTheoretical,
            flex: 2,
            numeric: true,
            cell: (row) =>
                WmsFormat.signedQuantity(-row.theoreticalConsumedQty),
          ),
          WmsColumn(
            key: 'waste',
            header: 'Tullantı',
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.signedQuantity(-row.wasteQty),
          ),
          WmsColumn(
            key: 'transfer',
            header: 'Transfer',
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.signedQuantity(row.transferNetQty),
          ),
          WmsColumn(
            key: 'expected',
            header: l10n.consLabelExpected,
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.quantity(row.expectedQty),
          ),
          WmsColumn(
            key: 'counted',
            header: l10n.labelCounted,
            flex: 2,
            numeric: true,
            cell: (row) => WmsFormat.quantity(row.countedQty),
          ),
          WmsColumn(
            key: 'variance',
            header: l10n.labelVariance,
            flex: 2,
            numeric: true,
            render: (row, _) => Text(
              WmsFormat.signedQuantity(row.varianceQty),
              key: ValueKey('cons-variance-${row.productId}-${row.locationId}'),
              textAlign: TextAlign.right,
              style: WmsTypography.figure.copyWith(
                color: row.isZero
                    ? c.inkMuted
                    : (row.isShort ? c.ledgerOut : c.ledgerIn),
                fontWeight: row.isZero ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
          WmsColumn(
            key: 'variancePct',
            header: '%',
            width: 110,
            numeric: true,
            cell: (row) => WmsFormat.percent(row.variancePct, withSign: true),
          ),
          WmsColumn(
            key: 'uom',
            header: 'Vahid',
            width: 70,
            cell: (row) => row.baseUomCode ?? '',
          ),
          // Rendered only with `master.product.view_cost` — never masked.
          WmsColumn(
            key: 'varianceValue',
            header: 'Dəyər',
            flex: 2,
            numeric: true,
            permission: Permissions.productViewCost,
            cell: (row) => row.varianceValue == null
                ? ''
                : WmsFormat.signed(row.varianceValue!.amount, decimals: 2),
          ),
        ],
        rows: data.items,
      ),
    );
  }
}

class _PortionCompliance extends ConsumerWidget {
  const _PortionCompliance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final compliance = ref.watch(portionComplianceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.consLabelCompliancePct,
          style: WmsTypography.title.copyWith(color: c.ink),
        ),
        const SizedBox(height: WmsSpacing.space3),
        AsyncView<Page<PortionComplianceLineDto>>(
          value: compliance,
          onRetry: () => ref.invalidate(portionComplianceProvider),
          builder: (page) => WmsDataTable<PortionComplianceLineDto>(
            rowKey: (row, _) => '${row.menuItemId}-${row.productId}',
            minWidth: 900,
            emptyReason: l10n.consEmptyVarianceReason,
            emptyNextStep: l10n.consEmptyVarianceNext,
            columns: [
              WmsColumn(
                key: 'menuItem',
                header: l10n.consLabelMenuItem,
                flex: 3,
                cell: (row) => row.menuItemName ?? '#${row.menuItemId}',
              ),
              WmsColumn(
                key: 'product',
                header: l10n.labelProduct,
                flex: 3,
                cell: (row) => row.productName ?? '#${row.productId}',
              ),
              WmsColumn(
                key: 'portions',
                header: l10n.consLabelPortions,
                flex: 2,
                numeric: true,
                cell: (row) =>
                    WmsFormat.quantity(row.portionsSold, decimals: 0),
              ),
              WmsColumn(
                key: 'recipe',
                header: l10n.consLabelQtyPerPortion,
                flex: 2,
                numeric: true,
                cell: (row) => WmsFormat.quantity(row.recipeQtyPerPortion),
              ),
              WmsColumn(
                key: 'actual',
                header: 'Faktiki',
                flex: 2,
                numeric: true,
                cell: (row) => WmsFormat.quantity(row.actualQtyPerPortion),
              ),
              WmsColumn(
                key: 'compliance',
                header: l10n.consLabelCompliancePct,
                width: 140,
                numeric: true,
                render: (row, _) => Text(
                  WmsFormat.percent(row.compliancePct),
                  textAlign: TextAlign.right,
                  style: WmsTypography.figure.copyWith(
                    color: row.isOverPortioned ? c.warning : c.ink,
                    fontWeight: row.isOverPortioned
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
            ],
            rows: page.items,
          ),
        ),
      ],
    );
  }
}
