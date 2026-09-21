import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'async_view.dart';
import 'master_data_providers.dart';

/// Units of measure with their decimal precision (drives quantity display).
class UomListScreen extends ConsumerWidget {
  const UomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final uoms = ref.watch(uomListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelUoms)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<List<UomDto>>(
          value: uoms,
          onRetry: () => ref.invalidate(uomListProvider),
          builder: (items) => WmsDataTable<UomDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Ölçü vahidi siyahısı boşdur.',
            emptyNextStep: 'Master data bölməsində vahid əlavə edin.',
            columns: [
              WmsColumn(
                key: 'code',
                header: 'Kod',
                width: 120,
                render: (row, _) => Text(
                  row.code,
                  style: WmsTypography.docNo.copyWith(
                    color: WmsColors.of(context).ink,
                  ),
                ),
              ),
              WmsColumn(
                key: 'name',
                header: 'Ad',
                flex: 3,
                cell: (row) => row.name,
              ),
              WmsColumn(
                key: 'class',
                header: 'Sinif',
                width: 120,
                cell: (row) => row.uomClass.wire,
              ),
              WmsColumn(
                key: 'decimals',
                header: 'Onluq',
                width: 90,
                numeric: true,
                cell: (row) => '${row.decimals}',
              ),
            ],
            rows: items,
          ),
        ),
      ),
    );
  }
}
