import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'async_view.dart';
import 'master_data_providers.dart';

/// Supplier list; approved food suppliers are badged (TOR §7).
class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final suppliers = ref.watch(supplierListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelSuppliers)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<SupplierDto>>(
          value: suppliers,
          onRetry: () => ref.invalidate(supplierListProvider),
          builder: (page) => WmsDataTable<SupplierDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Təchizatçı siyahısı boşdur.',
            emptyNextStep: 'Master data bölməsində yeni təchizatçı yaradın.',
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
                flex: 4,
                cell: (row) => row.name,
              ),
              WmsColumn(
                key: 'taxId',
                header: 'VÖEN',
                flex: 2,
                cell: (row) => row.taxId ?? '—',
              ),
              WmsColumn(
                key: 'currency',
                header: 'Valyuta',
                width: 96,
                cell: (row) => row.currency,
              ),
              WmsColumn(
                key: 'food',
                header: 'Qida təchizatçısı',
                width: 170,
                render: (row, _) => row.isApprovedFoodSupplier
                    ? const WmsBadge(text: 'Təsdiqlənib', tone: WmsTone.success)
                    : const WmsBadge(text: 'Təsdiqlənməyib'),
              ),
            ],
            rows: page.items,
          ),
        ),
      ),
    );
  }
}
