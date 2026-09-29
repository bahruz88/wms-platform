import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_design_system/wms_design_system.dart';

import 'async_view.dart';
import 'master_data_providers.dart';

/// Product detail.
///
/// No cost rows: the master data contract carries no product cost at all. Average cost and last
/// purchase price are reporting figures, and the DTO used to declare them as nullable fields the
/// server never sent, so the block was dead in every case.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WmsColors.of(context);
    final product = ref.watch(productDetailProvider(productId));
    return Scaffold(
      appBar: AppBar(title: const Text('Məhsul')),
      body: AsyncView<ProductDto>(
        value: product,
        onRetry: () => ref.invalidate(productDetailProvider(productId)),
        builder: (data) => ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: [
            Text(
              data.name,
              style: WmsTypography.titleLg.copyWith(color: c.ink),
            ),
            const SizedBox(height: WmsSpacing.space1),
            Text(
              data.sku,
              style: WmsTypography.docNo.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: WmsSpacing.space4),
            _Row(
              label: 'Kateqoriya',
              value: data.categoryLabel,
            ),
            _Row(
              label: 'Base UoM',
              value: data.baseUomCode ?? '#${data.baseUomId}',
            ),
            _Row(label: 'Barkod', value: data.barcode ?? '—', mono: true),
            _Row(label: 'Ayırma strategiyası', value: data.issueStrategy.wire),
            _Row(
              label: 'Partiya tələb olunur',
              value: data.requiresBatch ? 'Bəli' : 'Xeyr',
            ),
            _Row(
              label: 'Expiry tələb olunur',
              value: data.requiresExpiry ? 'Bəli' : 'Xeyr',
            ),
            _Row(
              label: 'Min. qalıq',
              value: WmsFormat.quantity(data.minStock, decimals: 3),
              numeric: true,
            ),
            _Row(
              label: 'Sifariş nöqtəsi',
              value: WmsFormat.quantity(data.reorderPoint, decimals: 3),
              numeric: true,
            ),
            _Row(
              label: 'ƏDV dərəcəsi',
              value: WmsFormat.percent(data.vatRate),
              numeric: true,
            ),
            if (data.uoms.isNotEmpty) ...[
              const SizedBox(height: WmsSpacing.space5),
              WmsDataTable<ProductUomDto>(
                caption: 'Ölçü vahidləri',
                rowKey: (row, _) => row.id,
                emptyReason: 'Alternativ vahid yoxdur.',
                columns: [
                  WmsColumn(
                    key: 'code',
                    header: 'Vahid',
                    cell: (row) => row.uomCode ?? '#${row.uomId}',
                  ),
                  WmsColumn(
                    key: 'factor',
                    header: 'Base-ə əmsal',
                    numeric: true,
                    cell: (row) =>
                        WmsFormat.number(row.factorToBase, decimals: 8),
                  ),
                  WmsColumn(
                    key: 'validFrom',
                    header: 'Etibarlıdır',
                    cell: (row) => WmsFormat.date(row.validFrom),
                  ),
                ],
                rows: data.uoms,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.mono = false,
    this.numeric = false,
  });

  final String label;
  final String value;
  final bool mono;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final style = numeric
        ? WmsTypography.figure
        : (mono ? WmsTypography.docNo : WmsTypography.body);
    return Padding(
      padding: const EdgeInsets.only(bottom: WmsSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: WmsTypography.label.copyWith(color: c.inkMuted),
            ),
          ),
          Expanded(
            child: Text(value, style: style.copyWith(color: c.ink)),
          ),
        ],
      ),
    );
  }
}
