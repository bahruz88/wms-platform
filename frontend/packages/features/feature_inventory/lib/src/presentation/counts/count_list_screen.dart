import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../navigation.dart';
import '../inventory_providers.dart';

/// Inventory count list (`IC-YYYY-00000`).
class CountListScreen extends ConsumerWidget {
  const CountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final counts = ref.watch(countListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docCount)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<CountDto>>(
          value: counts,
          onRetry: () => ref.invalidate(countListProvider),
          builder: (page) => WmsDataTable<CountDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Sayım sənədi yoxdur.',
            emptyNextStep: 'Yeni sayım yaradın və lokasiyanı dondurun.',
            onRowTap: (row, _) =>
                context.go(InventoryRoutes.countDetail(row.id)),
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
                key: 'location',
                header: l10n.labelLocation,
                flex: 3,
                cell: (row) => row.locationName ?? '#${row.locationId}',
              ),
              WmsColumn(
                key: 'type',
                header: 'Tip',
                width: 120,
                cell: (row) => row.countType.wire,
              ),
              WmsColumn(
                key: 'frozenAt',
                header: 'Dondurulub',
                width: 160,
                cell: (row) => WmsFormat.dateTime(row.frozenAt),
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
