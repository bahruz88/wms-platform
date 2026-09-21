import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../navigation.dart';
import 'async_view.dart';
import 'master_data_providers.dart';

/// Product list. The cost column is declared with its permission, so
/// `WmsDataTable` drops it entirely for users without
/// `master.product.view_cost` (spec §16).
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final products = ref.watch(productListProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelProducts)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            child: WmsTextField(
              label: l10n.actionSearch,
              placeholder: 'SKU və ya ad',
              onChanged: (value) =>
                  ref.read(productSearchProvider.notifier).setSearch(value),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                WmsSpacing.space4,
                0,
                WmsSpacing.space4,
                WmsSpacing.space4,
              ),
              child: AsyncView<Page<ProductDto>>(
                value: products,
                onRetry: () => ref.read(productListProvider.notifier).refresh(),
                builder: (page) => WmsDataTable<ProductDto>(
                  permissions: permissions,
                  rowKey: (row, _) => row.id,
                  emptyReason: 'Axtarışa uyğun məhsul tapılmadı.',
                  emptyNextStep: 'Filtri dəyişin və ya yeni məhsul yaradın.',
                  onRowTap: (row, _) =>
                      context.go(MasterDataRoutes.productDetail(row.id)),
                  columns: [
                    WmsColumn(
                      key: 'sku',
                      header: 'SKU',
                      flex: 2,
                      render: (row, _) => Text(
                        row.sku,
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
                      key: 'uom',
                      header: 'Base UoM',
                      width: 96,
                      cell: (row) => row.baseUomCode ?? '',
                    ),
                    WmsColumn(
                      key: 'minStock',
                      header: 'Min. qalıq',
                      numeric: true,
                      cell: (row) =>
                          WmsFormat.quantity(row.minStock, decimals: 3),
                    ),
                    WmsColumn(
                      key: 'cost',
                      header: 'Orta maya',
                      numeric: true,
                      permission: Permissions.productViewCost,
                      cell: (row) => WmsFormat.money(row.avgUnitCost),
                    ),
                    WmsColumn(
                      key: 'status',
                      header: l10n.labelStatus,
                      width: 120,
                      render: (row, _) => WmsDocStatusBadge(
                        status: row.isActive ? 'ACTIVE' : 'CLOSED',
                        label: row.isActive ? 'Aktiv' : 'Deaktiv',
                      ),
                    ),
                  ],
                  rows: page.items,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
