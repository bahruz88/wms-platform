import 'package:decimal/decimal.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../inventory_providers.dart';

/// Inventory count entry: frozen book quantity vs counted quantity, the
/// variance with its percentage, and the mandatory reason code whenever the
/// variance is not zero (spec §9.6, §12.6).
class CountScreen extends ConsumerStatefulWidget {
  const CountScreen({
    required this.countId,
    this.varianceThresholdPct,
    super.key,
  });

  final int countId;

  /// `inv_setting.count_variance_approval_threshold_pct` (default 2).
  final Decimal? varianceThresholdPct;

  @override
  ConsumerState<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends ConsumerState<CountScreen> {
  final Map<int, Quantity> _counted = {};
  final Map<int, int> _reasonCodes = {};
  bool _submitting = false;
  Failure? _failure;
  bool _saved = false;

  Decimal get _threshold => widget.varianceThresholdPct ?? Decimal.fromInt(2);

  bool _needsReason(CountLineDto line) {
    final counted = _counted[line.id] ?? line.countedQty;
    if (counted == null) return false;
    final variance = counted - line.bookQty;
    if (variance.isZero) return false;
    return (_reasonCodes[line.id] ?? line.reasonCodeId) == null;
  }

  bool _canSave(CountDto count) =>
      count.status.canEnterCounts &&
      _counted.isNotEmpty &&
      !count.lines.any(_needsReason);

  Future<void> _save(CountDto count) async {
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final request = EnterCountRequest(
      rowVersion: count.rowVersion,
      lines: [
        for (final entry in _counted.entries)
          EnterCountLine(
            lineId: entry.key,
            countedQty: entry.value,
            reasonCodeId: _reasonCodes[entry.key],
          ),
      ],
    );
    final result = await ref
        .read(inventoryRepositoryProvider)
        .enterCounts(widget.countId, request);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold((_) => _saved = true, (failure) => _failure = failure);
    });
    if (_saved) ref.invalidate(countDetailProvider(widget.countId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final count = ref.watch(countDetailProvider(widget.countId));
    final reasons = ref.watch(reasonCodeListProvider(ReasonGroup.adjustment));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docCount)),
      body: WmsLoadingOverlay(
        loading: _submitting,
        child: AsyncView<CountDto>(
          value: count,
          onRetry: () => ref.invalidate(countDetailProvider(widget.countId)),
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
                '${data.locationName ?? '#${data.locationId}'} · ${data.countType.wire}',
                style: WmsTypography.body.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: WmsSpacing.space4),
              if (data.status.blocksLocation)
                const WmsAlert(
                  tone: WmsAlertTone.warning,
                  title: 'Lokasiya sayım üçün dondurulub',
                  message:
                      'Sayım bitənə qədər bu lokasiyada qəbul, məxaric, transfer, '
                      'tullantı və nümunə əməliyyatları rədd edilir.',
                  code: ProblemCodes.locationFrozen,
                ),
              if (_saved) ...[
                const SizedBox(height: WmsSpacing.space3),
                const WmsAlert(
                  tone: WmsAlertTone.success,
                  title: 'Sayım sətirləri yadda saxlanıldı',
                ),
              ],
              if (_failure != null) ...[
                const SizedBox(height: WmsSpacing.space3),
                WmsAlert.fromFailure(_failure!),
              ],
              const SizedBox(height: WmsSpacing.space4),
              for (final line in data.lines)
                _CountLineCard(
                  line: line,
                  counted: _counted[line.id],
                  reasonCodeId: _reasonCodes[line.id] ?? line.reasonCodeId,
                  thresholdPct: _threshold,
                  reasonOptions: [
                    for (final reason
                        in reasons.value ?? const <ReasonCodeDto>[])
                      WmsSelectOption(
                        value: reason.id,
                        label: '${reason.code} · ${reason.name}',
                      ),
                  ],
                  editable: data.status.canEnterCounts,
                  onCountedChanged: (value) => setState(() {
                    if (value == null) {
                      _counted.remove(line.id);
                    } else {
                      _counted[line.id] = value;
                    }
                  }),
                  onReasonChanged: (value) => setState(() {
                    if (value == null) {
                      _reasonCodes.remove(line.id);
                    } else {
                      _reasonCodes[line.id] = value;
                    }
                  }),
                ),
              const SizedBox(height: WmsSpacing.space5),
              Align(
                alignment: Alignment.centerLeft,
                child: WmsButton.primary(
                  label: l10n.actionSave,
                  enabled: _canSave(data),
                  disabledReason: data.status.canEnterCounts
                      ? l10n.validationReasonCodeRequired
                      : 'Sayım statusu daxiletməyə icazə vermir',
                  loading: _submitting,
                  onPressed: () => _save(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountLineCard extends StatelessWidget {
  const _CountLineCard({
    required this.line,
    required this.thresholdPct,
    required this.reasonOptions,
    required this.editable,
    required this.onCountedChanged,
    required this.onReasonChanged,
    this.counted,
    this.reasonCodeId,
  });

  final CountLineDto line;
  final Quantity? counted;
  final int? reasonCodeId;
  final Decimal thresholdPct;
  final List<WmsSelectOption<int>> reasonOptions;
  final bool editable;
  final ValueChanged<Quantity?> onCountedChanged;
  final ValueChanged<int?> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final effective = counted ?? line.countedQty;
    final hasVariance = effective != null && !(effective - line.bookQty).isZero;

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
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.labelBook,
                      style: WmsTypography.label.copyWith(color: c.inkMuted),
                    ),
                    const SizedBox(height: WmsSpacing.space1),
                    // Balance is never an input: the frozen book quantity is
                    // displayed read-only.
                    Text(
                      '${WmsFormat.quantity(line.bookQty, decimals: 3)}'
                      '${line.baseUomCode == null ? '' : ' ${line.baseUomCode}'}',
                      style: WmsTypography.figure.copyWith(color: c.ink),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: WmsQtyUomInput(
                  label: l10n.labelCounted,
                  required: true,
                  enabled: editable,
                  qty: effective,
                  uomId: 0,
                  uoms: [
                    WmsProductUom(
                      id: 0,
                      code: line.baseUomCode ?? 'BASE',
                      factorToBase: Decimal.one,
                    ),
                  ],
                  onQtyChanged: onCountedChanged,
                ),
              ),
              if (effective != null)
                WmsVarianceIndicator(
                  book: line.bookQty,
                  counted: effective,
                  uom: line.baseUomCode,
                  thresholdPct: thresholdPct,
                  reasonCode: reasonCodeId?.toString(),
                ),
            ],
          ),
          if (hasVariance) ...[
            const SizedBox(height: WmsSpacing.space3),
            SizedBox(
              width: 360,
              child: WmsSelect<int>(
                label: l10n.labelReasonCode,
                required: true,
                enabled: editable,
                value: reasonCodeId,
                placeholder: 'Səbəb seçin',
                error: reasonCodeId == null
                    ? l10n.validationReasonCodeRequired
                    : null,
                options: reasonOptions,
                onChanged: onReasonChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
