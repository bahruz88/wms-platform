import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'reporting_providers.dart';

/// Report catalogue with the async Excel export trigger.
class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final reports = ref.watch(reportListProvider);
    final exportState = ref.watch(exportControllerProvider);
    final canExport = ref.watch(
      hasPermissionProvider(Permissions.reportExport),
    );
    final job = exportState.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (exportState.hasError)
              WmsAlert.fromFailure(AsyncView.failureOf(exportState.error!)),
            if (job != null)
              WmsAlert(
                tone: job.isFailed ? WmsAlertTone.danger : WmsAlertTone.info,
                title: '${job.reportCode} · ${job.status}',
                message: job.isDone
                    ? 'Fayl hazırdır, yükləmə linki ilə açın.'
                    : 'Export arxa planda icra olunur.',
                code: job.error,
              ),
            const SizedBox(height: WmsSpacing.space4),
            AsyncView<List<ReportDefinitionDto>>(
              value: reports,
              onRetry: () => ref.invalidate(reportListProvider),
              builder: (items) => WmsDataTable<ReportDefinitionDto>(
                rowKey: (row, _) => row.code,
                emptyReason: 'Sizə açıq hesabat yoxdur.',
                emptyNextStep: 'Administratordan hesabat icazəsi tələb edin.',
                columns: [
                  WmsColumn(
                    key: 'code',
                    header: 'Kod',
                    width: 160,
                    render: (row, _) => Text(
                      row.code,
                      style: WmsTypography.docNo.copyWith(color: c.ink),
                    ),
                  ),
                  WmsColumn(
                    key: 'name',
                    header: 'Hesabat',
                    flex: 3,
                    cell: (row) => row.name,
                  ),
                  WmsColumn(
                    key: 'category',
                    header: 'Kateqoriya',
                    flex: 2,
                    render: (row, _) => WmsBadge(text: row.category),
                  ),
                  WmsColumn(
                    key: 'export',
                    header: '',
                    width: 170,
                    render: (row, _) => WmsButton(
                      label: l10n.actionExport,
                      size: WmsButtonSize.sm,
                      iconLeft: Icons.download_outlined,
                      enabled: canExport && row.supportsExport,
                      disabledReason: canExport
                          ? 'Bu hesabat export dəstəkləmir'
                          : l10n.labelNoPermission,
                      loading: exportState.isLoading,
                      onPressed: () => ref
                          .read(exportControllerProvider.notifier)
                          .export(row.code),
                    ),
                  ),
                ],
                rows: items,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
