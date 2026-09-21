import 'package:decimal/decimal.dart';
import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../domain/daily_sales_draft.dart';
import '../../domain/daily_sales_submitter.dart';
import '../consumption_alert.dart';
import '../consumption_providers.dart';

/// «Günün satışı» — the branch types how many of each menu item were sold
/// on a business date. This is the manual feed of ADR-012: no POS, no CSV,
/// just the till roll and a phone held in one hand.
///
/// Fast on purpose: search on top, the items just touched float to the
/// front of the list, the quantity control opens a numeric keypad and the
/// running total sits above the submit bar so the figure can be checked
/// against the till without scrolling.
///
/// Submitting moves the day's import from `DRAFT` to `SUBMITTED`; from
/// there the nightly `ConsumptionRunner` (or the manager) turns it into a
/// consumption document.
class DailySalesScreen extends ConsumerStatefulWidget {
  const DailySalesScreen({super.key});

  @override
  ConsumerState<DailySalesScreen> createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends ConsumerState<DailySalesScreen> {
  bool _submitting = false;
  Failure? _failure;
  bool _submitted = false;

  /// Units sold are whole pieces; the control still enforces the no-negative
  /// rule and the base-unit line of `WmsQtyUomInput`.
  static const int _unitDecimals = 0;

  List<WmsProductUom> get _portionUom => [
    WmsProductUom(id: 0, code: 'ədəd', factorToBase: Decimal.one),
  ];

  Future<void> _submit(int locationId, DateTime businessDate) async {
    final draft = ref.read(dailySalesDraftProvider);
    if (draft.isEmpty) return;
    setState(() {
      _submitting = true;
      _failure = null;
      _submitted = false;
    });

    final existing = await ref.read(dailySalesImportProvider.future);
    final result =
        await DailySalesSubmitter(ref.read(consumptionRepositoryProvider))
            .submit(
              locationId: locationId,
              businessDate: businessDate,
              draft: draft,
              existing: existing,
            );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      result.fold((_) => _submitted = true, (failure) => _failure = failure);
    });
    if (_submitted) {
      ref.read(dailySalesDraftProvider.notifier).clear();
      ref.invalidate(dailySalesImportProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consDailySales)),
      body: RequirePermission.withNotice(
        permission: Permissions.salesImport,
        child: _Body(
          submitting: _submitting,
          submitted: _submitted,
          failure: _failure,
          unitDecimals: _unitDecimals,
          portionUom: _portionUom,
          onSubmit: _submit,
          onDismissFailure: () => setState(() => _failure = null),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.submitting,
    required this.submitted,
    required this.failure,
    required this.unitDecimals,
    required this.portionUom,
    required this.onSubmit,
    required this.onDismissFailure,
  });

  final bool submitting;
  final bool submitted;
  final Failure? failure;
  final int unitDecimals;
  final List<WmsProductUom> portionUom;
  final void Function(int locationId, DateTime businessDate) onSubmit;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final locationId = ref.watch(branchLocationIdProvider);
    final businessDate = ref.watch(salesBusinessDateProvider);
    final draft = ref.watch(dailySalesDraftProvider);
    final items = ref.watch(sellableMenuItemsProvider);
    final existing = ref.watch(dailySalesImportProvider);

    if (locationId == null) {
      return const WmsEmptyState(
        reason: 'Hesabınıza filial təyin edilməyib.',
        nextStep: 'Administratordan lokasiya bağlanmasını istəyin.',
        icon: Icons.store_outlined,
      );
    }

    final blocked = existing.value == null
        ? null
        : planDailySales(existing.value);
    final isBlocked = blocked is DailySalesBlocked;

