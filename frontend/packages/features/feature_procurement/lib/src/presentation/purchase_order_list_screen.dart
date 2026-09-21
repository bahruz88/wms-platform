import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../navigation.dart';
import 'procurement_providers.dart';

/// Purchase order list (`PO-YYYY-00000`).
class PurchaseOrderListScreen extends ConsumerWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final orders = ref.watch(purchaseOrderListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docPurchaseOrderLong)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<PurchaseOrderDto>>(
          value: orders,
          onRetry: () => ref.invalidate(purchaseOrderListProvider),
          builder: (page) => WmsDataTable<PurchaseOrderDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Satınalma sifarişi yoxdur.',
            emptyNextStep: 'Seçilmiş təklifdən PO yaradın.',
            onRowTap: (row, _) =>
                context.go(ProcurementRoutes.purchaseOrderDetail(row.id)),
            columns: [
              WmsColumn(
                key: 'docNo',
                header: 'Sənəd',
                flex: 2,
                render: (row, _) => Text(
                  row.docNo,
                  style: WmsTypography.docNo.copyWith(color: c.ink),
                ),
              ),
              WmsColumn(
                key: 'date',
                header: l10n.labelDate,
                width: 120,
                cell: (row) => WmsFormat.date(row.docDate),
              ),
              WmsColumn(
                key: 'supplier',
                header: l10n.labelSupplier,
                flex: 3,
                cell: (row) => row.supplierName ?? '#${row.supplierId}',
              ),
              WmsColumn(
                key: 'total',
                header: 'Məbləğ',
                numeric: true,
                cell: (row) => WmsFormat.money(row.totalAmount),
              ),
              WmsColumn(
                key: 'totalBase',
                header: 'Məbləğ (AZN)',
                numeric: true,
                cell: (row) => WmsFormat.money(row.totalAmountBase),
              ),
              WmsColumn(
                key: 'expected',
                header: 'Gözlənilir',
                width: 130,
                cell: (row) => WmsFormat.date(row.expectedDate),
              ),
              WmsColumn(
                key: 'status',
                header: l10n.labelStatus,
                width: 190,
                render: (row, _) => WmsDocStatusBadge(status: row.status.wire),
              ),
            ],
            rows: page.items,
          ),
        ),
      ),
    );
  }
}
