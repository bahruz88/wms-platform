import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'procurement_providers.dart';

/// Purchase order detail with the approval chain and the approve/reject
/// actions, both gated by `proc.po.approve` (spec §7.1).
class PurchaseOrderDetailScreen extends ConsumerStatefulWidget {
  const PurchaseOrderDetailScreen({required this.poId, super.key});

  final int poId;

  @override
  ConsumerState<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState
    extends ConsumerState<PurchaseOrderDetailScreen> {
  bool _submitting = false;
  Failure? _failure;
  String? _decision;

  Future<void> _decide(PurchaseOrderDto po, {required bool approve}) async {
    final comment = await _askComment(approve: approve);
    if (comment == null) return;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final repository = ref.read(procurementRepositoryProvider);
    final result = approve
        ? await repository.approve(
            po.id,
            rowVersion: po.rowVersion,
            comment: comment.isEmpty ? null : comment,
          )
        : await repository.reject(
            po.id,
            rowVersion: po.rowVersion,
            comment: comment.isEmpty ? null : comment,
          );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold(
        (dto) => _decision = approve ? 'Təsdiqləndi' : 'Rədd edildi',
        (failure) => _failure = failure,
      );
    });
    ref.invalidate(purchaseOrderDetailProvider(widget.poId));
  }

  /// Rejection requires a comment; approval may carry one.
  Future<String?> _askComment({required bool approve}) async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    return WmsDialog.show<String>(
      context: context,
      dialog: StatefulBuilder(
        builder: (context, setLocalState) {
          final text = controller.text.trim();
          final missing = !approve && text.isEmpty;
          return WmsDialog(
            title: approve ? l10n.actionApprove : l10n.actionReject,
            subtitle: approve
                ? 'Sifariş təsdiqləndikdən sonra təchizatçıya göndərilə bilər.'
                : 'Rədd səbəbi sənəddə saxlanılır.',
            onClose: () => Navigator.of(context).pop(),
            actions: [
              WmsButton(
                label: l10n.actionCancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
              WmsButton(
                label: approve ? l10n.actionApprove : l10n.actionReject,
                variant: approve
                    ? WmsButtonVariant.primary
                    : WmsButtonVariant.danger,
                enabled: !missing,
                disabledReason: 'Rədd üçün səbəb məcburidir',
                onPressed: () => Navigator.of(context).pop(controller.text),
              ),
            ],
            child: WmsTextField(
              controller: controller,
              label: 'Şərh',
              required: !approve,
              error: missing ? l10n.validationRequired : null,
              autofocus: true,
              onChanged: (_) => setLocalState(() {}),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final po = ref.watch(purchaseOrderDetailProvider(widget.poId));
    final canApprove = ref.watch(hasPermissionProvider(Permissions.poApprove));
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docPurchaseOrder)),
      body: WmsLoadingOverlay(
        loading: _submitting,
        child: AsyncView<PurchaseOrderDto>(
          value: po,
          onRetry: () =>
              ref.invalidate(purchaseOrderDetailProvider(widget.poId)),
          builder: (data) => ListView(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            children: [
              Row(
                children: [
                  Text(
                    data.docNo,
                    style: WmsTypography.titleLg.copyWith(color: c.ink),
                  ),
                  const SizedBox(width: WmsSpacing.space3),
                  WmsDocStatusBadge(status: data.status.wire),
                ],
              ),
              const SizedBox(height: WmsSpacing.space2),
              Text(
                '${data.supplierName ?? '#${data.supplierId}'} · '
                '${WmsFormat.date(data.docDate)}',
                style: WmsTypography.body.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: WmsSpacing.space4),
              if (_decision != null)
                WmsAlert(
                  tone: WmsAlertTone.success,
                  title: '${data.docNo} $_decision',
                ),
              if (_failure != null) WmsAlert.fromFailure(_failure!),
              const SizedBox(height: WmsSpacing.space4),
              Wrap(
                spacing: WmsSpacing.space4,
                runSpacing: WmsSpacing.space3,
                children: [
                  _Figure(
                    label: 'Ara cəm',
                    value: WmsFormat.money(data.subtotal),
                  ),
                  _Figure(label: 'ƏDV', value: WmsFormat.money(data.vatAmount)),
                  _Figure(
                    label: 'Cəm',
                    value: WmsFormat.money(data.totalAmount),
                  ),
                  _Figure(
                    label: 'Cəm (AZN)',
                    value: WmsFormat.money(data.totalAmountBase),
                  ),
                  _Figure(
                    label: 'Məzənnə',
                    value: WmsFormat.number(data.fxRate, decimals: 8),
                  ),
                ],
              ),
              const SizedBox(height: WmsSpacing.space5),
              WmsDataTable<PurchaseOrderLineDto>(
                caption: 'Sətirlər',
                permissions: permissions,
                rowKey: (row, _) => row.lineNo,
                emptyReason: 'Sifarişdə sətir yoxdur.',
                columns: [
                  WmsColumn(
                    key: 'lineNo',
                    header: '№',
                    width: 44,
                    align: WmsColumnAlign.right,
                    cell: (row) => '${row.lineNo}',
                  ),
                  WmsColumn(
                    key: 'product',
                    header: l10n.labelProduct,
                    flex: 4,
                    cell: (row) => row.productName ?? '#${row.productId}',
                  ),
                  WmsColumn(
                    key: 'qty',
                    header: l10n.labelQuantity,
                    numeric: true,
                    cell: (row) => WmsFormat.quantity(row.qty, decimals: 3),
                  ),
                  WmsColumn(
                    key: 'received',
                    header: l10n.labelReceived,
                    numeric: true,
                    cell: (row) =>
                        WmsFormat.quantity(row.receivedQty, decimals: 3),
                  ),
                  WmsColumn(
                    key: 'outstanding',
                    header: 'Qalıq',
                    numeric: true,
                    cell: (row) =>
                        WmsFormat.quantity(row.outstandingQty, decimals: 3),
                  ),
                  WmsColumn(
                    key: 'price',
                    header: 'Qiymət',
                    numeric: true,
                    permission: Permissions.productViewCost,
                    cell: (row) => WmsFormat.money(row.unitPrice),
                  ),
                  WmsColumn(
                    key: 'lineTotal',
                    header: 'Sətir cəmi',
                    numeric: true,
                    permission: Permissions.productViewCost,
                    cell: (row) => WmsFormat.money(row.lineTotal),
                  ),
                ],
                rows: data.lines,
              ),
              if (data.approvalSteps.isNotEmpty) ...[
                const SizedBox(height: WmsSpacing.space5),
                Text(
                  'Təsdiq zənciri',
                  style: WmsTypography.title.copyWith(color: c.ink),
                ),
                const SizedBox(height: WmsSpacing.space3),
                WmsApprovalChain(
                  steps: [
                    for (final step in data.approvalSteps)
                      WmsApprovalStep(
                        stepNo: step.stepNo,
                        role: step.approverName ?? 'ADDIM ${step.stepNo}',
                        user: step.approverName,
                        decision: step.decision,
                        decidedAt: step.decidedAt,
                        comment: step.comment,
                        delegatedFrom: step.delegatedFromUserId?.toString(),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: WmsSpacing.space5),
              Row(
                children: [
                  WmsButton.primary(
                    label: l10n.actionApprove,
                    iconLeft: Icons.check,
                    enabled: canApprove && data.status.canApprove,
                    disabledReason: canApprove
                        ? 'Sifariş təsdiq gözləmir'
                        : l10n.labelNoPermission,
                    onPressed: () => _decide(data, approve: true),
                  ),
                  const SizedBox(width: WmsSpacing.space2),
                  WmsButton.danger(
                    label: l10n.actionReject,
                    iconLeft: Icons.close,
                    enabled: canApprove && data.status.canApprove,
                    disabledReason: canApprove
                        ? 'Sifariş təsdiq gözləmir'
                        : l10n.labelNoPermission,
                    onPressed: () => _decide(data, approve: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: WmsTypography.label.copyWith(color: c.inkMuted)),
        const SizedBox(height: WmsSpacing.space1),
        Text(value, style: WmsTypography.figure.copyWith(color: c.ink)),
      ],
    );
  }
}
