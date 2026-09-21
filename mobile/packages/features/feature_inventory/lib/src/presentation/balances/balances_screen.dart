import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Stock balances, filtered by location/product and paged by the server.
///
/// The balance is **read-only everywhere** (design system domain rule): it is
/// a ledger projection and can only change through a document.
class BalancesScreen extends ConsumerWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final balances = ref.watch(balancesProvider);
    final filter = ref.watch(balanceFilterProvider);
    final locations = ref.watch(locationListProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelBalances)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            child: Wrap(
              spacing: WmsSpacing.space3,
              runSpacing: WmsSpacing.space3,
              children: [
                SizedBox(
                  width: 280,
                  child: locations.maybeWhen(
                    data: (items) => WmsSelect<int>(
                      label: l10n.labelLocation,
                      placeholder: l10n.labelAll,
                      value: filter.locationId,
                      hint:
                          'Siyahı sizə təyin edilmiş lokasiyalarla məhdudlaşır',
                      options: [
                        for (final location in items)
                          WmsSelectOption(
                            value: location.id,
                            label: '${location.code} · ${location.name}',
                            enabled: !location.isVirtual,
                            disabledReason: location.isVirtual
                                ? 'virtual lokasiya'
                                : null,
                          ),
                      ],
                      onChanged: (value) => ref
                          .read(balanceFilterProvider.notifier)
                          .setLocation(value),
                    ),
                    orElse: () => WmsSelect<int>(
                      label: l10n.labelLocation,
                      options: const [],
                      enabled: false,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: WmsTextField(
                    label: l10n.actionSearch,
                    placeholder: 'SKU, ad və ya partiya',
                    onChanged: (value) => ref
                        .read(balanceFilterProvider.notifier)
                        .setSearch(value),
                  ),
                ),
              ],
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
              child: AsyncView<Page<BalanceDto>>(
                value: balances,
                onRetry: () => ref.read(balancesProvider.notifier).refresh(),
                builder: (page) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WmsDataTable<BalanceDto>(
                      permissions: permissions,
                      rowKey: (row, _) =>
                          '${row.productId}-${row.locationId}-${row.batchId}',
                      emptyReason: 'Bu lokasiyada qalıq yoxdur.',
                      emptyNextStep: 'Qəbul sənədi yaradın.',
                      columns: [
                        WmsColumn(
                          key: 'sku',
                          header: 'SKU',
                          flex: 2,
                          render: (row, _) => Text(
                            row.productSku ?? '#${row.productId}',
                            style: WmsTypography.docNo.copyWith(color: c.ink),
                          ),
                        ),
                        WmsColumn(
                          key: 'product',
                          header: l10n.labelProduct,
                          flex: 4,
                          cell: (row) => row.productName ?? '',
                        ),
                        WmsColumn(
                          key: 'location',
                          header: l10n.labelLocation,
                          flex: 2,
                          cell: (row) =>
                              row.locationCode ?? '#${row.locationId}',
                        ),
                        WmsColumn(
                          key: 'batch',
                          header: l10n.labelBatchNo,
                          flex: 2,
                          render: (row, _) => Text(
                            row.batchNo ?? '—',
                            style: WmsTypography.docNo.copyWith(color: c.ink),
                          ),
                        ),
                        WmsColumn(
                          key: 'expiry',
                          header: l10n.labelExpiryDate,
                          width: 120,
                          cell: (row) => WmsFormat.date(row.expiryDate),
                        ),
                        WmsColumn(
                          key: 'onHand',
                          header: 'Qalıq',
                          numeric: true,
                          cell: (row) =>
                              WmsFormat.quantity(row.qtyOnHand, decimals: 3),
                        ),
                        WmsColumn(
                          key: 'reserved',
                          header: 'Rezerv',
                          numeric: true,
                          cell: (row) =>
                              WmsFormat.quantity(row.qtyReserved, decimals: 3),
                        ),
                        WmsColumn(
                          key: 'available',
                          header: 'Mövcud',
                          numeric: true,
                          render: (row, _) => Text(
                            WmsFormat.quantity(row.qtyAvailable, decimals: 3),
                            textAlign: TextAlign.right,
                            style: WmsTypography.figure.copyWith(
                              color: c.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        WmsColumn(
                          key: 'uom',
                          header: 'Vahid',
                          width: 80,
                          cell: (row) => row.baseUomCode ?? '',
                        ),
                        // Rendered only with master.product.view_cost.
                        WmsColumn(
                          key: 'value',
                          header: 'Dəyər',
                          numeric: true,
                          permission: Permissions.productViewCost,
                          cell: (row) => WmsFormat.money(row.totalValue),
                        ),
                      ],
                      rows: page.items,
                    ),
                    if (page.totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: WmsSpacing.space3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${page.page} / ${page.totalPages} · ${page.total} sətir',
                              style: WmsTypography.caption.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                            const SizedBox(width: WmsSpacing.space3),
                            WmsButton(
                              label: 'Əvvəlki',
                              size: WmsButtonSize.sm,
                              enabled: page.hasPrevious,
                              disabledReason: 'İlk səhifədəsiniz',
                              onPressed: () => ref
                                  .read(balancesProvider.notifier)
                                  .loadPage(page.page - 1),
                            ),
                            const SizedBox(width: WmsSpacing.space2),
                            WmsButton(
                              label: 'Növbəti',
                              size: WmsButtonSize.sm,
                              enabled: page.hasNext,
                              disabledReason: 'Son səhifədəsiniz',
                              onPressed: () => ref
                                  .read(balancesProvider.notifier)
                                  .loadPage(page.page + 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