    return WmsLoadingOverlay(
      loading: submitting,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(WmsSpacing.space4),
              children: [
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 16, color: c.inkMuted),
                    const SizedBox(width: WmsSpacing.space2),
                    Text(
                      '${l10n.consLabelBusinessDate}: '
                      '${WmsFormat.date(businessDate)}',
                      style: WmsTypography.bodyStrong.copyWith(color: c.ink),
                    ),
                    const Spacer(),
                    if (existing.value != null)
                      WmsDocStatusBadge(status: existing.value!.status.wire),
                  ],
                ),
                const SizedBox(height: WmsSpacing.space3),
                if (isBlocked) ...[
                  WmsAlert(
                    tone: WmsAlertTone.warning,
                    title: l10n.consAlreadySubmitted,
                    message: l10n.consAlreadySubmittedHint,
                    code: ProblemCodes.duplicateBusinessDate,
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                ],
                if (submitted) ...[
                  WmsAlert(
                    tone: WmsAlertTone.success,
                    title: l10n.consActionSubmitSales,
                    message: l10n.consEmptyResultNext,
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                ],
                if (failure != null) ...[
                  ConsumptionAlert(
                    failure: failure!,
                    onClose: onDismissFailure,
                  ),
                  const SizedBox(height: WmsSpacing.space3),
                ],
                WmsTextField(
                  label: l10n.actionSearch,
                  placeholder: 'Menyu maddəsinin adı və ya kodu',
                  onChanged: (value) => ref
                      .read(menuItemSearchProvider.notifier)
                      .setSearch(value.trim()),
                ),
                const SizedBox(height: WmsSpacing.space4),
                AsyncView<Page<MenuItemDto>>(
                  value: items,
                  onRetry: () => ref.invalidate(sellableMenuItemsProvider),
                  builder: (page) => _SalesTable(
                    items: draft.sort(page.items),
                    draft: draft,
                    editable: !isBlocked,
                    unitDecimals: unitDecimals,
                    portionUom: portionUom,
                  ),
                ),
              ],
            ),
          ),
          _SubmitBar(
            draft: draft,
            unitDecimals: unitDecimals,
            submitting: submitting,
            enabled: draft.isNotEmpty && !isBlocked,
            disabledReason: isBlocked
                ? l10n.consAlreadySubmittedHint
                : l10n.consEmptySalesNext,
            onSubmit: () => onSubmit(locationId, businessDate),
          ),
        ],
      ),
    );
  }
}

class _SalesTable extends ConsumerWidget {
  const _SalesTable({
    required this.items,
    required this.draft,
    required this.editable,
    required this.unitDecimals,
    required this.portionUom,
  });

  final List<MenuItemDto> items;
  final DailySalesDraft draft;
  final bool editable;
  final int unitDecimals;
  final List<WmsProductUom> portionUom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return WmsDataTable<MenuItemDto>(
      rowKey: (row, _) => row.id,
      minWidth: 360,
      emptyReason: l10n.consEmptyMenuItemsReason,
      emptyNextStep: l10n.consEmptyMenuItemsNext,
      columns: [
        WmsColumn(
          key: 'menuItem',
          header: l10n.consLabelMenuItem,
          flex: 3,
          render: (row, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                row.name,
                style: WmsTypography.bodyStrong.copyWith(color: c.ink),
              ),
              Text(
                row.posCode == null
                    ? row.code
                    : '${row.code} · ${l10n.consLabelPosCode} ${row.posCode}',
                style: WmsTypography.docNo.copyWith(color: c.inkMuted),
              ),
              if (!row.hasActiveRecipe)
                Padding(
                  padding: const EdgeInsets.only(top: WmsSpacing.space1),
                  child: WmsBadge(
                    text: l10n.consLabelRecipeMissing,
                    tone: WmsTone.warning,
                    tooltip: l10n.consNoRecipeWarning,
                  ),
                ),
            ],
          ),
        ),
        WmsColumn(
          key: 'qtySold',
          header: l10n.consLabelSold,
          width: 150,
          numeric: true,
          render: (row, _) => WmsQtyUomInput(
            key: ValueKey('sales-qty-${row.id}'),
            decimals: unitDecimals,
            enabled: editable,
            qty: draft.quantityOf(row.id),
            uomId: 0,
            uoms: portionUom,
            onQtyChanged: (value) => ref
                .read(dailySalesDraftProvider.notifier)
                .setQuantity(row.id, value),
          ),
        ),
      ],
      rows: items,
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.draft,
    required this.unitDecimals,
    required this.submitting,
    required this.enabled,
    required this.disabledReason,
    required this.onSubmit,
  });

  final DailySalesDraft draft;
  final int unitDecimals;
  final bool submitting;
  final bool enabled;
  final String disabledReason;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceSunken,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WmsSpacing.space3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.consLabelTotalSold,
                      style: WmsTypography.label.copyWith(color: c.inkMuted),
                    ),
                    Text(
                      key: const ValueKey('daily-sales-total'),
                      '${WmsFormat.quantity(draft.totalUnits, decimals: unitDecimals)}'
                      ' · ${draft.enteredCount} maddə',
                      style: WmsTypography.figureLg.copyWith(color: c.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: WmsSpacing.space3),
              WmsButton.primary(
                label: l10n.consActionSubmitSales,
                enabled: enabled,
                loading: submitting,
                disabledReason: disabledReason,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
