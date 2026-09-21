import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'async_view.dart';
import 'master_data_providers.dart';

/// Location list. Virtual locations carry the `virtual` tone so they are
/// never confused with physical warehouses.
class LocationListScreen extends ConsumerWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locations = ref.watch(locationListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelLocations)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<List<LocationDto>>(
          value: locations,
          onRetry: () => ref.invalidate(locationListProvider),
          builder: (items) => WmsDataTable<LocationDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Sizə təyin edilmiş lokasiya yoxdur.',
            emptyNextStep: 'Administratordan lokasiya icazəsi tələb edin.',
            columns: [
              WmsColumn(
                key: 'code',
                header: 'Kod',
                width: 140,
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
                key: 'type',
                header: 'Tip',
                flex: 2,
                render: (row, _) => WmsBadge(
                  text: row.locationType.wire,
                  tone: row.isVirtual ? WmsTone.virtual : WmsTone.neutral,
                  tooltip: row.isVirtual
                      ? 'Virtual lokasiya'
                      : 'Fiziki lokasiya',
                ),
              ),
              WmsColumn(
                key: 'food',
                header: 'Qida',
                width: 90,
                cell: (row) => row.allowsFood ? 'Bəli' : 'Xeyr',
              ),
              WmsColumn(
                key: 'nonFood',
                header: 'Qeyri-qida',
                width: 110,
                cell: (row) => row.allowsNonFood ? 'Bəli' : 'Xeyr',
              ),
            ],
            rows: items,
          ),
        ),
      ),
    );
  }
}
