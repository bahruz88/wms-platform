import 'package:feature_identity/feature_identity.dart';
import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../domain/csv_file_picker.dart';
import '../consumption_alert.dart';
import '../consumption_providers.dart';
import '../date_field.dart';

/// «Satış importu» — upload a POS report as CSV and see what the parser
/// made of it.
///
/// Three things must be visible, because each of them silently loses sales
/// otherwise: which column held what, which rows could not be read, and
/// which POS codes matched no menu item. The last group is actionable here:
/// the code can be bound to a menu item (`PUT /menu-items/{id}`), which is
/// how the next upload stops producing unmapped lines.
class SalesImportScreen extends ConsumerStatefulWidget {
  const SalesImportScreen({super.key});

  @override
  ConsumerState<SalesImportScreen> createState() => _SalesImportScreenState();
}

class _SalesImportScreenState extends ConsumerState<SalesImportScreen> {
  int? _locationId;
  DateTime _businessDate = todayDate();
  PickedCsvFile? _file;
  String? _posColumn;
  String? _qtyColumn;
  String? _amountColumn;
  bool _busy = false;
  Failure? _failure;
  SalesImportParseResultDto? _result;

  SalesCsvColumnMapping get _columnMapping => SalesCsvColumnMapping(
    posCode: _posColumn,
    qtySold: _qtyColumn,
    grossAmount: _amountColumn,
  );

  Future<void> _pickFile() async {
    final picker = ref.read(csvFilePickerProvider);
    final picked = await picker.pickCsv();
    if (!mounted || picked == null) return;
    setState(() {
      _file = picked;
      _failure = null;
    });
  }

