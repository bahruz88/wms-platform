import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'procurement_providers.dart';

/// Quotation comparison. Selecting anything other than the cheapest offer
/// requires a written justification (`selection_note`, spec §10) — the
/// confirm button stays disabled until it is filled in.
class QuotationComparisonScreen extends ConsumerStatefulWidget {
  const QuotationComparisonScreen({required this.rfqId, super.key});

  final int rfqId;

  @override
  ConsumerState<QuotationComparisonScreen> createState() =>
      _QuotationComparisonScreenState();
}

class _QuotationComparisonScreenState
    extends ConsumerState<QuotationComparisonScreen> {
  int? _selectedId;
  String _selectionNote = '';
  bool _submitting = false;
  Failure? _failure;
  bool _done = false;

  /// The cheapest quotation by base-currency total.
  QuotationDto? _cheapest(List<QuotationDto> quotations) {
    final withTotal = quotations
        .where((q) => (q.totalAmountBase ?? q.totalAmount) != null)
        .toList();
    if (withTotal.isEmpty) return null;
    withTotal.sort(
      (a, b) => (a.totalAmountBase ?? a.totalAmount)!.compareTo(
        (b.totalAmountBase ?? b.totalAmount)!,
      ),
    );
    return withTotal.first;
  }

  bool _noteRequired(List<QuotationDto> quotations) {
    final cheapest = _cheapest(quotations);
    return _selectedId != null &&
        cheapest != null &&
        _selectedId != cheapest.id;
  }

  Future<void> _select(List<QuotationDto> quotations) async {
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final result = await ref
        .read(procurementRepositoryProvider)
        .selectQuotation(
          widget.rfqId,
          SelectQuotationRequest(
            quotationId: _selectedId!,
            selectionNote: _selectionNote.isEmpty ? null : _selectionNote,
          ),
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold((_) => _done = true, (failure) => _failure = failure);
    });
    if (_done) ref.invalidate(quotationListProvider(widget.rfqId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final quotations = ref.watch(quotationListProvider(widget.rfqId));
    final canSelect = ref.watch(
      hasPermissionProvider(Permissions.quotationSelect),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labelComparison)),
      body: WmsLoadingOverlay(
        loading: _submitting,
        child: AsyncView<List<QuotationDto>>(
          value: quotations,
          onRetry: () => ref.invalidate(quotationListProvider(widget.rfqId)),
          builder: (items) {
            final cheapest = _cheapest(items);
            final noteRequired = _noteRequired(items);
            final noteMissing = noteRequired && _selectionNote.trim().isEmpty;
            return ListView(
              padding: const EdgeInsets.all(WmsSpacing.space4),
              children: [
                if (_done)
                  const WmsAlert(
                    tone: WmsAlertTone.success,
                    title: 'Təklif seçildi',
                    message: 'PO yaratmaq üçün satınalma sənədinə keçin.',
                  ),
                if (_failure != null) WmsAlert.fromFailure(_failure!),
                const SizedBox(height: WmsSpacing.space3),
                WmsDataTable<QuotationDto>(
                  caption: 'Təkliflər',
                  // Wide comparison grid: scrolls horizontally on phones.
                  minWidth: 1100,
                  rowKey: (row, _) => row.id,
                  selectedKey: _selectedId,
                  emptyReason: 'Bu RFQ üzrə təklif daxil olmayıb.',
                  emptyNextStep: 'Təchizatçılardan təklif gözlənilir.',
                  onRowTap: canSelect
                      ? (row, _) => setState(() => _selectedId = row.id)
                      : null,
                  columns: [
                    WmsColumn(
                      key: 'supplier',
                      header: l10n.labelSupplier,
                      flex: 3,
                      render: (row, _) => Row(
                        children: [
                          Flexible(
                            child: Text(
                              row.supplierName ?? '#${row.supplierId}',
                              style: WmsTypography.bodyStrong.copyWith(
                                color: c.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (cheapest != null && row.id == cheapest.id) ...[
                            const SizedBox(width: WmsSpacing.space2),
                            const WmsBadge(
                              text: 'Ən ucuz',
                              tone: WmsTone.accent,
                            ),
                          ],
                        ],
                      ),
                    ),
                    WmsColumn(
                      key: 'quoteNo',
                      header: 'Təklif №',
                      flex: 2,
                      render: (row, _) => Text(
                        row.quoteNo ?? '—',
                        style: WmsTypography.docNo.copyWith(color: c.ink),
                      ),
                    ),
                    WmsColumn(
                      key: 'date',
                      header: l10n.labelDate,
                      width: 120,
                      cell: (row) => WmsFormat.date(row.quoteDate),
                    ),
                    WmsColumn(
                      key: 'validUntil',
                      header: 'Etibarlıdır',
                      width: 130,
                      cell: (row) => WmsFormat.date(row.validUntil),
                    ),
                    WmsColumn(
                      key: 'delivery',
                      header: 'Çatdırılma (gün)',
                      width: 150,
                      numeric: true,
                      cell: (row) => row.deliveryDays?.toString() ?? '—',
                    ),
                    WmsColumn(
                      key: 'total',
                      header: 'Məbləğ',
                      numeric: true,
                      cell: (row) => WmsFormat.money(row.totalAmount),
                    ),
                    WmsColumn(
                      key: 'totalBase',
                      header: 'Məbləğ (AZN)',
                      numeric: true,
                      cell: (row) => WmsFormat.money(row.totalAmountBase),
                    ),
                    WmsColumn(
                      key: 'selected',
                      header: 'Seçim',
                      width: 120,
                      render: (row, _) =>
                          row.isSelected || row.id == _selectedId
                          ? const WmsBadge(
                              text: 'Seçilib',
                              tone: WmsTone.success,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                  rows: items,
                ),
                if (noteRequired) ...[
                  const SizedBox(height: WmsSpacing.space4),
                  const WmsAlert(
                    tone: WmsAlertTone.warning,
                    title: 'Ən ucuz təklif seçilmədi',
                    message: 'Seçimin əsaslandırması sənəddə saxlanılır və audit jurnalına düşür.',
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                  WmsTextField(
                    label: l10n.labelSelectionNote,
                    required: true,
                    error: noteMissing
                        ? l10n.validationSelectionNoteRequired
                        : null,
                    onChanged: (value) =>
                        setState(() => _selectionNote = value),
                  ),
                ],
                const SizedBox(height: WmsSpacing.space5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: WmsButton.primary(
                    label: l10n.actionSelect,
                    enabled:
                        canSelect &&
                        _selectedId != null &&
                        !noteMissing &&
                        !_done,
                    disabledReason: !canSelect
                        ? l10n.labelNoPermission
                        : (_selectedId == null
                              ? 'Təklif seçilməyib'
                              : l10n.validationSelectionNoteRequired),
                    loading: _submitting,
                    onPressed: () => _select(items),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
