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

/// RFQ list; tapping a row opens the quotation comparison.
class RfqListScreen extends ConsumerWidget {
  const RfqListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final rfqs = ref.watch(rfqListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docRfq)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<RfqDto>>(
          value: rfqs,
          onRetry: () => ref.invalidate(rfqListProvider),
          builder: (page) => WmsDataTable<RfqDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'RFQ sənədi yoxdur.',
            emptyNextStep: 'Təsdiqlənmiş PR-lardan RFQ yaradın.',
            onRowTap: (row, _) =>
                context.go(ProcurementRoutes.quotationComparison(row.id)),
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
                key: 'dueDate',
                header: 'Son tarix',
                width: 120,
                cell: (row) => WmsFormat.date(row.dueDate),
              ),
              WmsColumn(
                key: 'quotes',
                header: 'Təkliflər',
                width: 120,
                numeric: true,
                cell: (row) => '${row.quotationCount}',
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
