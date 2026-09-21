import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../consumption_alert.dart';
import '../consumption_providers.dart';

/// «İstehlak jurnalı» — one row per branch and day, with the two numbers a
/// manager acts on: how many products fell short and how many sales lines
/// produced nothing.
///
/// The three actions are permission gated and each is a different right:
/// `cons.run.calculate` recalculates, `cons.run.post` writes the ledger
/// group, and only `inv.movement.reverse` may undo a posted document — and
/// then only with a reason code (SPEC §12.6).
class ConsumptionJournalScreen extends ConsumerStatefulWidget {
  const ConsumptionJournalScreen({super.key});

  @override
  ConsumerState<ConsumptionJournalScreen> createState() =>
      _ConsumptionJournalScreenState();
}

class _ConsumptionJournalScreenState
    extends ConsumerState<ConsumptionJournalScreen> {
  bool _busy = false;
  Failure? _failure;
  String? _notice;

  Future<void> _run(
    Future<Result<ConsumptionRunDetailDto>> Function() action,
    String Function(ConsumptionRunDetailDto run) success,
  ) async {
    setState(() {
      _busy = true;
      _failure = null;
      _notice = null;
    });
    final result = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((run) => _notice = success(run), (f) => _failure = f);
    });
    if (_failure == null) ref.invalidate(runJournalProvider);
  }

  Future<void> _reverse(ConsumptionRunDto run) async {
    final reasons =
        ref.read(reasonCodeListProvider(ReasonGroup.adjustment)).value ??
        const <ReasonCodeDto>[];
    final choice = await WmsDialog.show<_ReverseChoice>(
      context: context,
      dialog: _ReverseDialog(docNo: run.docNo, reasons: reasons),
    );
    if (choice == null || !mounted) return;
    await _run(
      () => ref
          .read(consumptionRepositoryProvider)
          .reverseRun(
            run.id,
            ReverseConsumptionRunRequest(
              reasonCodeId: choice.reasonCodeId,
              note: choice.note,
            ),
          ),
      (reversed) => '${reversed.docNo} storno edildi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consJournal)),
      body: RequirePermission.withNotice(
        permission: Permissions.runCalculate,
        child: WmsLoadingOverlay(
          loading: _busy,
          child: ListView(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            children: [
              const _Filters(),
              const SizedBox(height: WmsSpacing.space4),
              if (_notice != null) ...[
                WmsAlert(tone: WmsAlertTone.success, title: _notice),
                const SizedBox(height: WmsSpacing.space3),
              ],
              if (_failure != null) ...[
                ConsumptionAlert(
                  failure: _failure!,
                  onClose: () => setState(() => _failure = null),
                ),
                const SizedBox(height: WmsSpacing.space3),
              ],
              _JournalTable(
                onCalculate: (run) => _run(
                  () => ref
                      .read(consumptionRepositoryProvider)
                      .calculateRun(run.id, rowVersion: run.rowVersion),
                  (updated) =>
                      '${updated.docNo} yenidən hesablandı · '
                      '${updated.shortfallCount} çatışmazlıq.',
                ),
                onPost: (run) => _run(
                  () => ref
                      .read(consumptionRepositoryProvider)
                      .postRun(run.id, rowVersion: run.rowVersion),
                  (posted) => '${posted.docNo} post edildi.',
                ),
                onReverse: _reverse,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(runJournalFilterProvider);
    final notifier = ref.read(runJournalFilterProvider.notifier);
    final locations = ref.watch(locationListProvider).value ?? const [];

    return Wrap(
      spacing: WmsSpacing.space4,
      runSpacing: WmsSpacing.space3,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 280,
          child: WmsSelect<int>(
            label: l10n.labelLocation,
            value: filter.locationId,
            placeholder: l10n.labelAll,
            options: [
              for (final location in locations)
                if (!location.isVirtual)
                  WmsSelectOption(
                    value: location.id,
                    label: '${location.code} · ${location.name}',
                  ),
            ],
            onChanged: notifier.setLocation,
          ),
        ),
        SizedBox(
          width: 220,
          child: WmsSelect<ConsumptionRunStatus>(
            label: l10n.labelStatus,
            value: filter.status,
            placeholder: l10n.labelAll,
            options: [
              for (final status in ConsumptionRunStatus.values)
                WmsSelectOption(
                  value: status,
                  label: WmsDocStatusBadge.resolve(status.wire).$1,
                ),
            ],
            onChanged: notifier.setStatus,
          ),
        ),
        SizedBox(
          width: 240,
          child: WmsSelect<bool>(
            label: l10n.consLabelShortfall,
            value: filter.shortfallOnly,
            options: [
              WmsSelectOption(value: false, label: l10n.labelAll),
              const WmsSelectOption(
                value: true,
                label: 'Yalnız çatışmazlığı olanlar',
              ),
            ],
            onChanged: (value) =>
                notifier.setShortfallOnly(value: value ?? false),
          ),
        ),
      ],
    );
  }
}

class _JournalTable extends ConsumerWidget {
  const _JournalTable({
    required this.onCalculate,
    required this.onPost,
    required this.onReverse,
  });

  final ValueChanged<ConsumptionRunDto> onCalculate;
  final ValueChanged<ConsumptionRunDto> onPost;
  final ValueChanged<ConsumptionRunDto> onReverse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final runs = ref.watch(runJournalProvider);

    return AsyncView<Page<ConsumptionRunDto>>(
      value: runs,
      onRetry: () => ref.invalidate(runJournalProvider),
      builder: (page) => WmsDataTable<ConsumptionRunDto>(
        rowKey: (row, _) => row.id,
        minWidth: 1040,
        emptyReason: l10n.consEmptyRunsReason,
        emptyNextStep: l10n.consEmptyRunsNext,
        columns: [
          WmsColumn(
            key: 'docNo',
            header: l10n.consLabelDocNo,
            width: 150,
            render: (row, _) => Text(
              row.docNo,
              style: WmsTypography.docNo.copyWith(color: c.ink),
            ),
          ),
          WmsColumn(
            key: 'businessDate',
            header: l10n.consLabelBusinessDate,
            width: 120,
            cell: (row) => WmsFormat.date(row.businessDate),
          ),
          WmsColumn(
            key: 'location',
            header: l10n.labelLocation,
            flex: 3,
            cell: (row) => row.locationName ?? '#${row.locationId}',
          ),
          WmsColumn(
            key: 'shortfall',
            header: l10n.consLabelShortfall,
            width: 130,
            numeric: true,
            render: (row, _) => Text(
              '${row.shortfallCount}',
              textAlign: TextAlign.right,
              style: WmsTypography.figure.copyWith(
                color: row.hasShortfall ? c.warning : c.inkMuted,
                fontWeight: row.hasShortfall
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          WmsColumn(
            key: 'unmapped',
            header: l10n.consLabelUnmapped,
            width: 130,
            numeric: true,
            render: (row, _) => Text(
              '${row.unmappedCount}',
              textAlign: TextAlign.right,
              style: WmsTypography.figure.copyWith(
                color: row.hasUnmapped ? c.warning : c.inkMuted,
              ),
            ),
          ),
          WmsColumn(
            key: 'status',
            header: l10n.labelStatus,
            width: 160,
            render: (row, _) => WmsDocStatusBadge(status: row.status.wire),
          ),
          WmsColumn(
            key: 'actions',
            header: '',
            width: 300,
            render: (row, _) => _RowActions(
              run: row,
              onCalculate: () => onCalculate(row),
              onPost: () => onPost(row),
              onReverse: () => onReverse(row),
            ),
          ),
        ],
        rows: page.items,
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.run,
    required this.onCalculate,
    required this.onPost,
    required this.onReverse,
  });

  final ConsumptionRunDto run;
  final VoidCallback onCalculate;
  final VoidCallback onPost;
  final VoidCallback onReverse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: WmsSpacing.space2,
      runSpacing: WmsSpacing.space2,
      children: [
        RequirePermission(
          permission: Permissions.runCalculate,
          child: WmsButton(
            label: l10n.consActionCalculate,
            size: WmsButtonSize.sm,
            enabled: run.status.canCalculate,
            disabledReason:
                'Post edilmiş sənəd yenidən hesablanmır — storno edin',
            onPressed: onCalculate,
          ),
        ),
        RequirePermission(
          permission: Permissions.runPost,
          child: WmsButton.primary(
            label: l10n.actionPost,
            size: WmsButtonSize.sm,
            enabled: run.status.canPost,
            disabledReason: 'Yalnız hesablanmış sənəd post edilir',
            onPressed: onPost,
          ),
        ),
        RequirePermission(
          permission: Permissions.movementReverse,
          child: WmsButton.danger(
            label: l10n.consActionReverse,
            size: WmsButtonSize.sm,
            enabled: run.status.canReverse,
            disabledReason: 'Yalnız post edilmiş sənəd storno edilir',
            onPressed: onReverse,
          ),
        ),
      ],
    );
  }
}

/// Result of the reverse dialog; the reason code is never optional.
class _ReverseChoice {
  const _ReverseChoice({required this.reasonCodeId, this.note});

  final int reasonCodeId;
  final String? note;
}

class _ReverseDialog extends StatefulWidget {
  const _ReverseDialog({required this.docNo, required this.reasons});

  final String docNo;
  final List<ReasonCodeDto> reasons;

  @override
  State<_ReverseDialog> createState() => _ReverseDialogState();
}

class _ReverseDialogState extends State<_ReverseDialog> {
  int? _reasonCodeId;
  String? _note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WmsDialog(
      title: l10n.consReverseTitle,
      subtitle: widget.docNo,
      onClose: () => Navigator.of(context).pop(),
      actions: [
        WmsButton(
          label: l10n.actionCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        WmsButton.danger(
          label: l10n.consActionReverse,
          enabled: _reasonCodeId != null,
          disabledReason: l10n.consReverseReasonRequired,
          onPressed: _reasonCodeId == null
              ? null
              : () => Navigator.of(context).pop(
                  _ReverseChoice(reasonCodeId: _reasonCodeId!, note: _note),
                ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.consReverseMessage),
          const SizedBox(height: WmsSpacing.space4),
          WmsSelect<int>(
            label: l10n.labelReasonCode,
            required: true,
            value: _reasonCodeId,
            placeholder: 'Səbəb seçin',
            error: _reasonCodeId == null
                ? l10n.consReverseReasonRequired
                : null,
            options: [
              for (final reason in widget.reasons)
                WmsSelectOption(
                  value: reason.id,
                  label: '${reason.code} · ${reason.name}',
                ),
            ],
            onChanged: (value) => setState(() => _reasonCodeId = value),
          ),
          const SizedBox(height: WmsSpacing.space3),
          WmsTextField(
            label: l10n.labelNote,
            maxLines: 3,
            onChanged: (value) =>
                _note = value.trim().isEmpty ? null : value.trim(),
          ),
        ],
      ),
    );
  }
}
