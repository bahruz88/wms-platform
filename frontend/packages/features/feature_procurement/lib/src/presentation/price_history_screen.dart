import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'procurement_providers.dart';

/// Price history per product (TOR §25): each purchase with its difference
/// against the previous one, so price creep is visible.
class PriceHistoryScreen extends ConsumerStatefulWidget {
  const PriceHistoryScreen({this.productId, super.key});

  final int? productId;

  @override
  ConsumerState<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends ConsumerState<PriceHistoryScreen> {
  int? _productId;

  @override
  void initState() {
    super.initState();
    _productId = widget.productId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final products = ref.watch(productListProvider);
    final productId = _productId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelPriceHistory)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            child: SizedBox(
              width: 360,
              child: WmsSelect<int>(
                label: l10n.labelProduct,
                value: productId,
                placeholder: 'Məhsul seçin',
                options: [
                  for (final p in products.value?.items ?? const <ProductDto>[])
                    WmsSelectOption(value: p.id, label: '${p.sku} · ${p.name}'),
                ],
                onChanged: (value) => setState(() => _productId = value),
              ),
            ),
          ),
          Expanded(
            child: productId == null
                ? const WmsEmptyState(
                    reason: 'Məhsul seçilməyib.',
                    nextStep: 'Qiymət tarixçəsini görmək üçün məhsul seçin.',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      WmsSpacing.space4,
                      0,
                      WmsSpacing.space4,
                      WmsSpacing.space4,
                    ),
                    child: AsyncView<Page<PriceHistoryDto>>(
                      value: ref.watch(priceHistoryProvider(productId)),
                      onRetry: () =>
                          ref.invalidate(priceHistoryProvider(productId)),
                      builder: (page) => WmsDataTable<PriceHistoryDto>(
                        rowKey: (row, _) => row.id,
                        emptyReason: 'Bu məhsul üzrə qiymət tarixçəsi yoxdur.',
                        emptyNextStep:
                            'İlk PO təsdiqləndikdən sonra görünəcək.',
                        columns: [
                          WmsColumn(
                            key: 'date',
                            header: l10n.labelDate,
                            width: 120,
                            cell: (row) => WmsFormat.date(row.priceDate),
                          ),
                          WmsColumn(
                            key: 'supplier',
                            header: l10n.labelSupplier,
                            flex: 3,
                            cell: (row) =>
                                row.supplierName ?? '#${row.supplierId}',
                          ),
                          WmsColumn(
                            key: 'poNo',
                            header: 'PO',
                            flex: 2,
                            render: (row, _) => Text(
                              row.poDocNo ?? '—',
                              style: WmsTypography.docNo.copyWith(color: c.ink),
                            ),
                          ),
                          WmsColumn(
                            key: 'price',
                            header: 'Qiymət',
                            numeric: true,
                            cell: (row) => WmsFormat.money(row.unitPrice),
                          ),
                          WmsColumn(
                            key: 'priceBase',
                            header: 'Qiymət (AZN)',
                            numeric: true,
                            cell: (row) => WmsFormat.money(row.unitPriceBase),
                          ),
                          WmsColumn(
                            key: 'diff',
                            header: 'Fərq',
                            numeric: true,
                            render: (row, _) {
                              final diff = row.diffPct;
                              if (diff == null) {
                                return Text(
                                  '—',
                                  textAlign: TextAlign.right,
                                  style: WmsTypography.figure.copyWith(
                                    color: c.inkMuted,
                                  ),
                                );
                              }
                              final rising = diff > Decimal.zero;
                              return Text(
                                WmsFormat.percent(diff, withSign: true),
                                textAlign: TextAlign.right,
                                style: WmsTypography.figure.copyWith(
                                  color: rising ? c.danger : c.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
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
