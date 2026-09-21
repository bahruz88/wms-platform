import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Branch confirmation: `IN_TRANSIT` → destination. The keeper enters what
/// actually arrived; a discrepancy is recorded on the document rather than
/// silently corrected.
class IssueConfirmScreen extends ConsumerStatefulWidget {
  const IssueConfirmScreen({required this.issueId, super.key});

  final int issueId;

  @override
  ConsumerState<IssueConfirmScreen> createState() => _IssueConfirmScreenState();
}

class _IssueConfirmScreenState extends ConsumerState<IssueConfirmScreen> {
  final Map<int, Quantity> _received = {};
  final Map<int, String> _notes = {};
  bool _submitting = false;
  Failure? _failure;
  bool _done = false;

  Future<void> _confirm(IssueDto issue) async {
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final request = ConfirmIssueRequest(
      rowVersion: issue.rowVersion,
      lines: [
        for (final line in issue.lines)
          ConfirmIssueLine(
            lineNo: line.lineNo,
            receivedQty: _received[line.lineNo] ?? line.qty,
            note: _notes[line.lineNo],
          ),
      ],
    );
    final result = await ref
        .read(inventoryRepositoryProvider)
        .confirmIssue(widget.issueId, request);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold((_) => _done = true, (failure) => _failure = failure);
    });
    if (_done) ref.invalidate(issueDetailProvider(widget.issueId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final issue = ref.watch(issueDetailProvider(widget.issueId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionConfirmReceipt)),
      body: WmsLoadingOverlay(
        loading: _submitting,
        child: AsyncView<IssueDto>(
          value: issue,
          onRetry: () => ref.invalidate(issueDetailProvider(widget.issueId)),
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
                '${data.fromLocationName ?? '#${data.fromLocationId}'} → '
                '${data.toLocationName ?? '#${data.toLocationId}'}',
                style: WmsTypography.body.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: WmsSpacing.space4),
              if (_done)
                WmsAlert(
                  tone: WmsAlertTone.success,
                  title: '${data.docNo} qəbul edildi',
                  message: 'Mal IN_TRANSIT-dən filial qalığına keçdi.',
                ),
              if (_failure != null) WmsAlert.fromFailure(_failure!),
              if (!data.status.canConfirm && !_done) ...[
                const WmsAlert(
                  title: 'Bu sənəd təsdiq gözləmir',
                  message: 'Yalnız DISPATCHED statuslu sənəd təsdiqlənə bilər.',
                ),
                const SizedBox(height: WmsSpacing.space4),
              ],
              const SizedBox(height: WmsSpacing.space4),
              for (final line in data.lines)
                _ConfirmLine(
                  line: line,
                  received: _received[line.lineNo],
                  onQtyChanged: (value) => setState(() {
                    if (value == null) {
                      _received.remove(line.lineNo);
                    } else {
                      _received[line.lineNo] = value;
                    }
                  }),
                  onNoteChanged: (value) => _notes[line.lineNo] = value,
                ),
              const SizedBox(height: WmsSpacing.space5),
              Align(
                alignment: Alignment.centerLeft,
                child: WmsButton.primary(
                  label: l10n.actionConfirmReceipt,
                  enabled: data.status.canConfirm && !_done,
                  disabledReason: _done
                      ? 'Sənəd artıq təsdiqlənib'
                      : 'Sənəd DISPATCHED statusunda deyil',
                  loading: _submitting,
                  onPressed: () => _confirm(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmLine extends StatelessWidget {
  const _ConfirmLine({
    required this.line,
    required this.onQtyChanged,
    required this.onNoteChanged,
    this.received,
  });

  final IssueLineDto line;
  final Quantity? received;
  final ValueChanged<Quantity?> onQtyChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final effective = received ?? line.qty;
    final discrepancy = effective - line.qty;
    final hasDiscrepancy = !discrepancy.isZero;

    return Container(
      margin: const EdgeInsets.only(bottom: WmsSpacing.space3),
      padding: WmsSpacing.cardPadding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: WmsRadius.lgAll,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.productName ?? 'Məhsul #${line.productId}',
            style: WmsTypography.bodyStrong.copyWith(color: c.ink),
          ),
          if (line.batchNo != null)
            Text(
              line.batchNo!,
              style: WmsTypography.docNo.copyWith(color: c.inkMuted),
            ),
          const SizedBox(height: WmsSpacing.space3),
          Wrap(
            spacing: WmsSpacing.space4,
            runSpacing: WmsSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Göndərilən',
                      style: WmsTypography.label.copyWith(color: c.inkMuted),
                    ),
                    const SizedBox(height: WmsSpacing.space1),
                    Text(
                      '${WmsFormat.quantity(line.qty, decimals: 3)}'
                      '${line.uomCode == null ? '' : ' ${line.uomCode}'}',
                      style: WmsTypography.figure.copyWith(color: c.ink),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 240,
                child: WmsQtyUomInput(
                  label: l10n.labelReceived,
                  required: true,
                  qty: effective,
                  uomId: line.uomId,
                  uoms: [
                    WmsProductUom(
                      id: line.uomId,
                      code: line.uomCode ?? 'BASE',
                      factorToBase: Quantity.fromInt(1).value,
                    ),
                  ],
                  onQtyChanged: onQtyChanged,
                ),
              ),
              if (hasDiscrepancy)
                WmsBadge(
                  text:
                      'Fərq ${WmsFormat.signedQuantity(discrepancy, decimals: 3)}',
                  tone: WmsTone.warning,
                  icon: Icons.warning_amber_outlined,
                ),
            ],
          ),
          if (hasDiscrepancy) ...[
            const SizedBox(height: WmsSpacing.space3),
            WmsTextField(
              label: l10n.labelNote,
              required: true,
              hint: 'Fərqin səbəbini yazın — sənəd DISCREPANCY statusuna keçir',
              onChanged: onNoteChanged,
            ),
          ],
        ],
      ),
    );
  }
}
