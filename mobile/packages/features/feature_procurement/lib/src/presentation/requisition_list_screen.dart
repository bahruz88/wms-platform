import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../navigation.dart';
import 'procurement_providers.dart';

/// Purchase requisition list (`PR-YYYY-00000`).
class RequisitionListScreen extends ConsumerWidget {
  const RequisitionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final requisitions = ref.watch(requisitionListProvider);
    final canCreate = ref.watch(
      hasPermissionProvider(Permissions.requisitionCreate),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.docRequisitionLong),
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
                  context.go(ProcurementRoutes.requisitionCreateFullPath),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<RequisitionDto>>(
          value: requisitions,
          onRetry: () => ref.invalidate(requisitionListProvider),
          builder: (page) => WmsDataTable<RequisitionDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Satınalma tələbi yoxdur.',
            emptyNextStep: 'Filial ehtiyacı üçün yeni PR yaradın.',
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
                key: 'location',
                header: l10n.labelLocation,
                flex: 2,
                cell: (row) =>
                    row.requesterLocationName ?? '#${row.requesterLocationId}',
              ),
              WmsColumn(
                key: 'type',
                header: 'Tip',
                width: 120,
                render: (row, _) => WmsBadge(text: row.productType.wire),
              ),
              WmsColumn(
                key: 'priority',
                header: 'Prioritet',
                width: 120,
                render: (row, _) => WmsBadge(
                  text: row.priority.wire,
                  tone: row.priority == Priority.urgent
                      ? WmsTone.danger
                      : (row.priority == Priority.high
                            ? WmsTone.warning
                            : WmsTone.neutral),
                ),
              ),
              WmsColumn(
                key: 'status',
                header: l10n.labelStatus,
                width: 160,
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
