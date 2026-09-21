import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import '../format/wms_format.dart';
import '../tokens/wms_colors.dart';
import '../tokens/wms_opacity.dart';
import '../tokens/wms_radius.dart';
import '../tokens/wms_spacing.dart';
import '../tokens/wms_typography.dart';
import 'wms_badge.dart';
import 'wms_doc_status_badge.dart';
import 'wms_empty_state.dart';

/// A batch with its available quantity, as shown in the picker.
@immutable
class WmsBatchOption {
  const WmsBatchOption({
    required this.id,
    required this.batchNo,
    required this.available,
    this.expiryDate,
    this.receivedAt,
    this.status = BatchStatus.active,
  });

  final int id;
  final String batchNo;
  final Quantity available;
  final DateTime? expiryDate;
  final DateTime? receivedAt;
  final BatchStatus status;

  bool get selectable => status.isAllocatable;
}

/// `.wms-batch*` — batch selection for issues, transfers, waste and samples.
///
/// * the FEFO/FIFO suggestion is badged so the user sees why a batch comes
///   first;
/// * non-`ACTIVE` batches stay visible but cannot be selected (the keeper
///   must see where the expired 42 units are);
/// * expiry has two levels: `criticalDays` → danger, `warningDays` → warning;
/// * order: ACTIVE, QUARANTINE, BLOCKED, EXPIRED, each by expiry date;
/// * picking anything other than the suggestion raises [onOffSuggestion] so
///   the form can require a reason code + note.
class WmsBatchPicker extends StatelessWidget {
  const WmsBatchPicker({
    required this.batches,
    this.strategy = IssueStrategy.fefo,
    this.value,
    this.onChanged,
    this.requiredQty,
    this.uom,
    this.decimals = 3,
    this.warningDays = 30,
    this.criticalDays = 7,
    this.today,
    this.onOffSuggestion,
    super.key,
  });

  final List<WmsBatchOption> batches;

  /// `master_product.issue_strategy`.
  final IssueStrategy strategy;
  final int? value;
  final ValueChanged<WmsBatchOption>? onChanged;
  final Quantity? requiredQty;
  final String? uom;
  final int decimals;

  /// `inv_setting.expiry_warning_days` / `expiry_critical_days`.
  final int warningDays;
  final int criticalDays;

  /// Injected "today" for tests.
  final DateTime? today;

  /// Called when the user selects a batch other than the suggested one.
  final ValueChanged<WmsBatchOption>? onOffSuggestion;

  static const String suggestionLabelFefo = 'FEFO təklifi';
  static const String suggestionLabelFifo = 'FIFO təklifi';
  static const String offSuggestionWarning =
      'Təklif olunan partiya seçilmədi — səbəb kodu və qeyd məcburidir';

  String get suggestionLabel => strategy == IssueStrategy.fefo
      ? suggestionLabelFefo
      : suggestionLabelFifo;

  /// Sorted: ACTIVE, QUARANTINE, BLOCKED, EXPIRED; then by expiry/received.
  List<WmsBatchOption> get sorted {
    const rank = {
      BatchStatus.active: 0,
      BatchStatus.quarantine: 1,
      BatchStatus.blocked: 2,
      BatchStatus.expired: 3,
    };
    final list = [...batches];
    list.sort((a, b) {
      final byStatus = (rank[a.status] ?? 9).compareTo(rank[b.status] ?? 9);
      if (byStatus != 0) return byStatus;
      return _allocationKey(a).compareTo(_allocationKey(b));
    });
    return list;
  }

  /// The batch the FEFO/FIFO rule would allocate first.
  WmsBatchOption? get suggested {
    final allocatable =
        batches.where((b) => b.selectable && b.available.isPositive).toList()
          ..sort((a, b) => _allocationKey(a).compareTo(_allocationKey(b)));
    return allocatable.isEmpty ? null : allocatable.first;
  }

