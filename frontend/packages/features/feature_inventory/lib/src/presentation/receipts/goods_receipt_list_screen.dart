import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../navigation.dart';
import '../inventory_providers.dart';

/// Goods receipt list (`GR-YYYY-00000`).
class GoodsReceiptListScreen extends ConsumerWidget {
  const GoodsReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final receipts = ref.watch(goodsReceiptListProvider);
    final canCreate = ref.watch(
      hasPermissionProvider(Permissions.receiptCreate),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.docReceipt),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: WmsSpacing.space3),
            child: WmsButton.primary(
              label: l10n.actionCreate,
              size: WmsButtonSize.sm,
              iconLeft: Icons.add,
              enabled: canCreate,
              disabledReason: l10n.labelNoPermission,
              onPressed: () =>
                  context.go(InventoryRoutes.receiptCreateFullPath),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<GoodsReceiptDto>>(
          value: receipts,
          onRetry: () => ref.invalidate(goodsReceiptListProvider),
          builder: (page) => WmsDataTable<GoodsReceiptDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Hələ qəbul sənədi yoxdur.',
            emptyNextStep: 'Təchizatçıdan mal gələndə yeni qəbul yaradın.',
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
                key: 'location',
                header: l10n.labelLocation,
                flex: 2,
                cell: (row) => row.locationName ?? '#${row.locationId}',
              ),
              WmsColumn(
                key: 'quality',
                header: 'Keyfiyyət',
                width: 170,
                render: (row, _) =>
                    WmsDocStatusBadge(status: row.qualityStatus.wire),
              ),
              WmsColumn(
                key: 'status',
                header: l10n.labelStatus,
                width: 150,
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
