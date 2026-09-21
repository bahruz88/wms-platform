import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../navigation.dart';
import '../inventory_providers.dart';

/// Issue / transfer list. Dispatched documents sit in the virtual
/// `IN_TRANSIT` location until the branch confirms them (spec §12.3).
class IssueListScreen extends ConsumerWidget {
  const IssueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final issues = ref.watch(issueListProvider(null));
    final canConfirm = ref.watch(
      hasPermissionProvider(Permissions.issueConfirm),
    );

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.docIssue} / ${l10n.docTransfer}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: AsyncView<Page<IssueDto>>(
          value: issues,
          onRetry: () => ref.invalidate(issueListProvider(null)),
          builder: (page) => WmsDataTable<IssueDto>(
            rowKey: (row, _) => row.id,
            emptyReason: 'Məxaric və ya transfer sənədi yoxdur.',
            emptyNextStep: 'Filial tələbi əsasında yeni məxaric yaradın.',
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
                key: 'type',
                header: 'Tip',
                width: 160,
                render: (row, _) => WmsBadge(text: row.issueType.wire),
              ),
              WmsColumn(
                key: 'from',
                header: 'Mənbə',
                flex: 2,
                cell: (row) => row.fromLocationName ?? '#${row.fromLocationId}',
              ),
              WmsColumn(
                key: 'to',
                header: 'Hədəf',
                flex: 2,
                cell: (row) => row.toLocationName ?? '#${row.toLocationId}',
              ),
              WmsColumn(
                key: 'status',
                header: l10n.labelStatus,
                width: 140,
                render: (row, _) => WmsDocStatusBadge(status: row.status.wire),
              ),
              WmsColumn(
                key: 'action',
                header: '',
                width: 180,
                render: (row, _) => row.status.canConfirm
                    ? WmsButton(
                        label: l10n.actionConfirmReceipt,
                        size: WmsButtonSize.sm,
                        enabled: canConfirm,
                        disabledReason: l10n.labelNoPermission,
                        onPressed: () =>
                            context.go(InventoryRoutes.issueConfirm(row.id)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
            rows: page.items,
          ),
        ),
      ),
    );
  }
}