  Future<void> _upload() async {
    final file = _file;
    final locationId = _locationId;
    if (file == null || locationId == null) return;
    if (file.sizeBytes > ConsumptionApi.maxCsvBytes) {
      setState(
        () => _failure = ValidationFailure(
          ProblemDetails.local(
            code: ProblemCodes.fileTooLarge,
            title: 'Fayl çox böyükdür',
            detail:
                '${file.fileName} — ${file.sizeBytes} bayt. '
                'Maksimum ${ConsumptionApi.maxCsvBytes} bayt.',
            status: 422,
          ),
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _failure = null;
      _result = null;
    });
    final result = await ref
        .read(consumptionRepositoryProvider)
        .uploadSalesCsv(
          locationId: locationId,
          businessDate: _businessDate,
          bytes: file.bytes,
          filename: file.fileName,
          columnMapping: _columnMapping.isEmpty ? null : _columnMapping,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((parsed) => _result = parsed, (f) => _failure = f);
    });
    if (_result != null) ref.invalidate(salesImportListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locations = ref.watch(locationListProvider).value ?? const [];
    final picker = ref.watch(csvFilePickerProvider);
    final imports = ref.watch(salesImportListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consSalesImport)),
      body: RequirePermission.withNotice(
        permission: Permissions.salesImport,
        child: WmsLoadingOverlay(
          loading: _busy,
          child: ListView(
            padding: const EdgeInsets.all(WmsSpacing.space4),
            children: [
              _UploadPanel(
                locations: locations,
                locationId: _locationId,
                businessDate: _businessDate,
                file: _file,
                pickerAvailable: picker.isAvailable,
                posColumn: _posColumn,
                qtyColumn: _qtyColumn,
                amountColumn: _amountColumn,
                onLocationChanged: (value) =>
                    setState(() => _locationId = value),
                onDateChanged: (value) => setState(() => _businessDate = value),
                onPickFile: _pickFile,
                onPosColumnChanged: (value) =>
                    setState(() => _posColumn = value),
                onQtyColumnChanged: (value) =>
                    setState(() => _qtyColumn = value),
                onAmountColumnChanged: (value) =>
                    setState(() => _amountColumn = value),
                onUpload: _upload,
              ),
              if (_failure != null) ...[
                const SizedBox(height: WmsSpacing.space4),
                ConsumptionAlert(
                  failure: _failure!,
                  onClose: () => setState(() => _failure = null),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: WmsSpacing.space5),
                _ParseResult(result: _result!),
              ],
              const SizedBox(height: WmsSpacing.space6),
              Text(
                l10n.consSalesImport,
                style: WmsTypography.title.copyWith(
                  color: WmsColors.of(context).ink,
                ),
              ),
              const SizedBox(height: WmsSpacing.space3),
              AsyncView<Page<SalesImportDto>>(
                value: imports,
                onRetry: () => ref.invalidate(salesImportListProvider),
                builder: (page) => _ImportTable(rows: page.items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.locations,
    required this.locationId,
    required this.businessDate,
    required this.file,
    required this.pickerAvailable,
    required this.posColumn,
    required this.qtyColumn,
    required this.amountColumn,
    required this.onLocationChanged,
    required this.onDateChanged,
    required this.onPickFile,
    required this.onPosColumnChanged,
    required this.onQtyColumnChanged,
    required this.onAmountColumnChanged,
    required this.onUpload,
  });

  final List<LocationDto> locations;
  final int? locationId;
  final DateTime businessDate;
  final PickedCsvFile? file;
  final bool pickerAvailable;
  final String? posColumn;
  final String? qtyColumn;
  final String? amountColumn;
  final ValueChanged<int?> onLocationChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onPickFile;
  final ValueChanged<String> onPosColumnChanged;
  final ValueChanged<String> onQtyColumnChanged;
  final ValueChanged<String> onAmountColumnChanged;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return Container(
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
            l10n.consActionUploadCsv,
            style: WmsTypography.title.copyWith(color: c.ink),
          ),
          const SizedBox(height: WmsSpacing.space3),
          if (!pickerAvailable) ...[
            const WmsAlert(
              tone: WmsAlertTone.warning,
              title: 'Bu platformada fayl seçilə bilmir',
              message:
                  'CSV yükləməsi veb tətbiqdə işləyir. Mobil cihazda filial '
                  'günün satışını əl ilə daxil edir.',
            ),
            const SizedBox(height: WmsSpacing.space3),
          ],
          Wrap(
            spacing: WmsSpacing.space4,
            runSpacing: WmsSpacing.space3,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 280,
                child: WmsSelect<int>(
                  label: l10n.labelLocation,
                  required: true,
                  value: locationId,
                  placeholder: 'Filial seçin',
                  options: [
                    for (final location in locations)
                      WmsSelectOption(
                        value: location.id,
                        label: '${location.code} · ${location.name}',
                        enabled: !location.isVirtual,
                        disabledReason: location.isVirtual
                            ? 'virtual lokasiya'
                            : null,
                      ),
                  ],
                  onChanged: onLocationChanged,
                ),
              ),
              SizedBox(
                width: 210,
                child: ConsumptionDateField(
                  label: l10n.consLabelBusinessDate,
                  value: businessDate,
                  lastDate: todayDate(),
                  onChanged: onDateChanged,
                ),
              ),
              SizedBox(
                width: 300,
                child: WmsField(
                  label: l10n.consLabelFile,
                  required: true,
                  hint: file == null
                      ? 'Maksimum 5 MB · UTF-8 və ya Windows-1254'
                      : '${file!.sizeBytes} bayt',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          file?.fileName ?? '—',
                          style: WmsTypography.docNo.copyWith(color: c.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      WmsButton(
                        label: l10n.consActionChooseFile,
                        size: WmsButtonSize.sm,
                        enabled: pickerAvailable,
                        disabledReason: 'Fayl dialoqu mövcud deyil',
                        onPressed: onPickFile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WmsSpacing.space4),
          Text(
            l10n.consLabelColumnMapping,
            style: WmsTypography.label.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: WmsSpacing.space2),
          Wrap(
            spacing: WmsSpacing.space4,
            runSpacing: WmsSpacing.space3,
            children: [
              SizedBox(
                width: 220,
                child: WmsTextField(
                  label: l10n.consLabelPosCode,
                  placeholder: 'PLU',
                  mono: true,
                  onChanged: onPosColumnChanged,
                ),
              ),
              SizedBox(
                width: 220,
                child: WmsTextField(
                  label: l10n.consLabelSold,
                  placeholder: 'Qty',
                  mono: true,
                  onChanged: onQtyColumnChanged,
                ),
              ),
              SizedBox(
                width: 220,
                child: WmsTextField(
                  label: 'Məbləğ',
                  placeholder: 'Amount',
                  mono: true,
                  onChanged: onAmountColumnChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: WmsSpacing.space4),
          WmsButton.primary(
            label: l10n.consActionUploadCsv,
            enabled: file != null && locationId != null,
            disabledReason: locationId == null ? 'Filial seçin' : 'Fayl seçin',
            onPressed: onUpload,
          ),
        ],
      ),
    );
  }
}

class _ParseResult extends StatelessWidget {
  const _ParseResult({required this.result});

  final SalesImportParseResultDto result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final import = result.salesImport;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WmsAlert(
          tone: result.hasParseErrors
              ? WmsAlertTone.warning
              : WmsAlertTone.success,
          title:
              '${result.parsedRows} sətir oxundu · '
              '${result.parseErrors.length} sətir oxunmadı',
          message: result.hasParseErrors
              ? 'Oxunmayan sətirlər sənədə düşmədi; qalanı qaralama kimi '
                    'yazıldı. Faylı düzəldib yenidən yükləyin.'
              : 'Sənəd qaralama kimi yaradıldı. Təsdiqdən sonra hesablana bilər.',
        ),
        if (result.hasParseErrors) ...[
          const SizedBox(height: WmsSpacing.space3),
          WmsDataTable<SalesParseErrorDto>(
            caption: l10n.consLabelParseErrors,
            rowKey: (row, _) => row.rowNumber,
            minWidth: 560,
            emptyReason: 'Oxuna bilməyən sətir yoxdur.',
            columns: [
              WmsColumn(
                key: 'row',
                header: l10n.consLabelRow,
                width: 80,
                numeric: true,
                cell: (row) => '${row.rowNumber}',
              ),
              WmsColumn(
                key: 'message',
                header: 'Səbəb',
                flex: 3,
                cell: (row) => row.message,
              ),
              WmsColumn(
                key: 'raw',
                header: 'Fayldakı sətir',
                flex: 4,
                render: (row, _) => Text(
                  row.rawLine ?? '—',
                  style: WmsTypography.docNo.copyWith(color: c.inkMuted),
                ),
              ),
            ],
            rows: result.parseErrors,
          ),
        ],
        if (import.hasUnmapped) ...[
          const SizedBox(height: WmsSpacing.space4),
          _UnmappedPanel(import: import),
        ],
      ],
    );
  }
}

/// POS codes that matched no menu item. They are kept verbatim
/// (`raw_pos_code`) and can be bound to a menu item right here.
class _UnmappedPanel extends ConsumerStatefulWidget {
  const _UnmappedPanel({required this.import});

  final SalesImportDetailDto import;

  @override
  ConsumerState<_UnmappedPanel> createState() => _UnmappedPanelState();
}

class _UnmappedPanelState extends ConsumerState<_UnmappedPanel> {
  final Map<String, int> _picked = {};
  final Set<String> _mapped = {};
  Failure? _failure;
  bool _busy = false;

  Future<void> _map(String posCode, List<MenuItemDto> items) async {
    final menuItemId = _picked[posCode];
    if (menuItemId == null) return;
    final item = items.cast<MenuItemDto?>().firstWhere(
      (i) => i?.id == menuItemId,
      orElse: () => null,
    );
    if (item == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await ref
        .read(consumptionRepositoryProvider)
        .updateMenuItem(
          item.id,
          UpdateMenuItemRequest(
            code: item.code,
            name: item.name,
            rowVersion: item.rowVersion,
            posCode: posCode,
            category: item.category,
            isSubRecipe: item.isSubRecipe,
            isActive: item.isActive,
          ),
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      result.fold((_) => _mapped.add(posCode), (f) => _failure = f);
    });
    if (_failure == null) {
      ref
        ..invalidate(menuItemCatalogProvider)
        ..invalidate(sellableMenuItemsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final codes = widget.import.unmappedPosCodes.toSet().toList();
    final items = ref.watch(menuItemCatalogProvider).value?.items ?? const [];

    return WmsLoadingOverlay(
      loading: _busy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WmsAlert(
            key: const ValueKey('cons-unmapped-alert'),
            tone: WmsAlertTone.warning,
            title:
                '${widget.import.unmappedCount} sətir '
                '${l10n.consUnmappedTitle}',
            message: l10n.consUnmappedExplained,
          ),
          if (_failure != null) ...[
            const SizedBox(height: WmsSpacing.space3),
            ConsumptionAlert(
              failure: _failure!,
              onClose: () => setState(() => _failure = null),
            ),
          ],
          const SizedBox(height: WmsSpacing.space3),
          WmsDataTable<String>(
            caption: l10n.consLabelUnmapped,
            rowKey: (row, _) => row,
            minWidth: 620,
            emptyReason: 'Tanınmayan POS kodu yoxdur.',
            emptyNextStep: 'Bütün sətirlər menyu maddəsinə bağlandı.',
            columns: [
              WmsColumn(
                key: 'posCode',
                header: l10n.consLabelPosCode,
                width: 160,
                render: (row, _) => Text(
                  row,
                  style: WmsTypography.docNo.copyWith(
                    color: WmsColors.of(context).ink,
                  ),
                ),
              ),
              WmsColumn(
                key: 'menuItem',
                header: l10n.consLabelMenuItem,
                flex: 3,
                render: (row, _) => WmsSelect<int>(
                  value: _picked[row],
                  placeholder: 'Menyu maddəsi seçin',
                  enabled: !_mapped.contains(row),
                  options: [
                    for (final item in items)
                      WmsSelectOption(
                        value: item.id,
                        label: '${item.code} · ${item.name}',
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    if (value == null) {
                      _picked.remove(row);
                    } else {
                      _picked[row] = value;
                    }
                  }),
                ),
              ),
              WmsColumn(
                key: 'action',
                header: '',
                width: 200,
                render: (row, _) => _mapped.contains(row)
                    ? const WmsBadge(text: 'Bağlandı', tone: WmsTone.success)
                    : RequirePermission(
                        permission: Permissions.recipeManage,
                        child: WmsButton(
                          label: l10n.consActionMapPosCode,
                          size: WmsButtonSize.sm,
                          enabled: _picked[row] != null,
                          disabledReason: 'Menyu maddəsi seçin',
                          onPressed: () => _map(row, items),
                        ),
                      ),
              ),
            ],
            rows: codes,
          ),
        ],
      ),
    );
  }
}

class _ImportTable extends StatelessWidget {
  const _ImportTable({required this.rows});

  final List<SalesImportDto> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    return WmsDataTable<SalesImportDto>(
      rowKey: (row, _) => row.id,
      minWidth: 860,
      emptyReason: l10n.consEmptyImportsReason,
      emptyNextStep: l10n.consEmptyImportsNext,
      columns: [
        WmsColumn(
          key: 'businessDate',
          header: l10n.consLabelBusinessDate,
          width: 130,
          cell: (row) => WmsFormat.date(row.businessDate),
        ),
        WmsColumn(
          key: 'location',
          header: l10n.labelLocation,
          flex: 3,
          cell: (row) => row.locationName ?? '#${row.locationId}',
        ),
        WmsColumn(
          key: 'source',
          header: l10n.consLabelSource,
          width: 110,
          render: (row, _) => WmsBadge(
            text: row.source.wire,
            tone: row.source == SalesSource.manual
                ? WmsTone.neutral
                : WmsTone.accent,
            tooltip: 'cons_sales_import.source',
          ),
        ),
        WmsColumn(
          key: 'lineCount',
          header: l10n.consLabelLineCount,
          width: 100,
          numeric: true,
          cell: (row) => '${row.lineCount}',
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
              fontWeight: row.hasUnmapped ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        WmsColumn(
          key: 'gross',
          header: 'Məbləğ',
          flex: 2,
          numeric: true,
          cell: (row) => WmsFormat.money(row.grossAmount),
        ),
        WmsColumn(
          key: 'status',
          header: l10n.labelStatus,
          width: 170,
          render: (row, _) => WmsDocStatusBadge(status: row.status.wire),
        ),
      ],
      rows: rows,
    );
  }
}