  DateTime _allocationKey(WmsBatchOption b) {
    if (strategy == IssueStrategy.fefo) {
      return b.expiryDate ?? b.receivedAt ?? DateTime(9999);
    }
    return b.receivedAt ?? b.expiryDate ?? DateTime(9999);
  }

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final rows = sorted;
    final suggestion = suggested;
    final selectedOffSuggestion =
        value != null && suggestion != null && value != suggestion.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: WmsRadius.lgAll,
            border: Border.all(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: WmsSpacing.space2,
                  horizontal: WmsSpacing.space3,
                ),
                decoration: BoxDecoration(
                  color: c.surfaceSunken,
                  border: Border(bottom: BorderSide(color: c.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Partiya seçin',
                        style: WmsTypography.caption.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                    ),
                    if (requiredQty != null)
                      Text(
                        'Tələb: ${WmsFormat.quantity(requiredQty, decimals: decimals)}'
                        '${uom == null ? '' : ' $uom'}',
                        style: WmsTypography.figureSm.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                const WmsEmptyState(
                  reason: 'Bu məhsul üçün seçilə bilən partiya yoxdur.',
                  nextStep: 'Qəbul sənədi ilə yeni partiya yaradın.',
                )
              else
                for (var i = 0; i < rows.length; i++)
                  _BatchRow(
                    batch: rows[i],
                    selected: rows[i].id == value,
                    isSuggested:
                        suggestion != null && rows[i].id == suggestion.id,
                    suggestionLabel: suggestionLabel,
                    decimals: decimals,
                    uom: uom,
                    warningDays: warningDays,
                    criticalDays: criticalDays,
                    today: today,
                    isLast: i == rows.length - 1,
                    onTap: rows[i].selectable
                        ? () {
                            onChanged?.call(rows[i]);
                            if (suggestion != null &&
                                rows[i].id != suggestion.id) {
                              onOffSuggestion?.call(rows[i]);
                            }
                          }
                        : null,
                  ),
            ],
          ),
        ),
        if (selectedOffSuggestion)
          Padding(
            padding: const EdgeInsets.only(top: WmsSpacing.space2),
            child: Row(
              key: const ValueKey('wms-batch-off-suggestion'),
              children: [
                Icon(Icons.warning_amber_outlined, size: 16, color: c.warning),
                const SizedBox(width: WmsSpacing.space2),
                Expanded(
                  child: Text(
                    offSuggestionWarning,
                    style: WmsTypography.caption.copyWith(color: c.warning),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BatchRow extends StatelessWidget {
  const _BatchRow({
    required this.batch,
    required this.selected,
    required this.isSuggested,
    required this.suggestionLabel,
    required this.decimals,
    required this.warningDays,
    required this.criticalDays,
    required this.isLast,
    this.uom,
    this.today,
    this.onTap,
  });

  final WmsBatchOption batch;
  final bool selected;
  final bool isSuggested;
  final String suggestionLabel;
  final int decimals;
  final String? uom;
  final int warningDays;
  final int criticalDays;
  final DateTime? today;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    final expiry = batch.expiryDate;
    final days = expiry == null
        ? null
        : WmsFormat.daysUntil(expiry, from: today);
    final (expiryColor, expiryText) = switch (days) {
      null => (c.inkMuted, null),
      final d when d < 0 => (c.danger, '${-d} gün keçib'),
      final d when d <= criticalDays => (c.danger, '$d gün qalıb'),
      final d when d <= warningDays => (c.warning, '$d gün qalıb'),
      final d => (c.inkMuted, '$d gün qalıb'),
    };

    Widget row = Container(
      padding: const EdgeInsets.all(WmsSpacing.space3),
      decoration: BoxDecoration(
        color: selected ? c.accentSoft : null,
        border: isLast ? null : Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? c.accent : c.borderControl),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.accent,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: WmsSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        batch.batchNo,
                        style: WmsTypography.docNo.copyWith(color: c.ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSuggested) ...[
                      const SizedBox(width: WmsSpacing.space2),
                      WmsBadge(text: suggestionLabel, tone: WmsTone.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: WmsSpacing.space2,
                  runSpacing: WmsSpacing.space1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (expiry != null)
                      Text(
                        WmsFormat.date(expiry),
                        style: WmsTypography.figureSm.copyWith(
                          color: expiryColor,
                        ),
                      ),
                    if (expiryText != null)
                      Text(
                        expiryText,
                        style: WmsTypography.caption.copyWith(
                          color: expiryColor,
                        ),
                      ),
                    if (!batch.selectable)
                      WmsDocStatusBadge(status: batch.status.wire, dot: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: WmsSpacing.space3),
          Text(
            '${WmsFormat.quantity(batch.available, decimals: decimals)}'
            '${uom == null ? '' : ' $uom'}',
            style: WmsTypography.figure.copyWith(color: c.ink),
          ),
        ],
      ),
    );

    if (!batch.selectable) {
      row = Opacity(opacity: WmsOpacity.disabled, child: row);
    }
    return Semantics(
      selected: selected,
      button: batch.selectable,
      label: batch.batchNo,
      child: InkWell(onTap: onTap, hoverColor: c.rowHover, child: row),
    );
  }
}
